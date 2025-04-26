///|
test "slice" {
  let v = BitVector::new(100)
  v.set_all()
  v[50] = false
  let ve = v.slice(0, 99)
  inspect!(
    v,
    content="[1111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111]",
  )
  inspect!(v.length(), content="100")
  inspect!(
    ve,
    content="[1111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111]",
  )
  let byte = ve.serialization_back()
  inspect!(
    byte,
    content=
      #|b"\xff\xff\xff\xff\xff\xff\xdf\xff\xff\xff\xff\xff\xf0"
    ,
  )
  let vector = BitVector::deserialization(byte)
  inspect!(
    vector,
    content="[11111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111110000]",
  )
}

///|
test "combine" {
  let v1 = BitVector::new(68)
  let v2 = BitVector::new(32)
  let v3 = combine(v1, v2)
  v3.set_all()
  v3[50] = false
  inspect!(
    v3.to_string(),
    content="[1111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111]",
  )
}

///|
test {
  let vector = BitVector::new(15)
  vector.set_all()
  inspect!(vector.to_string(), content="[111111111111111]")
  let v1 = vector << 5
  inspect!(v1.to_string(), content="[111111111100000]")
  v1.push(false)
  v1.push(true)
  inspect!(v1.to_string(), content="[11111111110000001]")
}

///|
test "move" {
  let vector = BitVector::new(50)
  vector.set_all()
  inspect!(
    vector.to_string(),
    content="[11111111111111111111111111111111111111111111111111]",
  )
  let v1 = vector << 35
  inspect!(
    v1.to_string(),
    content="[11111111111111100000000000000000000000000000000000]",
  )
  let v2 = vector >> 35
  inspect!(
    v2.to_string(),
    content="[00000000000000000000000000000000000111111111111111]",
  )
  let v3 = and(vector, v2)
  inspect!(
    v3.to_string(),
    content="[00000000000000000000000000000000000111111111111111]",
  )
  let v4 = or(v1, v2)
  inspect!(v4, content="[11111111111111100000000000000000000111111111111111]")
  let v5 = not(v4)
  inspect!(v5, content="[00000000000000011111111111111111111000000000000000]")
  let num = set_number_count(vector)
  inspect!(num, content="50")
  inspect!(v5.find_first_set(), content="15")
  inspect!(v4.find_first_unset(), content="15")
}

///|
test "serialization" {
  let vector = BitVector::new(33)
  vector[32] = true
  let bool = vector.to_bool()
  let bytes_back = vector.serialization_back()
  let bytes_front = vector.serialization_front()
  inspect!(
    bool,
    content="[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true]",
  )
  inspect!(
    bytes_back,
    content=
      #|b"\x00\x00\x00\x00\x80"
    ,
  )
  inspect!(
    bytes_front,
    content=
      #|b"\x00\x00\x00\x00\x01"
    ,
  )
  let v1 = BitVector::deserialization(bytes_front)
  inspect!(v1, content="[0000000000000000000000000000000000000001]")
  let v2 = BitVector::deserialization(bytes_back)
  inspect!(v2, content="[0000000000000000000000000000000010000000]")
  let v3 = BitVector::bool_to_bitvector(bool)
  inspect!(v3, content="[000000000000000000000000000000001]")
}

///|
test "Iter" {
  let v1 = BitVector::new(33)
  for i in v1.iter() {
    inspect!(i, content="false")
  }
}
