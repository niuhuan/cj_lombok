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


public macro AllArgsConstructor(input: Tokens): Tokens {
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

public macro Eq(input: Tokens): Tokens {
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

/*
    public static func deserialize(dm: DataModel): B {
        let dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        B (
            Int64.deserialize(dms.get("a")),
            Int64.deserialize(dms.get("b")),
        )
    }

    public func serialize(): DataModel {
        DataModelStruct()
            .add(field<Int64>("a", this.a))
            .add(field<Int64>("b", this.b))
    }
*/
public macro Serializable(input: Tokens): Tokens {
    // take the input and parse it as a class declaration
    let (inputDecl, classDecl) = parseClassDecl(input)
    // foreach var decl in the class declaration
    var deserializeTokens = quote ()
    var serializeTokens = quote ()
    for (decl in classDecl.body.decls){
        if (let Some(varDecl) <- decl as VarDecl) {
            let varName = varDecl.identifier
            let varNameValue = varDecl.identifier.value
            let propType = varDecl.declType
            deserializeTokens += quote ( 
                $(propType).deserialize(dms.get($(varNameValue))),
            )
            serializeTokens += quote ( 
                .add(field<$(propType)>($(varNameValue), this.$(varName)))
            )
        }
    }
    deserializeTokens = quote (
        public static func deserialize(dm: DataModel): $(classDecl.identifier) {
            let dms = match (dm) {
                case data: DataModelStruct => data
                case _ => throw Exception("this data is not DataModelStruct")
            }
            $(classDecl.identifier) (
                $(deserializeTokens)
            )
        }
    )
    serializeTokens = quote (
        public func serialize(): DataModel {
            DataModelStruct()
                $(serializeTokens)
        }
    )
    // add the Serializable interface to the class declaration 
    let classIdentifierValue = classDecl.identifier
    classDecl.superTypes.append(RefType(quote( Serializable < $(classIdentifierValue)  > )))
    // add the deserializeTokens to the class declaration
    classDecl.body.decls.append(FuncDecl(deserializeTokens))
    // add the serializeTokens to the class declaration
    classDecl.body.decls.append(FuncDecl(serializeTokens))
    // return the class declaration
    let result = quote (
            $(inputDecl)
    )
    println("serialization result: ${result}")
    return result
}


private func parseClassDecl(input: Tokens): (Decl, ClassDecl) {
    let decl = parseDecl(input)
    var thisDecl = decl
    while(thisDecl is MacroExpandDecl) {
        println("thisDecl is MacroExpandDecl")
        thisDecl = (thisDecl as MacroExpandDecl).getOrThrow().macroInputDecl
    }
    if (decl is ClassDecl) {
        return (decl, (decl as ClassDecl).getOrThrow())
    }
    diagReport(DiagReportLevel.ERROR, input[0..(0 + 1)], "macro can only be applied to classes", "should be class")
    throw Exception("macro can only be applied to classes")
}