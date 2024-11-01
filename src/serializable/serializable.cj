package cj_lombok.serializable

import cj_lombok.commons.*
import std.ast.*
import std.collection.*

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
public func serializable(input: Tokens): Tokens {
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
    return result
}



