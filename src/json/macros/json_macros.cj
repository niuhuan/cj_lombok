package cj_lombok.json.macros


import cj_lombok.commons.*
import std.ast.*
import std.collection.*

/*
    func toJsonString() -> String
    static func fromJsonString(json: String) -> T
*/
public func json(input: Tokens): Tokens {
    // take the input and parse it as a class declaration
    let (inputDecl, classDecl) = parseClassDecl(input)
    let fromJsonStringTokens = quote (
        public static func fromJsonString(jsonString: String): $(classDecl.identifier) {
            let jv: JsonValue = JsonValue.fromStr(jsonString)
            let jdm = DataModel.fromJson(jv)
            $(classDecl.identifier).deserialize(jdm)
        }
    )
    let toJsonStringTokens = quote (
        public func toJsonString(): String {
            let dm = this.serialize()
            let jsonObject = dm.toJson().asObject()
            jsonObject.toJsonString()
        }
    )
    // add the Serializable interface to the class declaration 
    let classIdentifierValue = classDecl.identifier
    classDecl.superTypes.append(RefType(quote( JsonInterfaces < $(classIdentifierValue)  > )))
    // add the fromJsonStringTokens to the class declaration
    classDecl.body.decls.append(FuncDecl(fromJsonStringTokens))
    // add the toJsonStringTokens to the class declaration
    classDecl.body.decls.append(FuncDecl(toJsonStringTokens))
    // return the class declaration
    let result = quote (
            $(inputDecl)
    )
    return result
}
