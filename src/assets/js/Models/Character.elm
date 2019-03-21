module Models.Character exposing (Character, encodeCharacter, initCharacter)

import Json.Encode as E


type alias Character =
    { name : String
    , kana : String
    }


initCharacter : Character
initCharacter =
    Character "" ""


encodeCharacter : Character -> String
encodeCharacter c =
    -- エンコード後のインデント0。
    c |> encodeCharacterToValue |> E.encode 0


encodeCharacterToValue : Character -> E.Value
encodeCharacterToValue c =
    E.object
        [ ( "name", E.string c.name )
        , ( "kana", E.string c.kana )
        ]
