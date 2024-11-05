package cj_lombok.commons

import std.ast.*
import std.collection.*

// 有符号整数类型包括 Int8、Int16、Int32、Int64 和 IntNative, 无符号整数类型包括 UInt8、UInt16、UInt32、UInt64 和 UIntNative，
public let numberTypes = HashSet(["Int8", "Int16", "Int32", "Int64", "IntNative", "UInt8", "UInt16", "UInt32", "UInt64", "UIntNative"])

// 浮点类型包括 Float16、 Float32 和 Float64
public let floatTypes = HashSet(["Float16", "Float32", "Float64"])

// 布尔类型使用 Bool 表示
public let boolType = "Bool"

// Option 类型使用 Option 表示
public let optionType = "Option"

// 获取类声明
public func parseClassDecl(input: Tokens): (Decl, ClassDecl) {
    let decl = parseDecl(input)
    var thisDecl = decl
    while(thisDecl is MacroExpandDecl) {
        thisDecl = (thisDecl as MacroExpandDecl).getOrThrow().macroInputDecl
    }
    if (decl is ClassDecl) {
        return (decl, (decl as ClassDecl).getOrThrow())
    }
    diagReport(DiagReportLevel.ERROR, input[0..(0 + 1)], "macro can only be applied to classes", "should be class")
    throw Exception("macro can only be applied to classes")
}

public let defaultInitDecl = 
    FuncDecl(quote (
        public init() {
        }
    ))
