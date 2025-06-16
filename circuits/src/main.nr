use dep::keccak256;
// getting the doublehashed answer and double hashing the guess hash . To prevent user passing the answer_hash as a guess hash.
fn main(guess_hash: Field, answer_double_hash: pub Field, _address: pub Field) {
    let guess_bytes: [u8; 32] = guess_hash.to_be_bytes();
    let guess_double_hash = keccak256::keccak256(guess_bytes, 32);
    assert(Field::from_be_bytes(guess_double_hash) == answer_double_hash);
}
