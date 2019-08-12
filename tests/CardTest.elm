module CardTest exposing (unitTest)

import Array
import Dict exposing (Dict)
import Expect
import Json.Decode as D
import Models.Card as Card
import Models.Tag as Tag exposing (Tag)
import Test exposing (..)



----


unitTest : Test
unitTest =
    describe "カードのテスト"
        [ describe "カード配列から指定したタグ名のものを絞り込む"
            [ test "タグ名がある場合" <|
                \() ->
                    let
                        def =
                            Card.initCard

                        array =
                            [ def, { def | tags = [ Tag "てすと" 0, Tag "2" 0 ] }, { def | tags = [ Tag "1" 0, Tag "てすと" 0 ] } ]

                        filterd =
                            Card.filterByName "てすと" array
                    in
                    List.length filterd
                        |> Expect.equal 2
            , test "タグ名がない場合" <|
                \() ->
                    let
                        def =
                            Card.initCard

                        array =
                            [ def, { def | tags = [ Tag "てすと" 0, Tag "2" 0 ] } ]

                        filterd =
                            Card.filterByName "ないよ" array
                    in
                    List.length filterd
                        |> Expect.equal 0
            ]
        ]
