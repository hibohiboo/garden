module Utils.TextStrings exposing (getText)

import Dict exposing (Dict)


dict : Dict String String
dict =
    Dict.fromList [ ( "test", "test" ), ( "a", "b" ) ]


getText : String -> String
getText key =
    case Dict.get key dict of
        Just val ->
            val

        Nothing ->
            ""
