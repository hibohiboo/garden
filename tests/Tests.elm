module Tests exposing (getText, sheet, suite, unitTest)

import Dict exposing (Dict)
import Expect
import GoogleSpreadSheetApi as GSApi
import Route exposing (..)
import Test exposing (..)
import Url
import Utils.TextStrings as Tx



----


unitTest : Test
unitTest =
    describe "simple unit test"
        [ test "Inc adds one" <|
            \() ->
                1
                    |> Expect.equal 1
        ]


{-| テストケースを簡単に書くためのヘルパー関数
-}
testParse : String -> String -> Maybe Route -> Test
testParse name path expectedRoute =
    test name <|
        \_ ->
            Url.fromString ("http://example.com" ++ path)
                |> Maybe.andThen Route.parse
                |> Expect.equal expectedRoute


suite : Test
suite =
    describe "Route"
        [ testParse "shold parse Top" "/" (Just Route.Top)
        , testParse "shold parse Top with quesies" "/?dummy=value" (Just Route.Top)
        , testParse "shold parse Top with hash" "/#dumy" (Just Route.Top)
        , testParse "shold parse RuleBook" "/rulebook" (Just (Route.RuleBook Nothing))
        , testParse "shold parse RuleBook with hash" "/rulebook#first" (Just (Route.RuleBook (Just "first")))
        , testParse "shold parse PrivacyPolicy" "/privacy-policy" (Just Route.PrivacyPolicy)
        , testParse "shold parse Agreement" "/agreement" (Just Route.Agreement)
        , testParse "shold parse LoginUser" "/mypage" (Just Route.LoginUser)
        , testParse "shold parse CreateCharacter" "/mypage/character/create/aaa" (Just (Route.CharacterCreate "aaa"))
        , testParse "shold parse UpdateCharacter" "/mypage/character/edit/aaa/bbb" (Just (Route.CharacterUpdate "aaa" "bbb"))
        , testParse "shold parse Inavalid path" "/foo/bar/baz" Nothing
        ]


sheet : Test
sheet =
    describe "GoogleSpreadSheet"
        [ test "配列をレコードに入れるテスト" <|
            \_ ->
                let
                    actual =
                        case GSApi.organDecodeFromString "[\"a\", \"b\"]" of
                            Ok a ->
                                a

                            Err _ ->
                                GSApi.Organ "" ""

                    expect =
                        { name = "a", description = "b" }
                in
                Expect.equal actual expect
        , test "配列の配列を処理するテスト" <|
            \_ ->
                let
                    actual =
                        case GSApi.organsDecodeFromString "[[\"a\", \"b\"],[\"c\", \"d\"]]" of
                            Ok a ->
                                a

                            Err _ ->
                                [ GSApi.Organ "a" "b" ]

                    expect =
                        [ GSApi.Organ "a" "b", GSApi.Organ "c" "d" ]
                in
                Expect.equal actual expect
        , test "オブジェクトの中の配列を処理するテスト" <|
            \_ ->
                let
                    actual =
                        case GSApi.organsInObjectDecodeFromString "{\"values\":[[\"a\", \"b\"],[\"c\", \"d\"]]}" of
                            Ok a ->
                                a

                            Err _ ->
                                []

                    expect =
                        [ GSApi.Organ "a" "b", GSApi.Organ "c" "d" ]
                in
                Expect.equal actual expect
        ]


getText : Test
getText =
    describe "TextStrings"
        [ describe "defaultEmpty"
            [ test "値を取得するテスト" <|
                \_ ->
                    let
                        actual =
                            Tx.defaultEmpty (Dict.fromList [ ( "test", "test" ), ( "a", "b" ) ]) "test"

                        expect =
                            "test"
                    in
                    Expect.equal actual expect
            , test "値がなければ空白を取得するテスト" <|
                \_ ->
                    let
                        actual =
                            Tx.defaultEmpty (Dict.fromList [ ( "test", "test" ), ( "a", "b" ) ]) "bb"

                        expect =
                            ""
                    in
                    Expect.equal actual expect
            ]
        , describe "getText"
            [ test "値を取得するテスト" <|
                \_ ->
                    let
                        actual =
                            Tx.getText (Dict.fromList [ ( "test", "test" ), ( "a", "b" ) ]) "test" "default value"

                        expect =
                            "test"
                    in
                    Expect.equal actual expect
            , test "値がなければデフォルト値を取得するテスト" <|
                \_ ->
                    let
                        actual =
                            Tx.getText (Dict.fromList [ ( "test", "test" ), ( "a", "b" ) ]) "bb" "default value"

                        expect =
                            "default value"
                    in
                    Expect.equal actual expect
            ]
        , test "スプレッドから取得した結果をディクショナリにするテスト" <|
            \_ ->
                let
                    actual =
                        GSApi.dictFromSpreadSheet "{\"values\":[[\"a\", \"b\"],[\"c\", \"d\"]]}"

                    expect =
                        Dict.fromList [ ( "a", "b" ), ( "c", "d" ) ]
                in
                Expect.equal actual expect
        ]
