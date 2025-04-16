///|
enum BitType {
  Zero
  One
} derive(Eq)

///|
struct BitVector {
  mut len : Int
  data : Array[UInt]
}

///|
struct ByteVector {
  len : Int
  data : Array[Byte]
}
