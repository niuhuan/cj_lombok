package cj_lombok.eqs

import cj_lombok.commons.*
import std.ast.*
import std.collection.*

public func eqs(input: Tokens): Tokens {
    // take the input and parse it as a class declaration
    let (inputDecl, classDecl) = parseClassDecl(input)
    // foreach var decl in the class declaration
    var eqBodyTokens = quote ()
    var first = true
    for (decl in classDecl.body.decls){
        if (let Some(varDecl) <- decl as VarDecl) {
            if (first) {
                first = false
            } else {
                eqBodyTokens += quote ( && )
            }
            let varName = varDecl.identifier
            eqBodyTokens += quote ( this.$(varName) == other.$(varName) )
        }
    }
    let eqTokens = quote (
        public operator func == (other: $(classDecl.identifier)): Bool {
            $eqBodyTokens
        }
    )
    // add the eqTokens to the class declaration
    classDecl.body.decls.append(FuncDecl(eqTokens))
    // return the class declaration
    let result = quote (
            $(inputDecl)
    )
    return result
}
