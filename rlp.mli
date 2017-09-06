(** Rlp: Recursive Length Prefix format. **)

(** {2} RLP Trees *)

(** [t] is the type for RLP tree structures. *)
type t =
  RlpData of Rope.t
| RlpList of t list

(** [rlpInt i] encodes [i] into an [RlpData] element with big-endian with no zeros in front.  Zero is encoded as the empty byte sequence.
 *  Raises [Invalid_argument] when [i] is negative.
 *)
val rlpInt : int -> t

(** [rlpBigInt] is similar to [rlpInt]. **)
val rlpBigInt : Big_int.big_int -> t

(** [displayRope t] converts the RLP tree [t] into a JSON-like string (represented as a [Rope.t]). *)
val displayRope : t -> Rope.t

(** [displayRope t] converts the RLP tree [t] into a JSON-like string (represented as a [Rope.t]). *)
val display : t -> string

(** {2} Encoding and Decoding *)

(** [encode t] encodes the RLP tree structure into a byte string represented as a Rope.t *)
val encode : t -> Rope.t

exception InvalidRlp

(** [decode r] reads the given byte string into the RLP tree structure. Raises [InvalidRlp] when [r] is not a "canonical" encoding. [decode (encode t)] should be equal to [t] up to the Rope content equality. *)
val decode : Rope.t -> t
