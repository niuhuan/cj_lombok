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
    let (inputDecl, classDecl, structDecl, body) = parseClassOrStruct(input)
    // foreach var decl in the class declaration
    var toStringTokens = quote("")
    var first = true
    for (decl in body.decls){
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
    let identifierValue = if (let Some(classDecl) <- classDecl) {
        classDecl.identifier.value
    } else {
        structDecl.getOrThrow().identifier.value
    }
    toStringTokens = quote (
        public func toString(): String {
            return $identifierValue + $bracketOpen + $(toStringTokens) + $bracketClose
        }
    )
    body.decls.append(FuncDecl(toStringTokens))
    // add the ToString interface to the class declaration
    let superTypes = if (let Some(classDecl) <- classDecl) {
        classDecl.superTypes
    } else {
        structDecl.getOrThrow().superTypes
    }
    superTypes.append(RefType(quote( ToString )))
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
    else if (propType is RefType && (propType as RefType).getOrThrow().identifier.value == "Option") {
        let refType = (propType as RefType).getOrThrow()
        let pathTokens = quote ( this.$(propName) )
        return quote ( + $propNameValue + $eq + $(optionValue(pathTokens, refType)) )
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
            tupleValueTokens += quote ( + )
            let newPathTokens = quote ( $pathTokens[$(i)] )
            tupleValueTokens += toupleValue(newPathTokens, (cType as TupleType).getOrThrow())
        }
        else if (cType is RefType && (cType as RefType).getOrThrow().identifier.value == "Option") {
            tupleValueTokens += quote ( + )
            let newPathTokens = quote ( $pathTokens[$(i)] )
            tupleValueTokens += optionValue(newPathTokens, (cType as RefType).getOrThrow())
        }
        else {
            tupleValueTokens += quote ( + $pathTokens [$(i)].toString() )
        }
    }
    tupleValueTokens += quote ( + ")" )
    return tupleValueTokens
}

private func optionValue(pathTokens: Tokens, refType: RefType): Tokens {
    let cTypes = refType.typeArguments
    if (cTypes.size != 1) {
        throw Exception("Option type must have one type argument")
    }
    let newPathTokens = quote ( $pathTokens.getOrThrow() )
    var someTokens = quote ()
    let cType = cTypes[0]
    if (cType is TupleType) {
        someTokens += toupleValue(newPathTokens, (cType as TupleType).getOrThrow())
    } else if (cType is RefType && (cType as RefType).getOrThrow().identifier.value == "Option") {
        someTokens += optionValue(newPathTokens, (cType as RefType).getOrThrow())
    } else {
        someTokens += quote ( $(newPathTokens).toString() )
    }
    quote (
        if ( $(pathTokens).isSome() ) {
            "Some(" + $someTokens + ")"
        } else {
            "None"
        }
    )
}
