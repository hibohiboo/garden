module Models.Character exposing (Character, characterDecoder, encodeCharacter, initBaseCards, initCharacter)

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
    , trait : String
    , mutagen : String
    , cards : Array Card.CardData
    , reason : String
    , labo : String
    , memo : String
    , activePower : Int
    , isPublished : Bool
    }


initCharacter : String -> Character
initCharacter storeUserId =
    Character storeUserId "" "" "" "" "" "" (Array.fromList []) "" "" "" 4 False


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
        , ( "trait", E.string c.trait )
        , ( "mutagen", E.string c.mutagen )
        , ( "cards", E.array Card.encodeCardToValue c.cards )
        , ( "reason", E.string c.reason )
        , ( "labo", E.string c.labo )
        , ( "memo", E.string c.memo )
        , ( "activePower", E.int c.activePower )
        , ( "isPublished", E.bool c.isPublished )
        ]


characterDecoder : Decoder Character
characterDecoder =
    Decode.succeed Character
        |> Json.Decode.Pipeline.required "storeUserId" Decode.string
        |> Json.Decode.Pipeline.required "characterId" Decode.string
        |> Json.Decode.Pipeline.required "name" Decode.string
        |> Json.Decode.Pipeline.required "kana" Decode.string
        |> Json.Decode.Pipeline.required "organ" Decode.string
        |> Json.Decode.Pipeline.optional "trait" Decode.string ""
        |> Json.Decode.Pipeline.optional "mutagen" Decode.string ""
        |> Json.Decode.Pipeline.optional "cards" (Decode.array Card.cardDecoderFromJson) (Array.fromList [])
        |> Json.Decode.Pipeline.optional "reason" Decode.string ""
        |> Json.Decode.Pipeline.optional "labo" Decode.string ""
        |> Json.Decode.Pipeline.optional "memo" Decode.string ""
        |> Json.Decode.Pipeline.optional "activePower" Decode.int 4
        |> Json.Decode.Pipeline.optional "isPublished" Decode.bool False



-- ==============================================================================================
-- ユーティリティ
-- ==============================================================================================


initBaseCards : Character -> List Card.CardData -> Character
initBaseCards char cards =
    let
        baseCards =
            Card.getBases cards
    in
    { char | cards = Array.fromList baseCards }
