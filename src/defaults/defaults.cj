package cj_lombok.defaults

import cj_lombok.commons.*
import std.collection.*
import std.ast.*

// 有符号整数类型包括 Int8、Int16、Int32、Int64 和 IntNative, 无符号整数类型包括 UInt8、UInt16、UInt32、UInt64 和 UIntNative，

public let numberTypes = HashSet(["Int8", "Int16", "Int32", "Int64", "IntNative", "UInt8", "UInt16", "UInt32", "UInt64", "UIntNative"])

// 浮点类型包括 Float16、 Float32 和 Float64

public let floatTypes = HashSet(["Float16", "Float32", "Float64"])

// 布尔类型使用 Bool 表示

public let boolType = "Bool"

// 字符串类型使用 String 表示

public let stringType = "String"

public func default(input: Tokens) {
    // take the input and parse it as a class declaration
    let (inputDecl, classDecl) = parseClassDecl(input)
    // foreach var decl in the class declaration
    for (decl in classDecl.body.decls){
        if (let Some(varDecl) <- decl as VarDecl) {
            let propType = varDecl.declType
            // println("=================")
            // println("${quote($varDecl)}")
            // println("propName: ${quote($propName)}")
            // println("propType: ${quote($propType)}")
            // println("${varDecl.assign.kind} ${quote($(varDecl.assign))}")
            // if (varDecl.assign.kind == ASSIGN) {
            //    println("expr: ${quote($(varDecl.expr))}")
            // }
            // println("=================")
            if (varDecl.assign.kind != ASSIGN) {
                varDecl.assign = quote ( = )[0]
                if (propType is PrimitiveType) {
                    let typeValue = (propType as PrimitiveType).getOrThrow().keyword.value
                    if (numberTypes.contains(typeValue)) {
                        varDecl.expr = LitConstExpr( quote ( 0 ) )
                    } else if (floatTypes.contains(typeValue)) {
                        varDecl.expr = LitConstExpr( quote ( 0.0 ) )
                    } else if (typeValue == boolType) {
                        varDecl.expr = LitConstExpr( quote ( false ) )
                    } else if (typeValue == stringType) {
                        varDecl.expr = LitConstExpr( quote ( "" ) )
                    }
                } else if (propType is RefType) {
                    let typeValue = (propType as RefType).getOrThrow().identifier.value
                    // println("ref typeValue: ${quote($typeValue)}")
                    if (typeValue == stringType) {
                        varDecl.expr = LitConstExpr( quote ( "" ) )
                    } else {
                        varDecl.expr = CallExpr( quote ( getDefaultValue<$(propType)>() ) )
                    }
                }
            }
        }
    }
    // add a default constructor
    classDecl.body.decls.append(FuncDecl(quote (
        public init() {
        }
    )))
    // implement the default macro
    classDecl.superTypes.append(RefType(quote ( Default<$(classDecl.identifier)> )))
    classDecl.body.decls.append(FuncDecl(quote (
        public static func default() : $(classDecl.identifier) {
            $(inputDecl.identifier)()
        }
    )))
    // return
    let result = quote ( $inputDecl )
    result
}
