///|
pub fn BitVector::new(length : Int) -> BitVector {
  let array_size = (length + 31) / 32
  let zero : UInt = 0
  let data = Array::makei(array_size, fn { _ => zero })
  { len: length, data }
}

///|
pub fn copy(self : BitVector) -> BitVector {
  { len: self.len, data: self.data.copy() }
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
pub fn push(self : BitVector, data : BitType) -> Unit {
  let pre_index = (self.len + 31) / 32
  self.len += 1
  let bit_index = (self.len + 31) / 32
  let bit_rest = self.len % 32
  if bit_index != pre_index {
    self.data.push(0)
  }
  match data {
    Zero => return
    One => {
      let one : UInt = 1
      let num = one << (32 - bit_rest)
      self.data[bit_index - 1] = self.data[bit_index - 1] | num
    }
  }
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
pub fn op_shl(self : BitVector, size : Int) -> BitVector {
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
pub fn op_shr(self : BitVector, size : Int) -> BitVector {
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
    return (self, short >> derta)
  } else {
    let derta = other.len - self.len
    let short = self.copy()
    short.len = self.len
    return (other, short >> derta)
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
pub fn set_number_count(self : BitVector) -> Int {
  if self.len == 0 {
    return 0
  }
  loop self[0], self.len - 1, 0 {
    One, 0, sum => return sum + 1
    Zero, 0, sum => return sum
    One, i, sum => continue self[self.len - 1 - i], i - 1, sum + 1
    Zero, i, sum => continue self[self.len - 1 - i], i - 1, sum
  }
}

///|
pub fn unset_number_count(self : BitVector) -> Int {
  if self.len == 0 {
    return 0
  }
  loop self[0], self.len - 1, 0 {
    Zero, 0, sum => return sum + 1
    One, 0, sum => return sum
    Zero, i, sum => continue self[self.len - 1 - i], i - 1, sum + 1
    One, i, sum => continue self[self.len - 1 - i], i - 1, sum
  }
}

///|
pub fn find_first_set(self : BitVector) -> Int {
  guard self.len != 0
  loop self[0], 0 {
    One, i => return i
    Zero, i => continue self[i + 1], i + 1
  }
}

///|
pub fn find_first_unset(self : BitVector) -> Int {
  guard self.len != 0
  loop self[0], 0 {
    Zero, i => return i
    One, i => continue self[i + 1], i + 1
  }
}

///|
pub fn slice(self : BitVector, begin : Int, end : Int) -> BitVector {
  guard begin >= 0 && end <= self.len
  let v = self << begin
  let new_v = BitVector::new(end - begin + 1)
  let new_index = (end - begin + 32) / 32
  for i in 0..<new_index {
    new_v.data[i] = v.data[i]
  }
  new_v
}

///|
pub fn combine(self : BitVector, other : BitVector) -> BitVector {
  let size = self.len + other.len
  let new_v = BitVector::new(size)
  let num = (size + 31) / 32
  let self_index = (self.len + 31) / 32
  let self_rest = self.len % 32
  if self_rest == 0 {
    for i in 0..<num {
      if i < self_index {
        new_v.data[i] = self.data[i]
      } else {
        new_v.data[i] = other.data[i - self_index]
      }
    }
  } else {
    for i in 0..<num {
      if i < self_index {
        new_v.data[i] = self.data[i]
      } else if i == self_index {
        let m = other.data[0] << (32 - self_rest)
        new_v.data[i] = new_v.data[i] | m
      } else {
        let current = new_v.data[i] << (32 - self_rest)
        let front = new_v.data[i - 1] >> self_rest
        new_v.data[i] = current | front
      }
    }
  }
  new_v
}

///|
pub fn serialization(self : BitVector) -> ByteVector {
  let byte_size = (self.len + 7) / 8
  let byte_array = Array::makei(byte_size, fn { _ => b'\x00' })
  for i in 0..<byte_size {
    let num = self.data[i / 4] >> ((3 - i % 4) * 8)
    byte_array[i] = num.to_byte()
  }
  { len: self.len, data: byte_array }
}

///|
pub fn deserialization(self : ByteVector) -> BitVector {
  let vector = BitVector::new(self.len)
  let bit_size = (self.len + 31) / 32
  let byte_size = (self.len + 7) / 8
  for i in 0..<bit_size {
    for j in 0..<4 {
      if 4 * i + j < byte_size {
        let num = self.data[4 * i + j].to_uint() << ((3 - j) * 8)
        vector.data[i] = vector.data[i] | num
      } else {
        break
      }
    }
  }
  vector
}
