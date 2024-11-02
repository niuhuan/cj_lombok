package cj_lombok.tests

import log.*
import std.unittest.*
import std.unittest.testmacro.*
import cj_lombok.*
import serialization.serialization.*
import encoding.json.*

@When[test]
@ToString
@AllArgsConstructor
@Eq
@Serializable[AllArgsConstructor]
@Json
public class TestModel {
    let a: Int64
    let b: Int64
}


@When[test]
@Test
public class TestRunner{
    let logger = getGlobalLogger(("name", "TestRunner"))
    @TestCase
    func toStringTest(): Unit {
        let testInstance = TestModel(1,2)
        logger.trace("testInstance : ${testInstance}")
    }
    @TestCase
    func eqTest(): Unit {
        let testInstanceA = TestModel(1,2)
        let testInstanceB = TestModel(1,3)
        let testInstanceC = TestModel(1,2)
        @Assert(testInstanceA == testInstanceB, false)
        @Assert(testInstanceA == testInstanceC, true)
    }
    @TestCase
    func serializationTest(): Unit {
        let testInstance = TestModel(1,2)
        let dm = testInstance.serialize()
        let jsonObject = dm.toJson().asObject()
        let jsonString = jsonObject.toJsonString()
        logger.trace("jsonObjectString : ${jsonString}")
        let jv: JsonValue = JsonValue.fromStr(jsonString)
        let jdm = DataModel.fromJson(jv)
        let deserialized = TestModel.deserialize(jdm)
        @Assert(testInstance == deserialized, true)
    }
    @TestCase
    func jsonTest(): Unit {
        let testInstance = TestModel(1,2)
        let jsonString = testInstance.toJsonString()
        logger.trace("jsonObjectString : ${jsonString}")
        let deserialized = TestModel.fromJsonString(jsonString)
        @Assert(testInstance == deserialized, true)
    }
}
