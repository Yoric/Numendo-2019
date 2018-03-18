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
    <tabular*|<tformat|<table|<row|<cell|<text|><dfrac|\<Gamma\>\<oplus\><around*|(|<math-ss|label>:l|)>\<vdash\>N<rsub|body>:<math-tt|Statement>|\<Gamma\>\<vdash\>N:<math-tt|LabelledStatement>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|LabelledStatement>>>|<row|<cell|N<around*|[|<math-tt|body>|]>=N<rsub|body>>>|<row|<cell|N<around*|[|<math-tt|label>|]>=l>>|<row|<cell|l\<neq\>\<epsilon\>>>>>>>>|<row|<cell|<text|><dfrac||\<Gamma\>\<vdash\>N:<math-tt|BreakStatement>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|BreakStatement>>>|<row|<cell|N<around*|[|<math-tt|label>|]>=l>>|<row|<cell|l\<in\>\<Gamma\>.label>>>>>>>>>>
  </equation*>

  <section|Bytecode Compilation (with Asserted Scope)>

  <\equation*>
    <tabular*|<tformat|<table|<row|<cell|<text|><dfrac|\<Gamma\>\<vdash\>N<rsub|callee>:<math-tt|Expression><space|1em>\<Gamma\>\<vdash\>N<rsub|args>:<math-tt|Arguments>|\<Gamma\>\<vdash\>N:<math-tt|CallExpression>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|CallExpression>>>|<row|<cell|N<around*|[|<math-tt|callee>|]>=N<rsub|callee>>>|<row|<cell|N<around*|[|<math-tt|arguments>|]>=N<rsub|args>>>|<row|<cell|>>|<row|<cell|N<rsub|callee>.type\<neq\><math-tt|IdentifierExpression>>>>>>>>|<row|<cell|<text|><dfrac|\<Gamma\>\<vdash\>N<rsub|callee>:<math-tt|IdentifierExpression><space|1em>\<Gamma\>\<vdash\>N<rsub|args>:<math-tt|Arguments>|\<Gamma\>\<vdash\>N:<math-tt|CallExpression>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|CallExpression>>>|<row|<cell|N<around*|[|<math-tt|callee>|]>=N<rsub|callee>>>|<row|<cell|N<around*|[|<math-tt|arguments>|]>=N<rsub|args>>>|<row|<cell|>>|<row|<cell|N<rsub|callee><around*|[|<math-tt|name>|]>\<neq\><text|\Peval\Q>>>>>>>>|<row|<cell|<text|><dfrac|\<Gamma\>\<vdash\>N<rsub|callee>:<math-tt|IdentifierExpression><space|1em>\<Gamma\>\<vdash\>N<rsub|args>:<math-tt|Arguments>|\<Gamma\>\<vdash\>N:<math-tt|CallExpression>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|CallExpression>>>|<row|<cell|N<around*|[|<math-tt|callee>|]>=N<rsub|callee>>>|<row|<cell|N<around*|[|<math-tt|arguments>|]>=N<rsub|args>>>|<row|<cell|>>|<row|<cell|N<rsub|callee><around*|[|<math-tt|name>|]>=<text|\Peval\Q>>>|<row|<cell|>>|<row|<cell|\<Gamma\>.hasDirectEval>>>>>>>|<row|<cell|<text|><dfrac||\<Gamma\>\<vdash\>N:<math-tt|AssertedParameterScope>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|AssertedParameterScope>>>|<row|<cell|N<around*|[|<math-tt|capturedNames>|]>\<subseteq\>N<around*|[|<math-tt|parameterNames>|]>>>|<row|<cell|\<Gamma\>.hasDirectEval=N<around*|[|<math-tt|hasDirectEval>|]>>>>>>>>|<row|<cell|<text|><dfrac|<stack|<tformat|<table|<row|<cell|\<Gamma\>\<oplus\><around*|(|hasDirectEval:b|)>\<vdash\>N<rsub|body>:<math-tt|FunctionBody>>>|<row|<cell|\<Gamma\>\<oplus\><around*|(|hasDirectEval:b|)>\<vdash\>N<rsub|paramscope>:<math-tt|AssertedParameterScope>>>|<row|<cell|\<ldots\>.>>>>>|\<Gamma\>\<vdash\>N:<math-tt|EagerFunctionDeclaration>><choice|<tformat|<table|<row|<cell|N.type=<math-tt|EagerFunctionDeclaration>>>|<row|<cell|N<around*|[|<math-tt|body>|]>=N<rsub|body>>>|<row|<cell|N<around*|[|parameterScope|]>=N<rsub|paramscope>>>|<row|<cell|\<vdots\>>>|<row|<cell|\<Gamma\>.hasDirectEval\<Rightarrow\>b>>>>>>>|<row|<cell|>>>>>
  </equation*>

  \;

  \;
</body>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?>>
    <associate|auto-2|<tuple|2|?>>
    <associate|auto-3|<tuple|3|?>>
    <associate|auto-4|<tuple|4|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Ecmaify>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>Binary
      encoding> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|3<space|2spc>Valid
      AST (before Asserted Scope)> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|4<space|2spc>Bytecode
      Compilation (with Asserted Scope)> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>