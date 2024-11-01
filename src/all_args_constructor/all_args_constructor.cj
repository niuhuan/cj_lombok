package cj_lombok.all_args_constructor

import cj_lombok.commons.*
import std.ast.*
import std.collection.*

public func all_args_constructor(input: Tokens): Tokens {
    // take the input and parse it as a class declaration
    let (inputDecl, classDecl) = parseClassDecl(input)
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
            $(inputDecl)
    )
    return result
}
