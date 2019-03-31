module Utils.TextStrings exposing (getText)

import Dict exposing (Dict)



-- Dictから値を取り出して返す。ない場合にはデフォルト値を返す


getText : Dict String String -> String -> String -> String
getText d key defaultValue =
    case Dict.get key d of
        Just val ->
            val

        Nothing ->
            defaultValue
