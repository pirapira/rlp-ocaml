type t =
  RlpData of Rope.t
| RlpList of t list

val encode : t -> Rope.t

exception InvalidRlp
val decode : Rope.t -> t
