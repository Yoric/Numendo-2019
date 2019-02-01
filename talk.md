% The JavaScript Binary AST

# The JavaScript Binary AST

or

**How fast can JavaScript start?**

David Teller (Yoric), Mozilla

---

## Web application performance matters

- "53% of visits are abandoned if a mobile site takes more than **3 seconds** to load" (source: [DoubleClick](https://docs.google.com/viewerng/viewer?url=https://storage.googleapis.com/doubleclick-prod/documents/The_Need_for_Mobile_Speed_-_FINAL.pdf))

--

- "Apps became interactive in **8 seconds** on desktop (using cable) and **16 seconds** on mobile (Moto G4 over 3G)"(median value, source: [Addy Osmani](https://medium.com/reloading/javascript-start-up-performance-69200f43b201), Google)


---

## What's the problem?

- Lots of code.
- Code slows you down, even when you don't execute it.

---

## Parsing

![](img/mobile parsing times.jpeg)

---

## JS startup pipeline

1. Full fetch + decompress.
2. Transcode to UTF-8.
3. Full tokenize + parse + verify
4. Partial AST build.
5. Bytecode compile partial AST.
6. Start interpreter.

---

## Optimizing (as a webdev)

1. Full fetch + decompress. – Minify + compress.
2. Transcode to UTF-8. – Serve as UTF-8.
3. Full tokenize + parse + verify – ?
4. Partial AST build – IIFE
5. Bytecode compile partial AST – ?
6. Start interpreter – ?

---

## Contrast with ~native

0. Pre-compile.
1. Lazy fetch.
2. No transcode.
3. No/minimal/lazy parse.
4. No/lazy dynamic compile.
5. Start interpreter.

---

## Let's try this
### Without modifying the language!

---

# Fixing parsing
Beyond IIFE

---

## Parsing is slow, because

- Tokens are complicated.
- Strings are complicated.
- `eval`.
- `SyntaxError`.
- Closures.

---

## So...

- Simplify tokens, strings.
- Pre-process `eval`, `SyntaxError`, closures.

---

## Instead of this

```js
function foo(x) {
  // No `eval`.
}
```

---

## Store this

```yaml
Names:
  - ["foo", ...]

FunctionDeclaration:
  name: 0
  eval: false
  body:
    ...
```

---

## Results

- Time spent parsing + verifying: -30%.
- Further optimizations coming :)

---

# Fixing download
Beyond minification

---

```js
const log = require('my-logger')('my-module');
const {parse, print} = require('my-parser');
// ...
```

---

- Strings, identifiers, properties are repeated.
- Many repeats across libraries.
- Code has patterns!

---

- String, identifier, properties dictionary.
- Code pattern dictionary.
- => ~1.2 bits/code construction.
- => ~2-6 bits/string, identifier, properties use.

---

## Results

- With a good dictionary, ~size parity with minification + brotli.
- *Without minification*
- Further optimizations coming :)

---

# Fixing compilation

---

## Instead of this

```js
function init() {
  // Used during startup
}
function later() {
  // Not used during startup
}
```

---

## Store this

```js
// Initial packet.
function init() {
  // Used during startup
}
```

```js
// Another packet.
function later() {
  // Not used during startup
}
```

---

##... and

- Start *compiling* `init` before `later` is received.
- Start *running* `init` before `later` is received.
- So yeah, we're working on *streaming* JavaScript.

---

## Results (lab)

- Time spent parsing: -75% (*).
- Time spent compiling: ~background task (*).

(*) Simulations.

---


# Conclusions

---

- JavaScript startup is a bottleneck.
- But it doesn't need to be!
- Reduce the amount of work at every step.
- Improvements in progress.
- Experiments in progress.

---

# Soon on a browser / Node near you? :)
