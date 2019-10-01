% BinAST
%or
%**Brisons le mur du chargement JS !**

---

David Teller (Yoric), Mozilla, Tech Lead

Un projet

- Mozilla
- Facebook
- Bloomberg
- CloudFlare

---

## Sur le web, la vitesse compte

:::incremental

- (sans blague !)
- [DoubleClick](https://storage.googleapis.com/doubleclick-prod/documents/The_Need_for_Mobile_Speed_-_FINAL.pdf) : sur mobile, si le chargmenet dure **3+ secondes**, 53% des visites sont abandonnées
- [Addy Osmani](https://medium.com/reloading/javascript-start-up-performance-69200f43b201) : en médiane, le TTI dure **8 secondes** sur fixe, **16 secondes** sur mobile
:::

---

![](img/slow.png)

---

## Quel est le problème?

:::incremental

- Du code.
- Beaucoup de code.
- Et vous, vous avez combien de code ?
- Le code vous ralentit.
- ... même si vous ne l'utilisez pas !

:::

---

## Parsing

![](img/mobile parsing times.jpeg)

---

# Comment JavaScript démarre

---

## On met du code...

![](img/pipes.jpg)

---


![](img/pipeline 1.png)

---

## En optimisant...

![](img/pipeline 2.png)

---

## Et le code natif ?

![](img/dotnet.png)


---


# Parlons de BinAST

- JavaScript
- **Bin**ary
- **A**bstract
- **S**yntax
- **T**ree

---

Pas de panique !

---

![](img/bast.png)


---

# Parsons plus vite

Au-delà de IIFE

---

## Le parseur est lent...

- Les Tokens, c'est compliqué.
- Les Chaînes de caractères, c'est compliqué.
- Les clôtures, c'est compliqué.
- `eval`.
- `SyntaxError`.

---

## Du coup...

- Simplifions les Tokens et les Chaînes.
- Gérons `eval`, `SyntaxError`, les clôtures en amont.

---

## Au lieu de ça

```js
function foo(x) {
  // Pas d'`eval`.
}
```

---

## Enregistrons ça

```yaml
Names:
  - ["foo", ...]

FunctionDeclaration: // 42
  name: 0            // 0
  eval: false        // 0
  body:              // ...
    ...
```

---

## Résultat

- Parser + analyse statique: durée -30%.
- C'est pas fini :)

---

# Téléchargeons plus vite

Au-delà de la minification

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

- Les chaînes, les noms... se répètent.
- Des répétitions entre bibliothèques.
- Le code a des motifs !

---

## Du coup, apprenons...

- Dictionnaires de chaînes, noms...
- Dictionnaires de code.
- Un dictionnaire par site web.
- => ~1.2 bits/nœud.
- => ~2-6 bits/chaîne, nom...

---

## Résultat

- Avec un bon dictionnaire, ~minification + brotli.
- *Sans minification.*
- C'est pas fini :)

---

# Compilons plus vite

---

## Au lieu de ça...

```js
function init() {
  // Exécuté tout de suite
  // ...
  button.addEventListener("click",
    function later() {
      // Exécuté plus tard
    });
}
```

---

## ...enregistrons ça

```js
// Paquet #1
function init() {
  // ...
  button.addEventListener("click", $later);
}
```

```js
// Paquet #N
function $later() {
  // ...
}
```

---

## ...du coup

:::incremental

- ...ne {parsons, compilons} que ce dont nous avons besoin.
- ...{parsons, compilons, exécutons} avant d'avoir reçu tout le fichier.
- Oui, nous parlons bien de *streaming* de JavaScript.

:::

---

## Résultats (labo)

- Parser: durée -75% (*).
- Compiler: ~se fait en parallèle (*).

(*) À confirmer.


---

# Conclusions

---

![](img/pipeline 3.png)

---

## Résultats

:::incremental

- Le démarrage du JavaScript est un goulot d'étranglement.
- Nous pouvons le résoudre !
- Sans changer le code.
- Sans changer le langage.
- Moins de travail pour l'ordinateur !

:::

---

## Montrez-moi le code !

- WIP.
- https://github.com/binast
- Firefox Nightly (caché derrière une préférence)
- Slides: https://yoric.github.io/Numendo-2019
- Bientôt sur un navigateur & et un serveur près de chez vous :)

---

# Contributeurs bienvenus !

- https://github.com/binast
