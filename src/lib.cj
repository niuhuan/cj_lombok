macro package cj_lombok

import std.ast.*

// define quote
const  comma = ", "
const  eq = " = "
const  bracketOpen = "("
const  bracketClose = ")"

public macro ToString(input: Tokens): Tokens {
    // take the input and parse it as a class declaration
    let decl = parseDecl(input)
    if (!(decl is ClassDecl)) {
        diagReport(DiagReportLevel.ERROR, input[0..(0 + 1)], "ToString macro can only be applied to classes", "should be class")
    }
    let classDecl = (decl as ClassDecl).getOrThrow()  
    // foreach var decl in the class declaration
    var toStringTokens = quote("")
    var first = true
    for ( decl in classDecl.body.decls){
        if (let Some(propDecl) <- decl as VarDecl) {
            let propName = propDecl.identifier
            if (!first) {
 
                toStringTokens += quote ( + $comma )
            } else {
                first = false
            }
            let propNameValue = 
            propName.value
            toStringTokens += quote ( + $propNameValue + $eq + this.$(propName).toString() )
        }
    }
    // append the toString function to the class declaration
    let classIdentifierValue = classDecl.identifier.value
    toStringTokens = quote (
        public func toString(): String {
            return $classIdentifierValue + $bracketOpen + $(toStringTokens) + $bracketClose
        }
    )
    classDecl.body.decls.append(FuncDecl(toStringTokens))
    // add the ToString interface to the class declaration 
    classDecl.superTypes.append(RefType(quote( ToString )))
    // return the class declaration
    let result = quote (
            $(classDecl)
    )
    return result
}


