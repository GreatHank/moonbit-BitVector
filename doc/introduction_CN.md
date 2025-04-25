# BitVector API 文档

## 简介

`BitVector` 是一种高效存储布尔值的位向量结构，支持快速的位操作。其内部使用 `UInt` 类型，每个元素存储 32 位。

---

## 构造与基本操作

### `BitVector::new(length : Int) -> BitVector`

创建指定长度的 BitVector，所有位默认初始化为 `false`。

---

### `length(self : BitVector) -> Int`

返回当前位向量的总长度（位数）。

---

### `copy(self : BitVector) -> BitVector`

返回当前 BitVector 的深拷贝，数据内容完全复制。

---

### `clear(self : BitVector) -> Unit`

将当前 BitVector 清空：长度设为 0，数据数组清除。

---

## 🧱 位访问与修改

直接通过
```
moonbit
let v1 = BitVector::new(20)
v1[2] = true
inspect!(v1[2], content = "true")
```

---

### `flip(self : BitVector, index : Int) -> Unit`

将指定位置上的位取反（1→0，0→1）。

---

### `push(self : BitVector, data : Bool) -> Unit`

向位向量末尾添加一个布尔值位。

---

## 🔍 查询操作

### `find_first_set(self : BitVector) -> Int`

查找第一个值为 `true` 的位并返回其下标。

---

### `find_first_unset(self : BitVector) -> Int`

查找第一个值为 `false` 的位并返回其下标。

---

### `set_number_count(self : BitVector) -> Int`

统计从末尾开始为 `true` 的位的数量。

---

### `unset_number_count(self : BitVector) -> Int`

统计从末尾开始为 `false` 的位的数量。

---

## 🧹 批量设置操作

### `set_all(self : BitVector) -> Unit`

将所有位设置为 `true`。

---

### `reset_all(self : BitVector) -> Unit`

将所有位设置为 `false`。

---

## 🧮 按位逻辑运算

### `and(self : BitVector, other : BitVector) -> BitVector`

按位与（AND）运算，返回新的 BitVector。

---

### `or(self : BitVector, other : BitVector) -> BitVector`

按位或（OR）运算。

---

### `xor(self : BitVector, other : BitVector) -> BitVector`

按位异或（XOR）运算。

---

### `not(self : BitVector) -> BitVector`

按位取反操作，将每一位进行取反。

---

## ⏩ 位移操作

### `op_shl(self : BitVector, size : Int) -> BitVector`

逻辑左移 `size` 位，移出的位丢弃，空位补零。

---

### `op_shr(self : BitVector, size : Int) -> BitVector`

逻辑右移 `size` 位。

---

## 🧩 切片与拼接

### `slice(self : BitVector, begin : Int, end : Int) -> BitVector`

从指定范围 `[begin, end)` 中截取新的 BitVector。

---

### `combine(self : BitVector, other : BitVector) -> BitVector`

将两个 BitVector 拼接为一个新向量。

---

## 🔁 转换与迭代

### `to_bool(self : BitVector) -> Array[Bool]`

将当前位向量转化为布尔数组。

---

### `bool_to_bitvector(self : Array[Bool]) -> BitVector`

从布尔数组构建 `BitVector` 。

---

### `iter(self : BitVector) -> Iter[Bool]`

返回迭代器，用于遍历 `BitVector` 的每一位，将其转化成`Iter[Bool]`

---

## 💾 序列化与反序列化

### `serialization_front(self : BitVector) -> Bytes`

以“尾部对齐”方式序列化为字节数组。

**注意**：这是会在前面进行**补0**操作。

---

### `serialization_back(self : BitVector) -> Bytes`

以“头部对齐”方式序列化为字节数组。

**注意**：这会在后面进行**补0**操作。

---

### `deserialization(self : Bytes) -> BitVector`

从字节数组反序列化出 BitVector。

---

## 🧾 显示与调试

以字符串形式输出位向量内容，如 `[010101]`。
