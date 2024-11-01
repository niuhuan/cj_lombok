package cj_lombok.commons

import std.ast.*

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
