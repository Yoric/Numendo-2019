% BinAST

# BinAST

or

**How fast can JavaScript start?**

David Teller (Yoric), Mozilla


---

Joint work:

- Mozilla (SpiderMonkey team, community)
- Facebook (WebPerf team)
- Bloomberg
- CloudFlare

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

# How JavaScript works

---

## JS startup pipeline

![](img/pipes.jpg)

---

## JS startup pipeline

![](img/pipeline 1.png)

---

## + Optimizations

![](img/pipeline 2.png)

---

## Contrast with ~native

![](img/dotnet.png)


---

# Hello, BAST

![](img/bast.png)


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
if (Constants.DEBUG) {
  // ...
}
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
function later() {
  // Not used during startup
}
function init() {
  // Used during startup
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

## ... and

- Start *parsing* `init` before `later` is received.
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

![](img/pipeline 3.png)

---

# How we test it! (*)

1. Replace `uglify` with `binjs_encode`.
2. Replace `text/javascript` with `application/javascript-binast`.
3. Done.

(*) Not ready for prime-time.

---

- JavaScript startup is a bottleneck.
- But it doesn't need to be!
- Reduce the amount of work at every step.
- Save time and energy!
- Improvements in progress.
- Experiments in progress.
- No programming language harmed!

---

# Soon on a browser / server near you? :)
