# HolyJIT: Towards staged JIT compilation

## Early stage research


Nicolas B. Pierron, David Teller

`{ nbp, dteller } @mozilla.com`

---

## Anatomy of a JIT compiler

Example: SpiderMonkey

1. Parser
2. Bytecode compiler
3. Interpreter
4. Native compiler
5. Optimizing native compiler

---

## Implementations of the language

1. Interpreter
2. Native compiler
3. Optimizing native compiler
4. Also, Inline Caches

--

That's a bit too much.

---

# Objectives


1. Reduce the number of implementations of the *same* language.
2. Reduce TCB.
3. Provide a generic toolbox to build JIT-compiled languages (e.g. JS, CSS).
4. Simplify testing.
5. Maintain type-safety as long as we can.

---

## From specifications to execution

Anatomy of an implementation:

- Opcode specifications (source code)
- State
- => Control Flow Graph
- => Native

--

Same anatomy for:

- interpreter;
- native compiler;
- optimizing native compiler;
- ...

---

# Towards staged JIT compilation

---

## Start with specifications

```rust
// Define a single opcode.
opcode!(Op::Add => {
    let lval = stack.pop()?;
    let rval = stack.pop()?;
    let lprim = lval.to_primitive()?;
    let rprim = rval.to_primitive()?;
    match (lprim.type_(), rprim.type_()) {
        (String, _) | (_, String) => {
            let lstring = lprim.to_string()?;
            let rstring = rprim.to_string()?;
            stack.push(JSString::concat(lstring, rstring)?)
        }
        _ => {
            let lnum = lprim.to_number()?;
            let rnum = lprim.to_number()?;
            stack.push(JSNumber::add(lnum, rnum)?)
        }
    }
})
```

---

## Extracting a bytecode interpreter

During VM build, for each opcode:
- Opcode specifications
- => Control Flow Graph
- => CFG as Executable (Native? WebAssembly?)
- => CFG as Data

--

We have a bytecode interpreter.

--

New **build-time** tool introduced: CFG => CFG as Data (generic).

---

## Add a program

JS expression:
```js
arg_5.length + 1
```

Bytecode:
```
Op::GetArg(5)
Op::Int8(1)
Op::Length(0)
Op::Add
```

---

## Extracting a naive native compiler

During VM execution, our program is a bunch of opcodes.

- CFG as Data
- => Combine CFG blocks
- => CFG as Executable

--

We have runtime-built native code.

--

New **runtime** tools introduced:

- combine CFG blocks (generic);
- CFG as Data => Executable (generic).

---

# Beyond multi-stage compilation

So far, we have a variant of multi-stage compilation.

How do we go further?

--

Extend the toolset.

---

## Example extension: tracing

```rust
opcode!(Op::Add => {
    let lval = stack.pop()?;
    let rval = stack.pop()?;
    trace!{
        // Same source code as above.
        // However, this generates a CFG instrumented to produce traces as CFG.
        let lprim = lval.to_primitive()?;
        let rprim = rval.to_primitive()?;
        // ...
    }
})
```

--

New **build-time** tool introduced: CFG => tracing CFG as Data (generic).

Part of a standard library of build-time tools.

---

# Current status

- Early stage research.
- How do we articulate several optimizing compilers together?
- How can developers specify tracing strategies? (e.g. long-running loops)
- [Proof of concept](https://github.com/nbp/holyjit).