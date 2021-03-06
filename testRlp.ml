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

let encodeTest orig result =
  let encoded = encode (RlpData (Rope.of_string orig)) in
  let expected = (Rope.of_string (Hex.(to_string (`Hex result)))) in
  assert_equal (Rope.to_string encoded) (Rope.to_string expected);
  let r = RlpData (Rope.of_string orig) in
  assert_equal (Rope.to_string Rlp.(encode r)) (Rope.to_string (Rlp.(encode (decode (encode r)))))

let dog test_ctxt =
  encodeTest "dog" "83646f67"

let shortstring2 test_ctxt =
  encodeTest "Lorem ipsum dolor sit amet, consectetur adipisicing eli"
             "b74c6f72656d20697073756d20646f6c6f722073697420616d65742c20636f6e7365637465747572206164697069736963696e6720656c69"

let longstring test_ctxt =
  encodeTest "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
             "b8384c6f72656d20697073756d20646f6c6f722073697420616d65742c20636f6e7365637465747572206164697069736963696e6720656c6974"

let longstring2 test_ctxt =
  encodeTest "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur mauris magna, suscipit sed vehicula non, iaculis faucibus tortor. Proin suscipit ultricies malesuada. Duis tortor elit, dictum quis tristique eu, ultrices at risus. Morbi a est imperdiet mi ullamcorper aliquet suscipit nec lorem. Aenean quis leo mollis, vulputate elit varius, consequat enim. Nulla ultrices turpis justo, et posuere urna consectetur nec. Proin non convallis metus. Donec tempor ipsum in mauris congue sollicitudin. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Suspendisse convallis sem vel massa faucibus, eget lacinia lacus tempor. Nulla quis ultricies purus. Proin auctor rhoncus nibh condimentum mollis. Aliquam consequat enim at metus luctus, a eleifend purus egestas. Curabitur at nibh metus. Nam bibendum, neque at auctor tristique, lorem libero aliquet arcu, non interdum tellus lectus sit amet eros. Cras rhoncus, metus ac ornare cursus, dolor justo ultrices metus, at ullamcorper volutpat"
             "b904004c6f72656d20697073756d20646f6c6f722073697420616d65742c20636f6e73656374657475722061646970697363696e6720656c69742e20437572616269747572206d6175726973206d61676e612c20737573636970697420736564207665686963756c61206e6f6e2c20696163756c697320666175636962757320746f72746f722e2050726f696e20737573636970697420756c74726963696573206d616c6573756164612e204475697320746f72746f7220656c69742c2064696374756d2071756973207472697374697175652065752c20756c7472696365732061742072697375732e204d6f72626920612065737420696d70657264696574206d6920756c6c616d636f7270657220616c6971756574207375736369706974206e6563206c6f72656d2e2041656e65616e2071756973206c656f206d6f6c6c69732c2076756c70757461746520656c6974207661726975732c20636f6e73657175617420656e696d2e204e756c6c6120756c74726963657320747572706973206a7573746f2c20657420706f73756572652075726e6120636f6e7365637465747572206e65632e2050726f696e206e6f6e20636f6e76616c6c6973206d657475732e20446f6e65632074656d706f7220697073756d20696e206d617572697320636f6e67756520736f6c6c696369747564696e2e20566573746962756c756d20616e746520697073756d207072696d697320696e206661756369627573206f726369206c756374757320657420756c74726963657320706f737565726520637562696c69612043757261653b2053757370656e646973736520636f6e76616c6c69732073656d2076656c206d617373612066617563696275732c2065676574206c6163696e6961206c616375732074656d706f722e204e756c6c61207175697320756c747269636965732070757275732e2050726f696e20617563746f722072686f6e637573206e69626820636f6e64696d656e74756d206d6f6c6c69732e20416c697175616d20636f6e73657175617420656e696d206174206d65747573206c75637475732c206120656c656966656e6420707572757320656765737461732e20437572616269747572206174206e696268206d657475732e204e616d20626962656e64756d2c206e6571756520617420617563746f72207472697374697175652c206c6f72656d206c696265726f20616c697175657420617263752c206e6f6e20696e74657264756d2074656c6c7573206c65637475732073697420616d65742065726f732e20437261732072686f6e6375732c206d65747573206163206f726e617265206375727375732c20646f6c6f72206a7573746f20756c747269636573206d657475732c20617420756c6c616d636f7270657220766f6c7574706174"

let encodeObjTest orig result =
  let encoded = encode orig in
  let expected = (Rope.of_string (Hex.(to_string (`Hex result)))) in
  assert_equal (Rope.to_string encoded) (Rope.to_string expected);
  assert_equal (Rope.to_string (Rlp.encode orig)) (Rope.to_string (Rlp.(encode (decode (encode orig)))))


