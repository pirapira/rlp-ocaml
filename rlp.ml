type t =
  RlpData of Rope.t
| RlpList of t list
