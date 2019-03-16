module Tests exposing (suite, unitTest)

import Expect
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
        , testParse "shold parse User" "/foo" (Just (Route.User "foo"))
        , testParse "shold parse Repo" "/foo/bar" (Just (Route.Repo "foo" "bar"))
        , testParse "shold parse Inavalid path" "/foo/bar/baz" Nothing
        ]
