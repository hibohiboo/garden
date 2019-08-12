module TagTest exposing (unitTest)

import Array
import Dict exposing (Dict)
import Expect
import Json.Decode as D
import Models.Tag as Tag exposing (Tag)
import Test exposing (..)



----


unitTest : Test
unitTest =
    describe "タグのテスト"
        [ test "タグ一覧の中に一致する名前があることを確認する" <|
            \() ->
                Tag.memberByName "てすと" [ Tag "てすと" 0, Tag "2" 0 ]
                    |> Expect.equal True
        , test "タグ一覧の中に一致する名前がないことを確認する" <|
            \() ->
                Tag.memberByName "ててて" [ Tag "てすと" 0, Tag "2" 0 ]
                    |> Expect.equal False
        ]