let emptylist test_ctxt =
  encodeObjTest (RlpList []) "c0"

let rlpString str =
  RlpData (Rope.of_string str)

let stringlist test_ctxt =
  encodeObjTest (RlpList [rlpString "dog"; rlpString "god"; rlpString "cat"])
                "cc83646f6783676f6483636174"

let shortListMax1 test_ctxt =
  encodeObjTest (RlpList (List.map rlpString ["asdf"; "qwer"; "zxcv"; "asdf";"qwer"; "zxcv"; "asdf"; "qwer"; "zxcv"; "asdf"; "qwer"]))
                "F784617364668471776572847a78637684617364668471776572847a78637684617364668471776572847a78637684617364668471776572"

let longList1 test_ctxt =
  encodeObjTest (RlpList
                   [ RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ])
                "F840CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376"

let longList2 test_ctxt =
  encodeObjTest (RlpList
                   [ RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ; RlpList (List.map rlpString ["asdf";"qwer";"zxcv"])
                   ])
                "F90200CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376CF84617364668471776572847a786376"


let listsoflists test_ctx =
  encodeObjTest (RlpList [ RlpList [ RlpList []; RlpList [] ]; RlpList [] ])
                "c4c2c0c0c0"

let listsoflists2 test_ctx =
  encodeObjTest (RlpList [ RlpList []; RlpList [RlpList []]; RlpList [ RlpList []; RlpList[ RlpList []] ] ])
                "c7c0c1c0c3c0c1c0"


let dictTest1 test_ctx =
  encodeObjTest (RlpList [ RlpList [ rlpString "key1"; rlpString "val1"];
                           RlpList [ rlpString "key2"; rlpString "val2"];
                           RlpList [ rlpString "key3"; rlpString "val3"];
                           RlpList [ rlpString "key4"; rlpString "val4"]])
                "ECCA846b6579318476616c31CA846b6579328476616c32CA846b6579338476616c33CA846b6579348476616c34"

let smallint test_ctx =
  encodeObjTest (rlpInt 1) "01"

let smallint2 test_ctx =
  encodeObjTest (rlpInt 16) "10"

let smallint3 test_ctx =
  encodeObjTest (rlpInt 79) "4f"

let smallint4 test_ctx =
  encodeObjTest (rlpInt 127) "7f"

let mediumint1 test_ctx =
  encodeObjTest (rlpInt 128) "8180"

let mediumint2 test_ctx =
  encodeObjTest (rlpInt 1000) "8203e8"

let mediumint3 test_ctx =
  encodeObjTest (rlpInt 100000) "830186a0"

let mediumint4 test_ctx =
  encodeObjTest (rlpBigInt (Big_int.big_int_of_string "83729609699884896815286331701780722"))
                "8F102030405060708090A0B0C0D0E0F2"

let mediumint5 test_ctx =
  encodeObjTest (rlpBigInt (Big_int.big_int_of_string "105315505618206987246253880190783558935785933862974822347068935681"))
                "9C0100020003000400050006000700080009000A000B000C000D000E01"

let suite =
  "suite">:::
    ["empty">:: empty
    ;"dog">:: dog
    ;"shortstring2">:: shortstring2
    ;"longstring">:: longstring
    ;"longstring2">:: longstring2
    ;"emptylist">:: emptylist
    ;"stringlist">:: stringlist
    ;"shortListMax1">:: shortListMax1
    ;"longList1">:: longList1
    ;"longList2">:: longList2
    ;"listsoflists">:: listsoflists
    ;"listsoflists2">:: listsoflists2
    ;"dictTest1">:: dictTest1
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
    ;"smallint">:: smallint
    ;"smallint2">:: smallint2
    ;"smallint3">:: smallint3
    ;"mediumint1">:: mediumint1
    ;"mediumint2">:: mediumint2
    ;"mediumint3">:: mediumint3
    ;"mediumint4">:: mediumint4
    ;"mediumint5">:: mediumint5
    ]

let () = run_test_tt_main suite
