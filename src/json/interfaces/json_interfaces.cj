package cj_lombok.json.interfaces

public interface JsonStringInterfaces<T> {
    func toJsonString(): String
    static func fromJsonString(json: String): T
}
