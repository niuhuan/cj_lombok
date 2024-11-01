package cj_lombok.to_string

import cj_lombok.commons.*
import std.ast.*
import std.collection.*

// define quote
const  comma = ", "
const  eq = " = "
const  bracketOpen = "("
const  bracketClose = ")"

public func to_string(input: Tokens): Tokens {
    // take the input and parse it as a class declaration
    let (inputDecl, classDecl) = parseClassDecl(input)
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
            $(inputDecl)
    )
    return result
}
