macro package cj_lombok

import std.ast.*
import std.collection.*

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


public macro AllArgsConstructor(input: Tokens): Tokens {
    // take the input and parse it as a class declaration
    let decl = parseDecl(input)
    if (!(decl is ClassDecl)) {
        diagReport(DiagReportLevel.ERROR, input[0..(0 + 1)], "AllArgsConstructor macro can only be applied to classes", "should be class")
    }
    let classDecl = (decl as ClassDecl).getOrThrow()
    // identifier-type map
    // foreach var decl in the class declaration
    let map = ArrayList<(Token,  TypeNode)>()
    for (decl in classDecl.body.decls){
        if (let Some(propDecl) <- decl as VarDecl) {
            let propName = propDecl.identifier
            let propType = propDecl.declType
            map.append((propName, propType))
        }
    }
    // create the constructor
    var first = true
    var params = quote ()
    var assignmentes = quote ()
    for((propName, propType) in map) {
        if (!first) {
            params += quote ( , )
        } else {
            first = false
        }
        params += quote (  $propName : $propType )
        assignmentes += quote ( 
            this.$(propName) = $propName 
        )
    }
    let constructorTokens = quote (
        public init($params) {
            $assignmentes
        }
    )
    classDecl.body.decls.append(FuncDecl(constructorTokens))
    // return the class declaration
    let result = quote (
            $(classDecl)
    )
    return result
}

public macro Eq(input: Tokens): Tokens {
    // take the input and parse it as a class declaration
    let decl = parseDecl(input)
    if (!(decl is ClassDecl)) {
        diagReport(DiagReportLevel.ERROR, input[0..(0 + 1)], "Getter macro can only be applied to classes", "should be class")
    }
    let classDecl = (decl as ClassDecl).getOrThrow()
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
            $(classDecl)
    )
    return result
}