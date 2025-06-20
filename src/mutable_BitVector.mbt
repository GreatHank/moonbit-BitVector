///|
pub fn BitVector::new(length : Int) -> BitVector {
  let array_size = (length + 31) / 32
  let zero : UInt = 0
  let data = Array::makei(array_size, fn { _ => zero })
  { len: length, data }
}

///|
pub fn BitVector::length(self : BitVector) -> Int {
  self.len
}

///|
pub fn BitVector::copy(self : BitVector) -> BitVector {
  { len: self.len, data: self.data.copy() }
}

///|
pub fn op_get(self : BitVector, index : Int) -> Bool {
  guard index >= 0 && index < self.len
  let one : UInt = 1
  let array_index = index / 32
  let bit_pos = 31 - index % 32
  let found = one << bit_pos
  if (self.data[array_index] & found) == 0 {
    false
  } else {
    true
  }
}

///|
pub fn clear(self : BitVector) -> Unit {
  self.len = 0
  self.data.clear()
}

///|
pub fn op_set(self : BitVector, index : Int, value : Bool) -> Unit {
  guard index >= 0 && index < self.len
  let one : UInt = 1
  let array_index = index / 32
  let bit_pos = 31 - index % 32
  let found = one << bit_pos
  match value {
    true => self.data[array_index] = self.data[array_index] | found
    false => {
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
pub fn push(self : BitVector, data : Bool) -> Unit {
  let pre_index = (self.len + 31) / 32
  self.len += 1
  let bit_index = (self.len + 31) / 32
  let bit_rest = self.len % 32
  if bit_index != pre_index {
    self.data.push(0)
  }
  match data {
    false => return
    true => {
      let one : UInt = 1
      let num = one << (32 - bit_rest)
      self.data[bit_index - 1] = self.data[bit_index - 1] | num
    }
  }
}

///|
pub impl Show for BitVector with to_string(self) {
  let mut result = "["
  for i = 0; i < self.len; i = i + 1 {
    match self[i] {
      false => result = result + "0"
      true => result = result + "1"
    }
  }
  result + "]"
}

///|
pub impl Show for BitVector with output(s, l) {
  l.write_string(s.to_string())
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
    true, 0, sum => return sum + 1
    false, 0, sum => return sum
    true, i, sum => continue self[self.len - 1 - i], i - 1, sum + 1
    false, i, sum => continue self[self.len - 1 - i], i - 1, sum
  }
}

///|
pub fn unset_number_count(self : BitVector) -> Int {
  if self.len == 0 {
    return 0
  }
  loop self[0], self.len - 1, 0 {
    false, 0, sum => return sum + 1
    true, 0, sum => return sum
    false, i, sum => continue self[self.len - 1 - i], i - 1, sum + 1
    true, i, sum => continue self[self.len - 1 - i], i - 1, sum
  }
}

///|
pub fn find_first_set(self : BitVector) -> Int {
  guard self.len != 0
  loop self[0], 0 {
    true, i => return i
    false, i => continue self[i + 1], i + 1
  }
}

///|
pub fn find_first_unset(self : BitVector) -> Int {
  guard self.len != 0
  loop self[0], 0 {
    false, i => return i
    true, i => continue self[i + 1], i + 1
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
pub fn BitVector::to_bool(self : BitVector) -> Array[Bool] {
  let size = self.len
  let array_bool = Array::makei(size, fn(_) { false })
  for i in 0..<size {
    match self[i] {
      false => array_bool[i] = false
      true => array_bool[i] = true
    }
  }
  array_bool
}

///|
pub fn BitVector::bool_to_bitvector(self : Array[Bool]) -> BitVector {
  let size = self.length()
  let bit_array = BitVector::new(size)
  for index, i in self {
    match i {
      true => bit_array[index] = true
      false => bit_array[index] = false
    }
  }
  bit_array
}

///|
/// The iter method converts a `BitVector` into an iterator of
/// type `Iter[Bool]`.
pub fn BitVector::iter(self : BitVector) -> Iter[Bool] {
  Iter::new(fn(yield_) {
    let len = self.len
    let mut count = 0
    outer~: for x in self.data {
      for i in 0..<32 {
        let num : UInt = 1
        let target = x & num
        let bool = target != 0
        guard count < len && yield_(bool) is IterContinue else {
          break outer~ IterEnd
        }
        count += 1
      }
    } else {
      IterContinue
    }
  })
}

///|
/// Serialization means change the type `BitVector` to the type `Bytes`.
/// What's more, the size of `Bytes` is 8 so the length of `BitVector`
/// should be extended to a multiple of 8.
/// 
/// **Attention** :
/// In this method, the zero-padding should be applied at the beginning.
/// 
/// **Example**:
/// ```
/// moonbit
/// let vector = BitVector::new(33)
/// let bytes_front = vector.serialization_front()
/// inspect!(bytes_front, content = b"\x00\x00\x00\x00\x01")
/// ```
pub fn BitVector::serialization_front(self : BitVector) -> Bytes {
  let byte_size = (self.len + 7) / 8
  let byte_rest = self.len % 8
  let byte_array = Array::makei(byte_size, fn { _ => b'\x00' })
  let fir = self.data[0] >> (32 - byte_rest)
  byte_array[0] = (fir | 0).to_byte()
  for i in 1..<byte_size {
    if i % 4 == 0 {
      let max : UInt = 4294967295
      let middle = max >> (24 + byte_rest)
      let pre = self.data[i / 4 - 1] & middle
      let now = self.data[i / 4] >> (32 - byte_rest)
      let num = pre | now
      byte_array[i] = num.to_byte()
    } else {
      let num = self.data[i / 4] >> ((3 - i % 4) * 8 + byte_rest)
      byte_array[i] = num.to_byte()
    }
  }
  @bytes.from_array(byte_array)
}

///|
/// Serialization means change the type `BitVector` to the type `Bytes`.
/// What's more, the size of `Bytes` is 8 so the length of `BitVector`
/// should be extended to a multiple of 8.
/// 
/// **Attention** :
/// In this method, the `BitVector` will pad with zero at the end.
/// 
/// **Example** :
/// ```
/// moonbit
/// let vector = BitVector::new(33)
/// let bytes_back = vector.serialization_back()
/// inspect!(bytes_back, content= b"\x00\x00\x00\x00\x80")
/// ```
pub fn BitVector::serialization_back(self : BitVector) -> Bytes {
  let byte_size = (self.len + 7) / 8
  let byte_array = Array::makei(byte_size, fn { _ => b'\x00' })
  for i in 0..<byte_size {
    let num = self.data[i / 4] >> ((3 - i % 4) * 8)
    byte_array[i] = num.to_byte()
  }
  @bytes.from_array(byte_array)
}

///|
/// Deserialization means change a `Bytes` type to `BitVector`.
/// 
/// **Attention**: This method might change the length of your `BitVector`.
/// It depends the definition of your choice of the `serialization`.
/// 
/// **Example**:
/// ```
/// moonbit
/// let vector = BitVector::new(33)
/// let bytes_back = vector.serialization_back()
/// let bytes_front = vector.serialization_front()
/// let v1 = BitVector::deserialization(bytes_front)
/// inspect!(v1, content="[0000000000000000000000000000000000000001]")
/// let v2 = BitVector::deserialization(bytes_back)
/// inspect!(v2, content="[0000000000000000000000000000000010000000]")
/// ```
pub fn BitVector::deserialization(self : Bytes) -> BitVector {
  let len = self.length() * 8
  let vector = BitVector::new(len)
  let bit_size = (len + 31) / 32
  let byte_size = (len + 7) / 8
  for i in 0..<bit_size {
    for j in 0..<4 {
      if 4 * i + j < byte_size {
        let num = self[4 * i + j].to_uint() << ((3 - j) * 8)
        vector.data[i] = vector.data[i] | num
      } else {
        break
      }
    }
  }
  vector
}
