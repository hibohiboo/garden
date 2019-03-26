module Tests exposing (sheet, suite, unitTest)

import Expect
import GoogleSpreadSheetApi as GSApi
import Route exposing (..)
import Test exposing (..)
import Url



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
        , test "配列をレコードに処理するテスト" <|
            \_ ->
                let
                    actual =
                        case GSApi.organsDecodeFromString "[[\"a\", \"b\"],[\"c\", \"d\"]]" of
                            Ok a ->
                                a

                            Err _ ->
                                []

                    expect =
                        [ GSApi.Organ "a" "b", GSApi.Organ "c" "d" ]
                in
                Expect.equal actual expect
        ]
