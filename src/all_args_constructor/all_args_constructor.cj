package cj_lombok.all_args_constructor

import cj_lombok.commons.*
import std.ast.*
import std.collection.*

public func all_args_constructor(input: Tokens): Tokens {
    // take the input and parse it as a class declaration
    let (inputDecl, _, body) = parseClassOrStructBody(input)
    // identifier-type map
    // foreach var decl in the class declaration
    var hasDefaultConstructor = false
    let map = ArrayList<(Token,  TypeNode)>()
    for (decl in body.decls){
        if (let Some(funcDecl) <- decl as FuncDecl) {
            if (funcDecl.identifier.value == "init") {
                if (funcDecl.funcParams.size == 0) {
                    hasDefaultConstructor = true
                }
            }
        }
        if (let Some(propDecl) <- decl as VarDecl) {
            let propName = propDecl.identifier
            let propType = propDecl.declType
            map.append((propName, propType))
        }
    }
    // if there are no properties, return the input
    if (map.size == 0) {
        if (!hasDefaultConstructor) {
            body.decls.append(defaultInitDecl)
        }
        let result = quote (
                $(inputDecl)
        )
        return result
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
    body.decls.append(FuncDecl(constructorTokens))
    // return the class declaration
    let result = quote (
            $(inputDecl)
    )
    return result
}
