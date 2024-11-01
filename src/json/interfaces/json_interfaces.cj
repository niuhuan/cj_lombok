package cj_lombok.json.interfaces

public interface JsonInterfaces<T> {
    func toJsonString(): String
    static func fromJsonString(json: String): T
}
