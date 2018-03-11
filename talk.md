# The JavaScript Binary AST

.center[or]

.center[**How fast can JavaScript start?**]

.center[[David Teller](about.html), Mozilla]

.center[With Shu-yu Guo (Bloomberg), Vladan Djeric (Facebook WebPerf)]

---

## Program

- Motivation
- The high cost of lexing
- The high cost of analyzing alone
- The high cost of parsing
- The high cost of fetching
- Conclusions

---

# I. Motivation

---

## Web application performance matters

- "53% of visits are abandoned if a mobile site takes more than three seconds to load" (source: [DoubleClick](https://docs.google.com/viewerng/viewer?url=https://storage.googleapis.com/doubleclick-prod/documents/The_Need_for_Mobile_Speed_-_FINAL.pdf))

---

## Parsing is a bottleneck on desktop

![JavaScript parsing is a bottleneck](img/parsing times.png)

.small[Source: [Addy Osmani](https://medium.com/reloading/javascript-start-up-performance-69200f43b201), Google]

---

## ...and worse on mobile

Parsing 1Mb of JavaScript:

![On mobile, things get up to 90x worse](img/mobile parsing times.jpeg)


.small[Source: [Addy Osmani](https://medium.com/reloading/javascript-start-up-performance-69200f43b201), Google]

---

.center[## Why?]

---


## JS startup pipeline

1. Full fetch + decompress.
2. Transcode to UTF-8.
3. Full parse + full verify + partial AST build.
4. Bytecode compile partial AST.
5. Start interpreter.

⇒ Per-byte cost is high.

---

## Native startup

By contrast:

- No verification.
- Everything is loaded lazily.

⇒ Per-byte cost is ~0.

--

Can we get close to this without changing the semantics of JavaScript?

---

# II. The high cost of lexing

---

## The high cost of lexing

Lexing JavaScript is pretty ugly:

- is `for` an identifier or a keyword?
- is `/` an operator, a regexp or a comment?
- is `"use string"` a string or a directive?
- ...

---

## Experiment 1.1

Could we speed parsing by using a better lexer?

Protocol:

1. Evaluate time spent verifying during text parse.
2. Extract (unsafe) binary format from SpiderMonkey AST.
3. Replace text parsing with binary parsing.
4. Compare speed (Facebook Chat, Firefox Devtools).

---

## Experiment 1.1 - Result

> Could we speed parsing by using a better lexer?

- Original verification time: 𝜖
- Parse duration change: * ~0.3

⇒ Experiment conclusive. Let's go Binary AST.

---

## Experiment 1.2

Can we:

- design a binary source format to transport ASTs;
- keep semantics and syntax guarantees for well-behaved programs;
- make it future-compatible?

---

Let's encode

```js
function foo(x) {
    ...
}
```


---

## Language specifications

```java
interface EagerFunctionDeclaration {
  attribute boolean isAsync;
  attribute boolean isGenerator;
  // ...
  attribute BindingIdentifier name;
  attribute FormalParameters params;
  attribute FunctionBody body;
};
```

---

## High-level: the AST

```yaml
EagerFunctionDeclaration:
    isAsync: false
    isGenerator: false
    name:
        BindingIdentifier:
            name: "foo"
    params:
        - FormalParameters:
            items:
                - BindingIdentifier:
                    name: "x"
        rest: null
    body: ...
```

---

## Low-level: Binary tokens

```js
[grammar]
  /* 0 */ EagerFunctionDeclaration [ "isAsync" ... ]
  /* 1 */ BindingIdentifier [ "name" ]
  ...
[strings]
  /* 0 */ "foo"
  /* 1 */ "x"
[ast]
  /* EagerFunctionDeclaration */ 0
    /* isAsync: false */ 0
    /* isGenerator: false */ 0
    ...
    /* name: BindingIdentifier */ 1
      /* name: "foo"*/ 0
    ...      
```

---

## Mid-level: Per-node versioning

```js
[grammar]
  /* 0 */ EagerFunctionDeclaration [
      "isAsync",
      "isGenerator",
      ...
    ]
  /* 42 */ EagerFunctionDeclaration2021 [
      "typevars",
      "logicalvars",
      ...
    ]
```

---

## Experiment 1.2 - Conclusion

> Can we:
>
> - design a binary source format to transport ASTs;
> - keep semantics and syntax guarantees for well-behaved programs;
> - make it future-compatible?

--

Experiment successful: yes, we can.

Limitation: no real-world benchmarks yet.

---

# Status

1. Full fetch + decompress.
2. **Removed** Transcode to UTF-8.
3. **Faster** Full parse + full verify + partial AST build.
4. Bytecode compile partial AST.
5. Start interpreter.

---

That's just the beginning.


---

# III. The high cost of analyzing alone

---

## Experiment 2.1

Streaming compilers can amortize the cost of fetching + decompressing to *O(1 + 𝜀)*
by folding it into compilation.

Can we do it with text JavaScript source?

---

## Interlude : the evils of eval (1)

Compare

```js
(function() {
  var a = 10;                // captured
  function foo(code) {       // not captured
    eval(code);
    return a;
  }

  console.log(foo(""));      // "10"
  console.log(foo("var a")); // "undefined"
})();
```

---

## Interlude : the evils of eval (2)

```js
(function() {
  var a = 10;                // captured
  function foo(code) {       // not captured
    my_eval(code);
    return a;
  }

  var my_eval = eval;        // captured
  console.log(foo(""));      // "10"
  console.log(foo("var a")); // "10"!
})();
```

---

## The high cost of analyzing alone

Before JS bytecode can compile a function node
or a block, it needs critical information:

- everything above the node in the AST;
- list of variables declared in children nodes;
- presence of direct calls to `eval` in subnodes;
- list of variables captured by siblings/subnode nested functions.

--

Corollary: The entire program must be parsed and verified before compilation.

---

## Experiment 2.1 - Result

> Streaming compilers can amortize the cost of fetching + decompressiong to *O(1 + 𝜀)*
> by folding it into compilation
>
> Can we do it with text JavaScript source?

⇒ No: information needed to compile the first byte may appear anywhere in the file.

---

## Experiment 2.2

Could we design a format:

- that stores all the critical information *before* it
would required by a streaming bytecode compiler;
- without compromising the interesting properties we have achieved;
- without changing the semantics of existing programs?

---

## AST Specifications (1)

```java
interface EagerFunctionDeclaration {
  attribute boolean isAsync;
  attribute boolean isGenerator;
  attribute AssertedParameterScope? parameterScope; // ☜
  attribute AssertedVarScope? bodyScope;            // ☜
  attribute BindingIdentifier name;
  attribute FormalParameters params;
  attribute FunctionBody body;
};
```

---

## AST Specifications (2)

```java
interface AssertedParameterScope {
  // Names of function parameters.
  attribute IdentifierName[] parameterNames;

  // Name of function parameters captured by nested functions.
  attribute IdentifierName[] capturedNames;

  // Presence of syntactic `eval(...)` in a descendent node.
  attribute boolean hasDirectEval;
};
```

---

## Language specifications

During compilation, throw a `SyntaxError` if `parameterNames`,
`capturedNames` or `hasDirectEval` was proven false.

---

## Experiment 2.2 - Status

> Could we design a format:
>
> - that stores all the critical information *before* it would required by a streaming bytecode compiler;
> - without compromising the interesting properties we have achieved;
> - without changing the semantics of existing programs?

⇒ Most likely. Actual verification in progress.

---

## Interlude - Relationship with PCC

We have changed information-building obligation:

- the encoder builds the information;
- the binary parser just needs to check it.

--

This is the same conceptual change as Proving Code ⇒ Proof Carrying Code.

---

# Status

1. **(WIP) O(1 + 𝜀)** Full fetch + decompress.
2. **Removed** Transcode to UTF-8.
3. **Faster** Full parse + full verify + partial AST build.
4. Bytecode compile partial AST.
5. Start interpreter.


---

# IV. The high cost of parsing

---

## The high cost of parsing

Recent JS VMs implement a lazy strategy ("Syntax Parsing"):
- parse and verify the entire file;
- only build AST for toplevel and toplevel functions;
- re-parse and re-verify nested functions as needed.

--

Would lazier parsing make things faster?

---

## Experiment 3.1 - Protocol

Would lazier parsing make things faster?

1. Evaluate first-parse time saved by Syntax Parsing.
2. Tweak unsafe binary parser to skip nested/all functions.
3. Compare speed (Facebook Chat, Firefox Devtools).

---

## Experiment 3.1 - Result

First-parse time effect:

- Syntax Parsing vs Full Parsing: * 0.8;
- Syntax Binary Parsing vs Binary Parsing: * 0.8;
- Binary Parsing (skip nested) vs Binary Parsing: * 0.45;
- Binary Parsing (skip functions) vs Binary Parsing: * 0.25

--

⇒ Experiment conclusive. Let's go lazy parsing!

---

## Experiment 3.2

Can we perform lazy parsing on text source?

---

## Experiment 3.2 - Result

Can we perform lazy parsing on text source?

- No: forbidden by JS specifications.
- No: the parser needs to parse entire functions to find out where they end.

---


## Experiment 3.3

Can we alter our binary source format:

- to allow lazy parsing source files;
- without losing the properties established before;
- without changing the semantics for any existing program;
- without changing the semantics for any well-behaved program?

---

## AST specifications

```webidl
typedef (EagerFunctionDeclaration
      or SkippableFunctionDeclaration)
    FunctionDeclaration;

[Skippable] SkippableFunctionDeclaration {
    attribute contents EagerFunctionDeclaration;
};
```

---

## Language specification

New exception: `DelayedSyntaxError`. May be thrown while *executing*
a `[Skippable]` node.

--

- Only affects new programs.
- Only affects ill-behaved programs.
- The encoder and browser may agree to skip parsing a function.

---

## Low-level: Binary tokens

```js
[grammar]
  /* 0 */ EagerFunctionDeclaration [ "isAsync" ... ]
  /* 1 */ BindingIdentifier [ "name" ]
  /* 2 */ SkippableFunctionDeclaration [ "contents" ] // ☜
  ...
[strings]
  /* 0 */ "foo"
  /* 1 */ "x"
[ast]
  /* SkippableFunctionDeclaration */ 2 // ☜
    /* implicit byte length */ 128     // ☜
    /* contents: EagerFunctionDeclaration */ 0
      /* isAsync: false */ 0
      /* isGenerator: false */ 0
      ...
    ...      
```

---

## Experiment 3.3 - Result

> Can we alter our binary source format:
>
> - to allow lazy parsing source files;
> - without losing the properties established before;
> - without changing the semantics for any existing program;
> - without changing the semantics for any well-behaved program?

--

Experiment successful: yes, we can.

---

# Status

1. **(WIP) O(1 + 𝜀)** Full fetch + decompress.
2. **Removed** Transcode to UTF-8.
3. **Faster + made lazy** Full parse + full verify + partial AST build.
4. Bytecode compile partial AST.
5. Start interpreter.


---

# V. The high cost of fetching
.center[## (Future work)]

---

## Experiment 4.1

Streaming *interpreters* can amortize the cost of fetching + decompressing **+ compiling** to *O(1 + 𝜀)*.

Can we do it with JavaScript source?

--

Clearly, no.

---

## Experiment 4.2 (WIP)

Streaming *interpreters* can amortize the cost of fetching + decompressing **+ compiling** to *O(1 + 𝜀)*.

Can we modify our AST to make it possible?

---


## Low-level: Binary tokens

```js
...
[grammar]
  /* 0 */ EagerFunctionDeclaration [ "isAsync" ... ]
  /* 1 */ BindingIdentifier [ "name" ]
  /* 2 */ SkippableFunctionDeclaration [ "contents" ]
  ...
[ast]
  // At offset 0, toplevel
  /* SkippableFunctionDeclaration */ 2
    /* declaration offset */ 32768     // ☜
  ...
  // At offset 32768
  /* contents: EagerFunctionDeclaration */ 0
    /* isAsync: false */ 0
    /* isGenerator: false */ 0
    ...      
```

---

## Experiment 4.2 - Status

> Streaming *interpreters* can amortize the cost of fetching + decompressing **+ compiling** to *O(1 + 𝜀)*.
>
> Can we modify our AST to make it possible?

- We have not affected the semantics of the language.
- We should be able to parse only the toplevel and then start execution.

⇒ Too early to conclude, but it might be possible.

---

# Status?

1. **(WIP) O(1 + 𝜀)** Full fetch + decompress.
2. **Removed** Transcode to UTF-8.
3. **(Future) O(1 + 𝜀)** Full parse + full verify + partial AST build.
4. **(Future) O(1 + 𝜀)** Bytecode compile partial AST.
5. Start interpreter.


---

# Conclusions


---


## What we have

- Clear roadmap towards from bottleneck to (hopefully) *O(1 + 𝜀)* JS startup.
- In most cases, no action required by web developer.

--

- Specifications:
  - [JS AST](https://binast.github.io/ecmascript-binary-ast/#binast-tree-grammar) (*)
  - [AST ⇒ original semantics](https://binast.github.io/ecmascript-binary-ast/#binast-transformation) (*)
  - TC39 Proposal, passed stage 0.
(*) Shu-yu Guo (Bloomberg).

--

- Tools
  - [Reference encoder/decoder](https://github.com/binast/binjs-ref).
  - [Manipulate, verify grammars](https://github.com/binast/binjs-ref).
  - [A parser generator towards C++, Rust](https://github.com/binast/binjs-ref).


---

## Next steps

- Finish SpiderMonkey implementations.
- Finish ongoing experiments.
- Real-world tests with Facebook WebPerf team.
- Real-world tests with other partners.
- Pass TC39 stage 1.
- Get it adopted by all VMs.

--

- Save the world!


---

.center[# Thank you very much!]

.center[Interested in collaborations!]

