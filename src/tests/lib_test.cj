package cj_lombok.tests

import std.unittest.*
import std.unittest.testmacro.*
import cj_lombok.*

@When[test]
@ToString
@AllArgsConstructor
@Eq
public class TestModel {
    let a: Int64
    let b: Int64
}


@When[test]
@Test
public class TestRunner{
    @TestCase
    func toStringTest(): Unit {
        let testInstance = TestModel(1,2)
        println("testInstance : ${testInstance}")
    }
    @TestCase
    func eqTest(): Unit {
        let testInstanceA = TestModel(1,2)
        let testInstanceB = TestModel(1,3)
        let testInstanceC = TestModel(1,2)
        @Assert(testInstanceA == testInstanceB, false)
        @Assert(testInstanceA == testInstanceC, true)
    }
}
