module Models.Character exposing
    ( Character
    , characterDecoder
    , characterDecoderFromFireStoreApi
    , characterListFromJson
    , encodeCharacter
    , initBaseCards
    , initCharacter
    )

import Array exposing (Array)
import FirestoreApi as FSApi
import GoogleSpreadSheetApi as GSAPI
import Json.Decode as D exposing (Decoder, Value, decodeString, field, string, succeed)
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
    , cardImage : String
    , cardImageData : String
    , characterImage : String
    , characterImageData : String
    , cardImageCreatorName : String
    , cardImageCreatorSite : String
    , cardImageCreatorUrl : String
    }


initCharacter : String -> Character
initCharacter storeUserId =
    Character storeUserId "" "" "" "" "" "" (Array.fromList []) "" "" "" 4 False "" "" "" "" "" "" ""


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
        , ( "cardImage", E.string c.cardImage )
        , ( "cardImageData", E.string c.cardImageData )
        , ( "characterImage", E.string c.characterImage )
        , ( "characterImageData", E.string c.characterImageData )
        , ( "cardImageCreatorName", E.string c.cardImageCreatorName )
        , ( "cardImageCreatorSite", E.string c.cardImageCreatorSite )
        , ( "cardImageCreatorUrl", E.string c.cardImageCreatorUrl )
        ]


characterDecoder : Decoder Character
characterDecoder =
    D.succeed Character
        |> required "storeUserId" D.string
        |> required "characterId" D.string
        |> required "name" D.string
        |> required "kana" D.string
        |> required "organ" D.string
        |> optional "trait" D.string ""
        |> optional "mutagen" D.string ""
        |> optional "cards" (D.array Card.cardDecoderFromJson) (Array.fromList [])
        |> optional "reason" D.string ""
        |> optional "labo" D.string ""
        |> optional "memo" D.string ""
        |> optional "activePower" D.int 4
        |> optional "isPublished" D.bool False
        |> optional "cardImage" D.string ""
        |> optional "cardImageData" D.string ""
        |> optional "characterImage" D.string ""
        |> optional "characterImageData" D.string ""
        |> optional "cardImageCreatorName" D.string ""
        |> optional "cardImageCreatorSite" D.string ""
        |> optional "cardImageCreatorUrl" D.string ""


characterDecoderFromFireStoreApi : Decoder Character
characterDecoderFromFireStoreApi =
    FSApi.fields characterDecoderFromFireStoreApiHealper


characterDecoderFromFireStoreApiHealper : Decoder Character
characterDecoderFromFireStoreApiHealper =
    D.succeed Character
        |> required "storeUserId" FSApi.string
        |> required "characterId" FSApi.string
        |> required "name" FSApi.string
        |> optional "kana" FSApi.string ""
        |> required "organ" FSApi.string
        |> optional "trait" FSApi.string ""
        |> optional "mutagen" FSApi.string ""
        |> optional "cards" (FSApi.array Card.cardDecoderFromFireStoreApi) (Array.fromList [])
        |> optional "reason" FSApi.string ""
        |> optional "labo" FSApi.string ""
        |> optional "memo" FSApi.string ""
        |> optional "activePower" FSApi.int 4
        |> optional "isPublished" FSApi.bool False
        |> optional "cardImage" FSApi.string ""
        |> optional "cardImageData" FSApi.string ""
        |> optional "characterImage" FSApi.string ""
        |> optional "characterImageData" FSApi.string ""
        |> optional "cardImageCreatorName" FSApi.string ""
        |> optional "cardImageCreatorSite" FSApi.string ""
        |> optional "cardImageCreatorUrl" FSApi.string ""


characterListDecoder : Decoder (List Character)
characterListDecoder =
    D.at [ "documents" ] (D.list characterDecoderFromFireStoreApiHealper)


characterListFromJson : String -> List Character
characterListFromJson json =
    case D.decodeString characterListDecoder json of
        Ok item ->
            item

        Err _ ->
            []



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
