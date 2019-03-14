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


suite : Test
suite =
    describe "Route"
        [ test "should parase URL" <|
            \_ ->
                Url.fromString "http://example.com/"
                    |> Maybe.andThen Route.parse
                    |> Expect.equal (Just Route.Top)
        ]
