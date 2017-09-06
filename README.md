# rlp-ocaml
RLP serialization for OCaml

[RLP](https://github.com/ethereum/wiki/wiki/RLP) is a way to encode trees into a byte string.  The encoded trees are muti-way trees with byte strings as leaves.

Such a tree lives in a type `t`, and this library can encode such a tree into a byte string (represented by `Rope.t`).  The library provides `encode : t -> Rope.t` and `decode : Rope.t -> t`, where `decode(encode a)` should be equal to `a`.

## Example

```
# Rope.to_string Rlp.(encode (RlpList [RlpData (Rope.of_string "aa"); RlpList []]));;
- : string = "\196\130aa\192"
# Rlp.(display (decode (Rope.of_string "\196\130aa\192")));;
- : string = "[\"aa\", []]"
```
