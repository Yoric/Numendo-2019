# The JavaScript Binary AST

.center[or]

.center[**How fast can JavaScript start?**]

.center[[David Teller](about.html), Mozilla]

.center[With Shu-yu Guo (Bloomberg), Vladan Djeric (Facebook WebPerf)]

---

## Program

- Problem statement
- The high cost of lexing
- The high cost of analyzing
- The high cost of parsing
- The high cost of fetching
- Conclusions

---

# I. Problem statement

---

## Web application performance matters

- "53% of visits are abandoned if a mobile site takes more than three seconds to load" (source: [DoubleClick](https://docs.google.com/viewerng/viewer?url=https://storage.googleapis.com/doubleclick-prod/documents/The_Need_for_Mobile_Speed_-_FINAL.pdf))

---

## Parsing + compiling is a bottleneck

![JavaScript parsing + compiling is a bottleneck](img/parsing times.png)

.small[On average, parsing + compiling == 4.4s]

.small[Source: [Addy Osmani](https://medium.com/reloading/javascript-start-up-performance-69200f43b201), Google]

---

## ...especially on mobile

Parsing 1Mb of JavaScript:

![On mobile, things get up to 90x worse](img/mobile parsing times.jpeg)


.small[Source: [Addy Osmani](https://medium.com/reloading/javascript-start-up-performance-69200f43b201), Google]

---

## Recommendations around the web

- "[Measure](https://philipwalton.com/articles/why-web-developers-need-to-care-about-interactivity/)"
- "[Make your JS smaller](https://infrequently.org/2017/10/can-you-afford-it-real-world-web-performance-budgets/)"
- "[Use server push](https://www.youtube.com/watch?v=RWLzUnESylc)"
- "Make your JS lazy"
- "Minimize your JS"
- ...

--

Sure, but...

---

.center[## Why is it a bottleneck?]

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

## Requirements

- Not a new programming language.
- Not a subset or a superset of JavaScript.
- Not a bytecode.
- Do not change the semantics of existing programs.
- Do not change the semantics of well-behaved programs.
- As transparent as possible.
- Compatible with future versions of JavaScript.

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

1. Extract (unsafe) binary format from SpiderMonkey AST.
2. Replace text parsing with binary parsing.
3. Benchmark time spent verifying during text parse.
4. Compare speed (Facebook Chat, Firefox Devtools).

---

## Experiment 1.1 - Result

> Could we speed parsing by using a better lexer?

- Parse duration change: *0.3
- Original verification time: 𝜖

⇒ Experiment conclusive. Let's go Binary AST.

---

## Experiment 1.2

Can we design a binary source format to transport ASTs,
within our requirements?

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

> Can we design a binary source format to transport ASTs, within our requirements?

⇒ Experiment successful: yes, we can.

--

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

# III. The high cost of analyzing

---

## Experiment 2.1

Streaming compilers can amortize the cost of fetching + decompressing to *O(1 + 𝜀)*
by folding it into compilation.

Can we do it with text JavaScript source?

---

## Interlude - the evils of eval (1)

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

## Interlude - the evils of eval (2)

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

## Blocked by analysis

Before JS bytecode can compile a function node
or a block, it needs critical information:

- everything above the node in the AST;
- list of variables declared in children nodes;
- presence of direct calls to `eval` in subnodes;
- list of variables captured by siblings/subnode nested functions.

---

## Experiment 2.1 - Result

> Streaming compilers can amortize the cost of fetching + decompression to *O(1 + 𝜀)*
> by folding it into compilation
>
> Can we do it with text JavaScript source?

⇒ No: information needed to compile the first byte may appear anywhere in the file.

---

## Experiment 2.2

Could we amend our Binary AST to enable streaming
bytecode compilation, within our requirements?

---

## Strategy

1. Consider the text parser as a mechanic for building (informal) proofs
of presence/absence of direct `eval`, etc.
2. Reverse proof obligations into Proof-Carrying Code.

--

Yes, you have heard the word "Proof-Carrying Code" in JavaScript.

--

No, it's not April 1st.

---


## AST Specifications (1)

```java
interface EagerFunctionDeclaration {
  attribute boolean isAsync;
  attribute boolean isGenerator;

  // (Informal) proof (function parameters)
  attribute AssertedParameterScope? parameterScope;
  // (Informal) proof (function body)
  attribute AssertedVarScope? bodyScope;

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

During compilation, if `parameterNames`, `capturedNames`
or `hasDirectEval` was proven false, throw `SyntaxError`.

--

== "If the proof is false, reject it."

---

## Experiment 2.2 - Status

> Could we amend our Binary AST to enable streaming bytecode compilation, within our requirements?

- ⇒ Intuitively, yes.
- WIP: Build the streaming compiler to confirm.

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

Recent JS VMs implement a semi-lazy strategy ("Syntax Parsing"):
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
3. Evaluate time spent reifying thunks.
4. Compare speed (Facebook Chat, Firefox Devtools).

---

## Experiment 3.1 - Result

First-parse time effect:

- Full Parsing ⇒ Syntax Parsing: * 0.8;
- Binary Parsing ⇒ Syntax Binary Parsing: * 0.8;
- Binary Parsing ⇒ Binary Parsing (skip nested): * 0.45;
- Binary Parsing ⇒ Binary Parsing (skip functions): * 0.25;
- Time spent reifying thunks: 𝜀.

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

Can we alter our binary source format to allow lazy parsing source files,
within our constraints?

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

New exception: `DelayedSyntaxError`. May be thrown while **executing** a `[Skippable]` node.

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

> Can we alter our binary source format to allow lazy parsing source files, within our constraints?


⇒ Experiment successful: yes, we can.

---

# Status

1. **(WIP) O(1 + 𝜀)** Full fetch + decompress.
2. **Removed** Transcode to UTF-8.
3. **Faster + made lazy** Full parse + full verify + partial AST build.
4. Bytecode compile partial AST.
5. Start interpreter.


---

# V. The high cost of fetching
## (Future work)

---

## Experiment 4.1

Streaming **interpreters** can amortize the cost of fetching + decompressing **+ compiling** to *O(1 + 𝜀)*.

Can we do it with JavaScript text source?

--

Clearly, no.

---

## Experiment 4.2 (WIP)

Streaming **interpreters** can amortize the cost of fetching + decompressing **+ compiling** to *O(1 + 𝜀)*.

Can we modify our Binary AST to make it possible?

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

> Streaming **interpreters** can amortize the cost of fetching + decompressing **+ compiling** to *O(1 + 𝜀)*.
>
> Can we modify our Binary AST to make it possible?

- We have not affected the semantics of the language.
- We should be able to parse only the toplevel and then start execution.

⇒ Too early to conclude, but encouraging.

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

--

- All domain knowledge can be part of the toolchain/CDN.
- Requires limited/no action by web developer.

--

- Energy-efficient.
- Ideas should work with other languages.

---

## Specifications

- [JS AST](https://binast.github.io/ecmascript-binary-ast/#binast-tree-grammar) (*)
- [AST ⇒ original semantics](https://binast.github.io/ecmascript-binary-ast/#binast-transformation) (*)
- TC39 Proposal, passed stage 1.

(*) Mostly Shu-yu Guo (Bloomberg).

---

## Tools

- [Reference encoder/decoder](https://github.com/binast/binjs-ref).
- [Manipulate, verify grammars](https://github.com/binast/binjs-ref).
- [A parser generator towards C++, Rust](https://github.com/binast/binjs-ref).


---

## Next steps

- Reference implementation
    - Work on compression.
    - Finish ongoing experiments.
- Real-world data
    - Finish SpiderMonkey implementation.
    - Real-world tests with partners.
- Language
    - Pass TC39 stage 2.
    - Get it adopted by all VMs.

---

.center[# Thank you very much!]

.center[Interested in collaborations!]

