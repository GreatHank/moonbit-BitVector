# BitVector: An Efficient Bit Vector Structure For Storing Boolean Values

---

[English-doc](./doc/introduction_EN.md) | [简体中文-文档](./doc/introduction_CN.md)

**BitVector** is an efficient bit vector structure for storing boolean values, supporting fast bitwise operations. Internally, it uses the `UInt` type, with each element storing 32 bits.

**Key Features**

- **Compressed Storage**: Utilizes `UInt` as the underlying structure to efficiently store boolean values using bit-level compression.

- **Bitwise Operations**: Provides a comprehensive set of bitwise manipulation methods, including logical `left/right shifts` and standard operations like `AND`, `OR`, `XOR`, and `NOT`.

- **Serialization Support**: Implements multiple serialization strategies, including `both head-aligned` and `tail-aligned` formats.

