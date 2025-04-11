///|
pub fn BitVector::new(length : Int) -> BitVector {
  let array_size = (length + 31) / 32
  let zero : UInt = 0
  let data = Array::makei(array_size, fn { _ => zero })
  { len: length, data }
}

///|
pub fn copy(self : BitVector) -> BitVector {
  { len: self.len, data: self.data }
}

///|
pub fn op_get(self : BitVector, index : Int) -> BitType {
  guard index >= 0 && index < self.len
  let one : UInt = 1
  let array_index = index / 32
  let bit_pos = 31 - index % 32
  let found = one << bit_pos
  if (self.data[array_index] & found) == 0 {
    Zero
  } else {
    One
  }
}

///|
pub fn clear(self : BitVector) -> Unit {
  self.len = 0
  self.data.clear()
}

///|
pub fn op_set(self : BitVector, index : Int, value : BitType) -> Unit {
  guard index >= 0 && index < self.len
  let one : UInt = 1
  let array_index = index / 32
  let bit_pos = 31 - index % 32
  let found = one << bit_pos
  match value {
    One => self.data[array_index] = self.data[array_index] | found
    Zero => {
      let max : UInt = 4294967295
      self.data[array_index] = self.data[array_index] & (max ^ found)
    }
  }
}

///|
pub fn flip(self : BitVector, index : Int) -> Unit {
  guard index >= 0 && index < self.len
  let one : UInt = 1
  let array_index = index / 32
  let bit_pos = 31 - index % 32
  let found = one << bit_pos
  self.data[array_index] = self.data[array_index] ^ found
}

///|
pub fn to_string(self : BitVector) -> String {
  let mut result = "["
  for i = 0; i < self.len; i = i + 1 {
    match self[i] {
      Zero => result = result + "0"
      One => result = result + "1"
    }
  }
  result + "]"
}

///|
pub fn set_all(self : BitVector) -> Unit {
  let max : UInt = 4294967295
  let array_index = (self.len + 31) / 32
  for i in 0..<(array_index - 1) {
    self.data[i] = max
  }
  let bit_pos = self.len % 32
  if bit_pos == 0 {
    self.data[array_index - 1] = max
  } else {
    self.data[array_index - 1] = max << (32 - bit_pos)
  }
}

///|
pub fn reset_all(self : BitVector) -> Unit {
  let array_index = self.len / 32
  for i in 0..=array_index {
    self.data[i] = 0
  }
}

///|
pub fn move_left(self : BitVector, size : Int) -> BitVector {
  let new_vector = BitVector::new(self.len)
  if size >= self.len {
    new_vector.reset_all()
    return new_vector
  }
  let move_block = size / 32
  let move_inner = size % 32
  let array_index = (self.len + 31) / 32
  let array_rest = self.len % 32
  // block movement
  for i in 0..<array_index {
    if i - array_index + move_block < 0 {
      new_vector.data[i] = self.data[i + move_block]
    } else {
      new_vector.data[i] = 0
    }
  }
  // inner movement
  if move_inner > 0 {
    for i in 0..<(array_index - 1) {
      let current = new_vector.data[i] << move_inner
      let next = new_vector.data[i + 1] >> (32 - move_inner)
      new_vector.data[i] = current | next
    }
    new_vector.data[array_index - 1] = new_vector.data[array_index - 1] <<
      move_inner
  }
  // delete
  if array_rest != 0 {
    let max : UInt = 4294967295
    let mask = max << (32 - array_rest)
    new_vector.data[array_index - 1] = new_vector.data[array_index - 1] & mask
  }
  new_vector
}

///|
/// move right needs to delete all the elements that moved out of your lens
pub fn move_right(self : BitVector, size : Int) -> BitVector {
  let new_vector = BitVector::new(self.len)
  if size >= self.len {
    new_vector.reset_all()
    return new_vector
  }
  let move_block = size / 32
  let move_inner = size % 32
  let array_index = (self.len + 31) / 32
  let array_rest = self.len % 32
  // block movement
  for i in 0..<move_block {
    new_vector.data[i] = 0
  }
  for i in move_block..<array_index {
    new_vector.data[i] = self.data[i - move_block]
  }
  // inner movement
  if move_inner > 0 {
    // as for array_index - 1
    let max : UInt = 4294967295
    let current = new_vector.data[array_index - 1] >> move_inner
    let next = new_vector.data[array_index - 2] << (32 - move_inner)
    let mask = max << (32 - array_rest)
    new_vector.data[array_index - 1] = (current | next) & mask
    for i = array_index - 2; i >= move_block; i = i - 1 {
      let current = new_vector.data[i] >> move_inner
      let next = new_vector.data[i - 1] << (32 - move_inner)
      new_vector.data[i] = current | next
    }
  }
  new_vector
}

///|
fn meet_two_vector(
  self : BitVector,
  other : BitVector
) -> (BitVector, BitVector) {
  if self.len == other.len {
    return (self, other)
  } else if self.len > other.len {
    let derta = self.len - other.len
    let short = other.copy()
    short.len = self.len
    return (self, short.move_right(derta))
  } else {
    let derta = other.len - self.len
    let short = self.copy()
    short.len = self.len
    return (other, short.move_right(derta))
  }
}

///|
pub fn and(self : BitVector, other : BitVector) -> BitVector {
  let ans = BitVector::new(@math.maximum(self.len, other.len))
  let (long, short) = meet_two_vector(self, other)
  let array_index = (long.len + 31) / 32
  for i in 0..<array_index {
    ans.data[i] = long.data[i] & short.data[i]
  }
  ans
}

///|
pub fn or(self : BitVector, other : BitVector) -> BitVector {
  let ans = BitVector::new(@math.maximum(self.len, other.len))
  let (long, short) = meet_two_vector(self, other)
  let array_index = (long.len + 31) / 32
  for i in 0..<array_index {
    ans.data[i] = long.data[i] | short.data[i]
  }
  ans
}

///|
pub fn xor(self : BitVector, other : BitVector) -> BitVector {
  let ans = BitVector::new(@math.maximum(self.len, other.len))
  let (long, short) = meet_two_vector(self, other)
  let array_index = (long.len + 31) / 32
  for i in 0..<array_index {
    ans.data[i] = long.data[i] ^ short.data[i]
  }
  ans
}

///|
pub fn not(self : BitVector) -> BitVector {
  let max : UInt = 4294967295
  let new_vector = BitVector::new(self.len)
  let array_index = (self.len + 31) / 32
  let array_rest = self.len % 32
  for i in 0..<(array_index - 1) {
    new_vector.data[i] = self.data[i] ^ max
  }
  let move_num = max << (32 - array_rest)
  new_vector.data[array_index - 1] = self.data[array_index - 1] ^ move_num
  new_vector
}

///|
test {
  let vector = BitVector::new(15)
  vector.set_all()
  inspect!(vector.to_string(), content="[111111111111111]")
  let v1 = vector.move_left(5)
  inspect!(v1.to_string(), content="[111111111100000]")
}

///|
test "move" {
  let vector = BitVector::new(50)
  vector.set_all()
  inspect!(
    vector.to_string(),
    content="[11111111111111111111111111111111111111111111111111]",
  )
  let v1 = vector.move_left(35)
  inspect!(
    v1.to_string(),
    content="[11111111111111100000000000000000000000000000000000]",
  )
  let v2 = vector.move_right(35)
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
  inspect!(v5.to_string(),content="[00000000000000011111111111111111111000000000000000]")
}
