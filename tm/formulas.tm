<TeXmacs|1.99.6>

<style|generic>

<\body>
  <section|Ecmaify>

  <\equation*>
    <tabular*|<tformat|<table|<row|<cell|<dfrac|<around*|\<llbracket\>|A|\<rrbracket\>><rsub|ecmaify>=a<rsub|1>,\<ldots\>.,a<rsub|n><space|1em><around*|\<llbracket\>|B|\<rrbracket\>><rsub|ecmaify>=b|<around*|\<llbracket\>|N|\<rrbracket\>><rsub|ecmaify>=<math-tt|function>
    f<around*|(|a<rsub|1>,\<ldots\>.,a<rsub|n>|)><around*|{|b|}>>>|<cell|<choice|<tformat|<table|<row|<cell|N.type=<math-tt|EagerFunctionDeclaration>>>|<row|<cell|N<around*|[|<math-tt|name>|]>=f>>|<row|<cell|N<around*|[|<math-tt|parameters>|]>=A>>|<row|<cell|N<around*|[|<math-tt|body>|]>=B>>|<row|<cell|N<around*|[|<math-tt|isAsync>|]>=ff>>|<row|<cell|N<around*|[|<math-tt|isGenerator>|]>=ff>>>>>>>|<row|<cell|<dfrac|<around*|\<llbracket\>|A|\<rrbracket\>><rsub|ecmaify>=a<rsub|1>,\<ldots\>.,a<rsub|n><space|1em><around*|\<llbracket\>|B|\<rrbracket\>><rsub|ecmaify>=b|<around*|\<llbracket\>|N|\<rrbracket\>><rsub|ecmaify>=<math-tt|function*>
    f<around*|(|a<rsub|1>,\<ldots\>.,a<rsub|n>|)><around*|{|b|}>>>|<cell|<choice|<tformat|<table|<row|<cell|N.type=<math-tt|EagerFunctionDeclaration>>>|<row|<cell|N<around*|[|<math-tt|name>|]>=f>>|<row|<cell|N<around*|[|<math-tt|parameters>|]>=A>>|<row|<cell|N<around*|[|<math-tt|body>|]>=B>>|<row|<cell|N<around*|[|<math-tt|isAsync>|]>=ff>>|<row|<cell|N<around*|[|<math-tt|isGenerator>|]>=tt>>>>>>>|<row|<cell|<dfrac|<around*|\<llbracket\>|A|\<rrbracket\>><rsub|ecmaify>=a<rsub|1>,\<ldots\>.,a<rsub|n><space|1em><around*|\<llbracket\>|B|\<rrbracket\>><rsub|ecmaify>=b|<around*|\<llbracket\>|N|\<rrbracket\>><rsub|ecmaify>=<math-tt|async
    function> f<around*|(|a<rsub|1>,\<ldots\>.,a<rsub|n>|)><around*|{|b|}>>>|<cell|<choice|<tformat|<table|<row|<cell|N.type=<math-tt|EagerFunctionDeclaration>>>|<row|<cell|N<around*|[|<math-tt|name>|]>=f>>|<row|<cell|N<around*|[|<math-tt|parameters>|]>=A>>|<row|<cell|N<around*|[|<math-tt|body>|]>=B>>|<row|<cell|N<around*|[|<math-tt|isAsync>|]>=tt>>|<row|<cell|N<around*|[|<math-tt|isGenerator>|]>=ff>>>>>>>>>>
  </equation*>

  <section|Binary encoding>

  <\equation*>
    <tabular*|<tformat|<table|<row|<cell|<text|<name|Bin-Node-Eager>><space|1em><dfrac|<around*|\<llbracket\>|V<rsub|1>|\<rrbracket\>><rsup|J,G,S><rsub|bin>=b<rsub|1><space|1em>\<ldots\>.<space|1em><around*|\<llbracket\>|V<rsub|n>|\<rrbracket\>><rsup|J,G,S><rsub|bin>=b<rsub|n>|<around*|\<llbracket\>|N|\<rrbracket\>><rsup|J,G,S><rsub|bin>=<around*|[|b,b<rsub|1>,\<ldots\>.,b<rsub|n>|]>><choice|<tformat|<table|<row|<cell|J.fields<around*|(|t|)>=field<rsub|1>,\<ldots\>.,field<rsub|n>>>|<row|<cell|N.type=t>>|<row|<cell|N<around*|[|field<rsub|1>|]>=V<rsub|1>>>|<row|<cell|N<around*|[|field<rsub|2>|]>=V<rsub|2>>>|<row|<cell|\<ldots\>.>>|<row|<cell|N<around*|[|field<rsub|n>|]>=V<rsub|n>>>|<row|<cell|G<around*|(|t|)>=b>>>>>>>|<row|<cell|<text|<name|Bin-String>><space|1em><dfrac|<space|4em>|<around*|\<llbracket\>|s|\<rrbracket\>><rsup|J,G,S><rsub|bin>><space|1em>S<around*|(|s|)>=b>>>>>
  </equation*>

  <section|Valid AST (before Asserted Scope)>

  <\equation*>
    <tabular*|<tformat|<table|<row|<cell|<text|<name|Valid-LabelledStatement><space|1em>><dfrac|\<Gamma\>\<oplus\><around*|(|<math-ss|label>:l|)>\<vdash\>N<rprime|'>:\<diamond\>|\<Gamma\>\<vdash\>N:\<diamond\>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|LabelledStatement>>>|<row|<cell|N<around*|[|<math-tt|body>|]>=N<rprime|'>>>|<row|<cell|N<around*|[|<math-tt|label>|]>=l>>>>>>>|<row|<cell|<text|<name|Valid-BreakStatement-Labelled><space|1em>><dfrac||\<Gamma\>\<vdash\>N:\<diamond\>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|BreakStatement>>>|<row|<cell|N<around*|[|<math-tt|label>|]>=l>>|<row|<cell|l\<in\>\<Gamma\>.label>>>>>>>>>>
  </equation*>

  <section|Bytecode Compilation (with Asserted Scope)>

  <\equation*>
    <tabular*|<tformat|<table|<row|<cell|<text|<name|Valid-CallExpression-Simple><space|1em>><dfrac|\<Gamma\>\<vdash\>N<rprime|'>:\<diamond\><space|1em>\<Gamma\>\<vdash\>N<rprime|''>:\<diamond\>|\<Gamma\>\<vdash\>N:\<diamond\>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|CallExpression>>>|<row|<cell|N<around*|[|<math-tt|callee>|]>=N<rprime|'>>>|<row|<cell|N<around*|[|<math-tt|arguments>|]>=N<rprime|''>>>|<row|<cell|>>|<row|<cell|N<rprime|'>.type\<neq\><math-tt|IdentifierExpression>>>>>>>>|<row|<cell|<text|<name|Valid-CallExpression-Not-Eval><space|1em>><dfrac|\<Gamma\>\<vdash\>N<rprime|'>:\<diamond\><space|1em>\<Gamma\>\<vdash\>N<rprime|''>:\<diamond\>|\<Gamma\>\<vdash\>N:\<diamond\>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|CallExpression>>>|<row|<cell|N<around*|[|<math-tt|callee>|]>=N<rprime|'>>>|<row|<cell|N<around*|[|<math-tt|arguments>|]>=N<rprime|''>>>|<row|<cell|>>|<row|<cell|N<rprime|'>.type=<math-tt|IdentifierExpression>>>|<row|<cell|N<rprime|'><around*|[|<math-tt|name>|]>\<neq\><text|\Peval\Q>>>>>>>>|<row|<cell|<text|<name|Valid-CallExpression-Eval><space|1em>><dfrac|\<Gamma\>\<vdash\>N<rprime|'>:\<diamond\><space|1em>\<Gamma\>\<vdash\>N<rprime|''>:\<diamond\>|\<Gamma\>\<vdash\>N:\<diamond\>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|CallExpression>>>|<row|<cell|N<around*|[|<math-tt|callee>|]>=N<rprime|'>>>|<row|<cell|N<around*|[|<math-tt|arguments>|]>=N<rprime|''>>>|<row|<cell|>>|<row|<cell|N<rprime|'>.type=<math-tt|IdentifierExpression>>>|<row|<cell|N<rprime|'><around*|[|<math-tt|name>|]>=<text|\Peval\Q>>>|<row|<cell|>>|<row|<cell|\<Gamma\>.hasDirectEval>>>>>>>|<row|<cell|<text|<name|Valid-AssertedParameterScope><space|1em>><dfrac||\<Gamma\>\<vdash\>N:\<diamond\>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|AssertedParameterScope>>>|<row|<cell|N<around*|[|<math-tt|capturedNames>|]>\<subseteq\>N<around*|[|<math-tt|parameterNames>|]>>>|<row|<cell|\<Gamma\>.hasDirectEval=N<around*|[|<math-tt|hasDirectEval>|]>>>>>>>>|<row|<cell|<text|<name|Valid-EagerFunctionDeclaration><space|1em>><dfrac|\<Gamma\>\<oplus\><around*|(|hasDirectEval:b|)>\<vdash\>N<rprime|'>:\<diamond\><space|1em>
    \<Gamma\>\<oplus\><around*|(|hasDirectEval:b|)>\<vdash\>N<rprime|''>:\<diamond\>|\<Gamma\>\<vdash\>N:\<diamond\>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|EagerFunctionDeclaration>>>|<row|<cell|N<around*|[|<math-tt|body>|]>=N<rprime|'>>>|<row|<cell|N<around*|[|parameterScope|]>=N<rprime|''>>>|<row|<cell|\<Gamma\>.hasDirectEval\<Rightarrow\>b>>>>>>>>>>
  </equation*>

  \;

  \;
</body>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?|../../../../.TeXmacs/texts/scratch/no_name_1.tm>>
    <associate|auto-2|<tuple|2|?|../../../../.TeXmacs/texts/scratch/no_name_1.tm>>
    <associate|auto-3|<tuple|3|?|../../../../.TeXmacs/texts/scratch/no_name_1.tm>>
    <associate|auto-4|<tuple|4|?|../../../../.TeXmacs/texts/scratch/no_name_1.tm>>
    <associate|auto-5|<tuple|1|?|../../../../.TeXmacs/texts/scratch/no_name_1.tm>>
  </collection>
</references>