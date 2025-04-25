# BitVector API Documentation

## Introduction

`BitVector` is an efficient bit vector structure for storing boolean values, supporting fast bitwise operations. Internally, it uses the `UInt` type, with each element storing 32 bits.

---

## Construction and Basic Operations

### `BitVector::new(length : Int) -> BitVector`

Creates a `BitVector` of the specified length, initializing all bits to `false`.

---

### `length(self : BitVector) -> Int`

Returns the total length (number of bits) of the `BitVector`.

---

### `copy(self : BitVector) -> BitVector`

Returns a deep copy of the current `BitVector`, duplicating all data.

---

### `clear(self : BitVector) -> Unit`

Clears the current `BitVector`: sets its length to 0 and clears the data array.

---

## 🧱 Bit Access and Modification

Direct usage:
```
moonbit
let v1 = BitVector::new(20)
v1[2] = true
inspect!(v1[2], content = "true")
```

---
### `flip(self : BitVector, index : Int) -> Unit`

Flips the bit at the specified index (1 → 0, 0 → 1).

---

### `push(self : BitVector, data : Bool) -> Unit`

Appends a boolean value to the end of the `BitVector`.

---

## 🔍 Query Operations

### `find_first_set(self : BitVector) -> Int`

Finds and returns the index of the first `true` bit.

---

### `find_first_unset(self : BitVector) -> Int`

Finds and returns the index of the first `false` bit.

---

### `set_number_count(self : BitVector) -> Int`

Counts the number of `true` bits from the end.

---

### `unset_number_count(self : BitVector) -> Int`

Counts the number of `false` bits from the end.

---

## 🧹 Batch Setting Operations

### `set_all(self : BitVector) -> Unit`

Sets all bits to `true`.

---

### `reset_all(self : BitVector) -> Unit`

Sets all bits to `false`.

---

## 🧮 Bitwise Logic Operations

### `and(self : BitVector, other : BitVector) -> BitVector`

Performs bitwise AND and returns a new `BitVector`.

---

### `or(self : BitVector, other : BitVector) -> BitVector`

Performs bitwise OR.

---

### `xor(self : BitVector, other : BitVector) -> BitVector`

Performs bitwise XOR.

---

### `not(self : BitVector) -> BitVector`

Performs bitwise NOT on each bit.

---

## ⏩ Shift Operations

### `op_shl(self : BitVector, size : Int) -> BitVector`

Logical left shift by `size` bits. Shifted-out bits are discarded, and zeros are padded at the end.

---

### `op_shr(self : BitVector, size : Int) -> BitVector`

Logical right shift by `size` bits.

---

## 🧩 Slicing and Concatenation

### `slice(self : BitVector, begin : Int, end : Int) -> BitVector`

Extracts a new `BitVector` from the specified range `[begin, end)`.

---

### `combine(self : BitVector, other : BitVector) -> BitVector`

Concatenates two `BitVector`s into a new vector.

---

## 🔁 Conversion and Iteration

### `to_bool(self : BitVector) -> Array[Bool]`

Converts the current `BitVector` into a boolean array.

---

### `bool_to_bitvector(self : Array[Bool]) -> BitVector`

Builds a `BitVector` from a boolean array.

---

### `iter(self : BitVector) -> Iter[Bool]`

Returns an iterator to traverse each bit in the `BitVector`, producing an `Iter[Bool]`.

---

## 💾 Serialization and Deserialization

### `serialization_front(self : BitVector) -> Bytes`

Serializes the `BitVector` into a byte array using **tail alignment**.

**Note:** Zero-padding is applied **at the beginning**.

---

### `serialization_back(self : BitVector) -> Bytes`

Serializes the `BitVector` into a byte array using **head alignment**.

**Note:** Zero-padding is applied **at the end**.

---

### `deserialization(self : Bytes) -> BitVector`

Deserializes a `BitVector` from a byte array.

---

## 🧾 Display and Debugging

Outputs the `BitVector` as a string, such as `[010101]`.