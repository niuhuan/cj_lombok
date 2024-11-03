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
        if (let Some(varDecl) <- decl as VarDecl) {
            if (!first) {
                toStringTokens += quote ( + $comma )
            } else {
                first = false
            }
            toStringTokens += varToString(varDecl)
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

private func varToString(varDecl: VarDecl): Tokens {
    let propName = varDecl.identifier
    let propType = varDecl.declType
    let propNameValue =  propName.value
    if (propType is TupleType) {
        var tupleType = (propType as TupleType).getOrThrow()
        let pathTokens = quote ( this.$(propName) )
        return quote ( + $propNameValue + $eq + $(toupleValue(pathTokens, tupleType)) )
    }
    quote ( + $propNameValue + $eq + this.$(propName).toString() )
}

private func toupleValue(pathTokens: Tokens, tupleType: TupleType): Tokens {
    var tupleValueTokens = quote ("(")
    var cTypes = tupleType.types
    for (i in 0..cTypes.size) {
        if (i > 0) {
            tupleValueTokens += quote ( + $comma )
        }
        let cType = cTypes[i]
        if (cType is TupleType) {
            let newPathTokens = quote ( $pathTokens[$(i)] )
            tupleValueTokens += quote ( + )
            tupleValueTokens += toupleValue(newPathTokens, (cType as TupleType).getOrThrow())
        } else {
            tupleValueTokens += quote ( + $pathTokens [$(i)].toString() )
        }
    }
    tupleValueTokens += quote ( + ")" )
    return tupleValueTokens
}
