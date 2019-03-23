module Models.Character exposing (Character, characterDecoder, encodeCharacter, initCharacter)

import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
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


characterDecoder : Decoder Character
characterDecoder =
    Decode.succeed Character
        |> Json.Decode.Pipeline.required "name" Decode.string
        |> Json.Decode.Pipeline.required "kana" Decode.string
