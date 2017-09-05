open OUnit2
open Rlp

let decodeEncodeTest (r : Rlp.t) =
  assert_equal r (Rlp.(decode (encode r)))

let empty test_ctxt =
  decodeEncodeTest (RlpData Rope.empty)

let invalidDecodeTest (r : Rope.t) =
  assert_raises Rlp.InvalidRlp (fun () -> decode r)

(* from pyrlp *)
let invalid0 = Rope.of_string ""
let invalid1 = Rope.of_string "\x00\xab"
let invalid2 = Rope.of_string "\x00\x00\xff"
let invalid3 = Rope.of_string "\x83dogcat"
let invalid4 = Rope.of_string "\x83do"
let invalid5 = Rope.of_string "\xc7\xc0\xc1\xc0\xc3\xc0\xc1\xc0\xff"
let invalid6 = Rope.of_string "\xc7\xc0\xc1\xc0\xc3\xc0\xc1"
let invalid7 = Rope.of_string "\x81\x02"
let invalid8 = Rope.of_string "\xb8\x00"
let invalid9 = Rope.of_string "\xb9\x00\x00"
let invalid10 = Rope.of_string "\xba\x00\x02\xff\xff"
let invalid11 = Rope.of_string "\x81\x54"

let invalid0Test test_ctxt = invalidDecodeTest invalid0
let invalid1Test test_ctxt = invalidDecodeTest invalid1
let invalid2Test test_ctxt = invalidDecodeTest invalid2
let invalid3Test test_ctxt = invalidDecodeTest invalid3
let invalid4Test test_ctxt = invalidDecodeTest invalid4
let invalid5Test test_ctxt = invalidDecodeTest invalid5
let invalid6Test test_ctxt = invalidDecodeTest invalid6
let invalid7Test test_ctxt = invalidDecodeTest invalid7
let invalid8Test test_ctxt = invalidDecodeTest invalid8
let invalid9Test test_ctxt = invalidDecodeTest invalid9
let invalid10Test test_ctxt = invalidDecodeTest invalid10
let invalid11Test test_ctxt = invalidDecodeTest invalid11

let suite =
  "suite">:::
    ["empty">:: empty
    ;"invalid0">:: invalid0Test
    ;"invalid1">:: invalid1Test
    ;"invalid2">:: invalid2Test
    ;"invalid3">:: invalid3Test
    ;"invalid4">:: invalid4Test
    ;"invalid5">:: invalid5Test
    ;"invalid6">:: invalid6Test
    ;"invalid7">:: invalid7Test
    ;"invalid8">:: invalid8Test
    ;"invalid9">:: invalid9Test
    ;"invalid10">:: invalid10Test
    ;"invalid11">:: invalid11Test
    ]

let () = run_test_tt_main suite
