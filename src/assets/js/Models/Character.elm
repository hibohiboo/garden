module Models.Character exposing (Character, EditorModel, characterDecoder, encodeCharacter, initCharacter)

import Array exposing (Array)
import GoogleSpreadSheetApi as GSAPI
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as E


type alias Character =
    { storeUserId : String
    , characterId : String
    , name : String
    , kana : String
    , organ : String
    , traits : Array String
    }


type alias EditorModel =
    { organs : List ( String, String )
    }


initCharacter : String -> Character
initCharacter storeUserId =
    Character storeUserId "" "" "" "" (Array.fromList [ "" ])


encodeCharacter : Character -> String
encodeCharacter c =
    -- エンコード後のインデント0。
    c |> encodeCharacterToValue |> E.encode 0


encodeCharacterToValue : Character -> E.Value
encodeCharacterToValue c =
    E.object
        [ ( "storeUserId", E.string c.storeUserId )
        , ( "characterId", E.string c.characterId )
        , ( "name", E.string c.name )
        , ( "kana", E.string c.kana )
        , ( "organ", E.string c.organ )
        , ( "traits", E.array E.string c.traits )
        ]


characterDecoder : Decoder Character
characterDecoder =
    Decode.succeed Character
        |> Json.Decode.Pipeline.required "storeUserId" Decode.string
        |> Json.Decode.Pipeline.required "characterId" Decode.string
        |> Json.Decode.Pipeline.required "name" Decode.string
        |> Json.Decode.Pipeline.required "kana" Decode.string
        |> Json.Decode.Pipeline.required "organ" Decode.string
        |> Json.Decode.Pipeline.optional "traits" (Decode.array Decode.string) (Array.fromList [ "" ])
