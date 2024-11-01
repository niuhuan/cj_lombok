macro package cj_lombok

import cj_lombok.commons.*
import cj_lombok.to_string.*
import cj_lombok.all_args_constructor.*
import cj_lombok.eqs.*
import cj_lombok.serializable.*
public import cj_lombok.json.interfaces.*
import cj_lombok.json.macros.*

import std.ast.*
import std.collection.*

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
    serializable(input)
}

public macro Json(input: Tokens): Tokens {
    json(input)
}

