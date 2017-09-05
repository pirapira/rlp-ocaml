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
    Rope.concat Rope.empty [encodeInt (183 + lenlen); encodedLen; rope]
and encodeList (lst : t list) : Rope.t =
  let body = Rope.concat Rope.empty (List.map encode lst) in
  let bodyLen = Rope.length body in
  if bodyLen < 56 then
    Rope.concat2 (immediateByte (192 + bodyLen)) body
  else
    let bodyLen = encodeInt bodyLen in
    let bodyLenLen = Rope.length bodyLen in
    Rope.concat Rope.empty [encodeInt (247 + bodyLenLen); bodyLen; body]

exception InvalidRlp

let rec decodeInt (r : Rope.t) : int =
  if Rope.is_empty r then 0 else
    256 * (Char.code (Rope.get r 0)) + decodeInt (Rope.sub r 1 (Rope.length r - 1))

let rec decodeObj (rope : Rope.t) : (t * Rope.t) =
  let len = Rope.length rope in
  if len = 0 then raise InvalidRlp
  else
    let firstChar = Char.code (Rope.get rope 0) in
    if firstChar < 128 then (RlpData (Rope.sub rope 0 1), Rope.sub rope 1 (len - 1))
    else if firstChar < 184 then
      let bodyLen = firstChar - 128 in
      (RlpData (Rope.sub rope 1 bodyLen), Rope.sub rope (1 + bodyLen) (len - 1 - bodyLen))
    else if firstChar < 192 then
      let bodyLenLen = firstChar - 183 in
      let bodyLen = decodeInt (Rope.sub rope 1 bodyLenLen) in
      (RlpData (Rope.sub rope (1 + bodyLenLen) bodyLen), Rope.sub rope (1 + bodyLenLen + bodyLen) (len - 1 - bodyLenLen - bodyLen))
    else if firstChar < 248 then
      let bodyLen = firstChar - 192 in
      (RlpList (decodeList (Rope.sub rope 1 bodyLen)), Rope.sub rope (1 + bodyLen) (len - 1 - bodyLen))
    else
      let bodyLenLen = firstChar - 247 in
      let bodyLen = decodeInt (Rope.sub rope 1 bodyLenLen) in
      (RlpList (decodeList (Rope.sub rope (1 + bodyLenLen) bodyLen)), Rope.sub rope (1 + bodyLenLen + bodyLen) (len - 1 - bodyLenLen - bodyLen))
and decodeList (rope : Rope.t) : t list =
  if Rope.is_empty rope then []
  else
    let (hd, rest) = decodeObj rope in
    hd :: decodeList rest

let decode (rope : Rope.t) : t =
  let (ret, rest) = decodeObj rope in
  if Rope.is_empty rest then
    ret
  else
    raise InvalidRlp
