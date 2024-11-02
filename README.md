CJ_LOMBOK 基础代码生成器
=====================

仓颉编程语言 基础代码生成器。Java lombok 的仓颉实现

## 📦 安装

使用git方式进行引入，并使用 `cjpm update` 进行更新

（当仓颉包管理器完善时，将会推送到仓库使用版本安装）

```yaml
[dependencies]

cj_lombok = { git = "https://gitcode.com/niuhuan_cn/cj_lombok.git" }
```


## 📖 特性

| 宏定义 | 说明 |
| -- | -- |
| `ToSting` | 对class实现ToString接口，便于打印 |
| `AllArgsConstructor`| 生成一个构造器，包含所有的属性字段 |
| `Eq`| 生成 `public operator func ==`，使得类实例可以用等号比较 |
| `Serializable` | 对class实现Serializable接口, 方便与json转化 需要 `import serialization.serialization.*` , 如果加上 `AllArgsConstructor` 则会使用全属性构造器, 否则先使用无参数构造器, 然后依次赋值 |
| `Json` | 对class实现`toJsonString`和fromJsonString, 需要 `@Serializable` 以及 `import encoding.json.*` |


## 🔖 用例

完整代码参见 [lib_tests.cj](src/tests/lib_tests.cj)

运行单元测试 `cjpm test src/tests`


```cangjie
import cj_lombok.*
import serialization.serialization.*
import encoding.json.*

// 使用cj_lombok
@ToString
@AllArgsConstructor
@Eq
@Serializable[AllArgsConstructor]
@Json
public class TestModel {
    let a: Int64
    let b: Int64
}

// @ToString @AllArgsConstructor @Eq 的使用
func test() {
    let testInstanceA = TestModel(1,2)
    let testInstanceB = TestModel(1,3)
    let testInstanceC = TestModel(1,2)
    println("testInstance : ${testInstanceA}")
    @Assert(testInstanceA == testInstanceB, false)
    @Assert(testInstanceA == testInstanceC, true)
}

// @Serializable @Json 的使用
func serializationTest(): Unit {
    let testInstance = TestModel(1,2)
    let jsonString = testInstance.toJsonString()
    logger.trace("jsonObjectString : ${jsonString}")
    let deserialized = TestModel.fromJsonString(jsonString)
    @Assert(testInstance == deserialized, true)
}
```

## 🏆 贡献

欢迎您的issue和pull request, fork时请保留源仓库地址

#### 计划中的特性

- [ ] 避免用户import其他包
- [ ] `@ToString`: `@ToString(format=json)` 
- [ ] 序列化、反序列化对SNAKE_CASE的兼容


## 📕 协议

参考 [LICENSE](LICENSE) 文件

