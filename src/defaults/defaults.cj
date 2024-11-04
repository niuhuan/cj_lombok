package cj_lombok.defaults

import cj_lombok.commons.*
import std.collection.*
import std.ast.*

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
                varDecl.expr = typeDefaultExpr(propType, input)
            }
        }
    }
    // add a default constructor
    classDecl.body.decls.append(FuncDecl(quote (
        public init() {
        }
    )))
    // implement the default macro
    classDecl.body.decls.append(FuncDecl(quote (
        public static func default() : $(classDecl.identifier) {
            $(inputDecl.identifier)()
        }
    )))
    // return
    let result = quote ( $inputDecl )
    result
}

public func typeDefaultExpr(propType: TypeNode, input: Tokens ) : Expr {
    if (propType is PrimitiveType) {
        let typeValue = (propType as PrimitiveType).getOrThrow().keyword.value
        if (numberTypes.contains(typeValue)) {
            return LitConstExpr( quote ( 0 ) )
        } else if (floatTypes.contains(typeValue)) {
            return LitConstExpr( quote ( 0.0 ) )
        } else if (typeValue == boolType) {
            return LitConstExpr( quote ( false ) )
        } else {
            diagReport(DiagReportLevel.ERROR, input[0..(0 + 1)], "macro error", "unsupported type: ${typeValue}")
            throw Exception("macro error")
        }
    } else if (propType is RefType) {
        let typeValue = (propType as RefType).getOrThrow().identifier.value
        // println("ref typeValue: ${quote($typeValue)}")
        if (typeValue == optionType) {
            return RefExpr( quote ( None ) )
        }
        else {
            return CallExpr( quote ( $(propType)() ) )
        }
    } else if (propType is TupleType) {
        let tupleType = (propType as TupleType).getOrThrow()
        let types = tupleType.types
        var tokens = quote ( \( )
        var first = true
        for (cType in types) {
            if (!first) {
                tokens += quote ( , )
            }
            tokens += quote ( $(typeDefaultExpr(cType, input)) )
            first = false
        }
        tokens += quote( \) )
        // println("tuple type: ${tokens}")
        return TupleLiteral( tokens )
    } else {
            diagReport(DiagReportLevel.ERROR, input[0..(0 + 1)], "macro error", "unsupported type: ${quote($propType)}")
            throw Exception("macro error")
    }
}
