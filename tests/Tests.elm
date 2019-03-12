module Tests exposing (..)

import Test exposing (..)
import Expect

----

unitTest : Test
unitTest =
    describe "simple unit test"
        [ test "Inc adds one" <|
            \() ->
                1
                    |> Expect.equal 1
        ]