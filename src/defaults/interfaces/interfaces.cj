
package cj_lombok.defaults.interfaces

public interface Default<T> {
     static func default() : T
}

public func getDefaultValue<T>() : T where T <: Default<T> {
    return T.default()
}

