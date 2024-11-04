macro package cj_lombok

import cj_lombok.commons.*
import cj_lombok.to_string.*
import cj_lombok.all_args_constructor.*
import cj_lombok.eqs.*
import cj_lombok.defaults.*
import cj_lombok.serializable.*
public import cj_lombok.json.interfaces.*
import cj_lombok.json.macros.*

import std.ast.*
import std.collection.*

public import serialization.serialization.{
    Serializable,
    DataModel,
    DataModelStruct,
    field
}
public import encoding.json.{
    ToJson,
    JsonValue
}

public macro ToString(input: Tokens): Tokens {
    to_string(input)
}

public macro AllArgsConstructor(input: Tokens): Tokens {
    all_args_constructor(input)
}

public macro Eq(input: Tokens): Tokens {
    eqs(input)
}

public macro Serializable(input: Tokens): Tokens {
    serializable(input, false)
}

public macro Serializable(attr: Tokens, input: Tokens): Tokens {
    if (attr.size == 0) {
        return serializable(input, false)
    }
    if (attr.size > 1) {
        diagReport(DiagReportLevel.ERROR, input[0..(0 + 1)], "macro error", "attr only support AllArgsConstructor")
        throw Exception("macro error")
    }
    if (attr[0].value == "AllArgsConstructor") {
        return serializable(input, true)
    }
    diagReport(DiagReportLevel.ERROR, input[0..(0 + 1)], "macro error", "attr only support AllArgsConstructor")
    throw Exception("macro error")
}

public macro Json(input: Tokens): Tokens {
    json(input)
}

public macro Default(input: Tokens): Tokens {
    default(input)
}
