///|
test "slice" {
  let v = BitVector::new(100)
  v.set_all()
  v[50] = Zero
  let ve = v.slice(0, 99)
  inspect!(
    v.to_string(),
    content="[1111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111]",
  )
  inspect!(
    ve.to_string(),
    content="[1111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111]",
  )
  let byte = ve.serialization()
  inspect!(
    byte.data,
    content="[b'\\xFF', b'\\xFF', b'\\xFF', b'\\xFF', b'\\xFF', b'\\xFF', b'\\xDF', b'\\xFF', b'\\xFF', b'\\xFF', b'\\xFF', b'\\xFF', b'\\xF0']",
  )
  let vector = byte.deserialization()
  inspect!(
    vector.to_string(),
    content="[1111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111]",
  )
}

///|
test "combine" {
  let v1 = BitVector::new(68)
  let v2 = BitVector::new(32)
  let v3 = combine(v1, v2)
  v3.set_all()
  v3[50] = Zero
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
  v1.push(BitType::Zero)
  v1.push(BitType::One)
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
  inspect!(
    v4.to_string(),
    content="[11111111111111100000000000000000000111111111111111]",
  )
  let v5 = not(v4)
  inspect!(
    v5.to_string(),
    content="[00000000000000011111111111111111111000000000000000]",
  )
  let num = set_number_count(vector)
  inspect!(num, content="50")
  inspect!(v5.find_first_set(), content="15")
  inspect!(v4.find_first_unset(), content="15")
}
