type t =
  RlpData of Rope.t
| RlpList of t list

let immediateByte (i : int) : Rope.t =
  let () = assert (0 <= i) in
  let () = assert (i < 256) in
  Rope.of_char (Char.chr i)

let rec encodeInt (i : int) : Rope.t =
  let () = assert (i >= 0) in
  if i = 0 then Rope.empty else
    Rope.(concat2 (encodeInt (i / 256)) (immediateByte (i mod 256)))

let rec encodeBigInt (i : Big_int.big_int) : Rope.t =
  let () = assert (Big_int.sign_big_int i >= 0) in
  if Big_int.(eq_big_int zero_big_int i) then Rope.empty else
    let modulo = Big_int.big_int_of_int 256 in
    Rope.(concat2 (encodeBigInt (Big_int.div_big_int i modulo)) (immediateByte (Big_int.(int_of_big_int (mod_big_int i modulo)))))

let rlpInt (i : int) : t =
  if i < 0 then raise (Invalid_argument "rlpInt: negative input.") else
    RlpData (encodeInt i)

let rlpBigInt (i : Big_int.big_int) : t =
  if Big_int.sign_big_int i < 0 then raise (Invalid_argument "rlpBigInt: negative input.") else
    RlpData (encodeBigInt i)

let rec encode (obj : t) : Rope.t =
  match obj with
  | RlpData rope -> encodeRope rope
  | RlpList lst -> encodeList lst
and encodeRope (rope : Rope.t) : Rope.t =
  let len = Rope.length rope in
  if len = 1 && Char.code(Rope.get rope 0) < 128 then rope
  else if len < 56 then
    Rope.concat2 (immediateByte (128 + len)) rope
  else
    let encodedLen = encodeInt len in
    let lenlen = Rope.length encodedLen in
    Rope.concat Rope.empty [immediateByte (183 + lenlen); encodedLen; rope]
and encodeList (lst : t list) : Rope.t =
  let body = Rope.concat Rope.empty (List.map encode lst) in
  let bodyLen = Rope.length body in
  if bodyLen < 56 then
    Rope.concat2 (immediateByte (192 + bodyLen)) body
  else
    let bodyLen = encodeInt bodyLen in
    let bodyLenLen = Rope.length bodyLen in
    Rope.concat Rope.empty [immediateByte (247 + bodyLenLen); bodyLen; body]

exception InvalidRlp

let rec decodeInt (r : Rope.t) : int =
  if Rope.is_empty r then 0 else
    256 * decodeInt (Rope.sub r 0 (Rope.length r - 1)) + Char.code (Rope.get r (Rope.length r - 1))

let rec decodeObj (rope : Rope.t) : (t * Rope.t) =
  let len = Rope.length rope in
  if len = 0 then raise InvalidRlp
  else
    let firstChar = Char.code (Rope.get rope 0) in
    if firstChar < 128 then (RlpData (Rope.sub rope 0 1), Rope.sub rope 1 (len - 1))
    else if firstChar < 184 then
      let bodyLen = firstChar - 128 in
      let ret = Rope.sub rope 1 bodyLen in
      (if bodyLen = 1 && Char.code(Rope.get ret 0) < 128 then raise InvalidRlp else
         (RlpData ret, Rope.sub rope (1 + bodyLen) (len - 1 - bodyLen)))
    else if firstChar < 192 then
      let bodyLenLen = firstChar - 183 in
      let bodyLen = decodeInt (Rope.sub rope 1 bodyLenLen) in
      (if bodyLen < 56 then raise InvalidRlp else
         (RlpData (Rope.sub rope (1 + bodyLenLen) bodyLen), Rope.sub rope (1 + bodyLenLen + bodyLen) (len - 1 - bodyLenLen - bodyLen)))
    else if firstChar < 248 then
      let bodyLen = firstChar - 192 in
      (RlpList (decodeList (Rope.sub rope 1 bodyLen)), Rope.sub rope (1 + bodyLen) (len - 1 - bodyLen))
    else
      let bodyLenLen = firstChar - 247 in
      let bodyLen = decodeInt (Rope.sub rope 1 bodyLenLen) in
      (if bodyLen < 56 then raise InvalidRlp else
         (RlpList (decodeList (Rope.sub rope (1 + bodyLenLen) bodyLen)),
          Rope.sub rope (1 + bodyLenLen + bodyLen) (len - 1 - bodyLenLen - bodyLen)))
and decodeList (rope : Rope.t) : t list =
  decodeListInner [] rope
and decodeListInner revAcc rope : t list =
  if Rope.is_empty rope then List.rev revAcc
  else
    let (hd, rest) = decodeObj rope in
    decodeListInner (hd :: revAcc) rest

let decode (rope : Rope.t) : t =
   try
    let (ret, rest) = decodeObj rope in
    if Rope.is_empty rest then
      ret
    else
      raise InvalidRlp
 with Invalid_argument _ -> (* expected from Rope.sub *)
    raise InvalidRlp
