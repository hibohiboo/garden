module Models.Character exposing (Character, characterDecoder, encodeCharacter, initCharacter)

import Array exposing (Array)
import GoogleSpreadSheetApi as GSAPI
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as E
import Models.Card as Card


type alias Character =
    { storeUserId : String
    , characterId : String
    , name : String
    , kana : String
    , organ : String
    , cards : Array Card.CardData
    }


initCharacter : String -> Character
initCharacter storeUserId =
    Character storeUserId "" "" "" "" (Array.fromList [])


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
        , ( "cards", E.array Card.encodeCardToValue c.cards )
        ]


characterDecoder : Decoder Character
characterDecoder =
    Decode.succeed Character
        |> Json.Decode.Pipeline.required "storeUserId" Decode.string
        |> Json.Decode.Pipeline.required "characterId" Decode.string
        |> Json.Decode.Pipeline.required "name" Decode.string
        |> Json.Decode.Pipeline.required "kana" Decode.string
        |> Json.Decode.Pipeline.required "organ" Decode.string
        |> Json.Decode.Pipeline.optional "cards" (Decode.array Card.cardDecoder) (Array.fromList [])
