///|
pub(all) enum BitType {
  Zero
  One
} derive(Eq)

///|
struct BitVector {
  mut len : Int
  data : Array[UInt]
}

///|
pub struct ByteVector {
  len : Int
  data : Array[Byte]
}
