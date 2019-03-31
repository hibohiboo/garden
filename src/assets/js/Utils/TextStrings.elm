module Utils.TextStrings exposing (defaultEmpty, getText)

import Dict exposing (Dict)


defaultEmpty : Dict String String -> String -> String
defaultEmpty d key =
    getText d key ""


getText : Dict String String -> String -> String -> String
getText d key defaultValue =
    case Dict.get key d of
        Just val ->
            val

        Nothing ->
            defaultValue
