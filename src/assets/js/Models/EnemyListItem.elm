module Models.EnemyListItem exposing
    ( EnemyListItem
    , encodeEnemyListItem
    , enemyListFromFireStoreApi
    , enemyListItemDecoder
    , init
    )

import Array exposing (Array)
import FirestoreApi as FSApi
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E
import Models.Card as Card exposing (CardData)
import Models.Tag as Tag exposing (Tag)


type alias EnemyListItem =
    { enemyId : String
    , name : String
    , activePower : Int
    , memo : String
    , cardImage : String
    , kana : String
    , degreeOfThreat : Int
    , tags : List Tag
    , cards : Array CardData
    }


init =
    EnemyListItem "" "" 0 "" "" "" 0 [] Array.empty


encodeEnemyListItem : EnemyListItem -> E.Value
encodeEnemyListItem enemy =
    E.object
        [ ( "enemyId", E.string enemy.enemyId )
        , ( "name", E.string enemy.name )
        , ( "activePower", E.int enemy.activePower )
        , ( "memo", E.string enemy.memo )
        , ( "cardImage", E.string enemy.cardImage )
        , ( "kana", E.string enemy.kana )
        , ( "degreeOfThreat", E.int enemy.degreeOfThreat )
        , ( "tags", E.list Tag.encodeTagToValue enemy.tags )
        , ( "cards", E.array Card.encodeCardToValue enemy.cards )
        ]


enemyListItemDecoder : Decoder EnemyListItem
enemyListItemDecoder =
    D.succeed EnemyListItem
        |> optional "enemyId" D.string ""
        |> required "name" D.string
        |> required "activePower" D.int
        |> optional "memo" D.string ""
        |> optional "cardImage" D.string ""
        |> optional "kana" D.string ""
        |> optional "degreeOfThreat" D.int 0
        |> optional "tags" Tag.tagsDecoderFromJson []
        |> optional "cards" (D.array Card.cardDecoderFromJson) Array.empty


enemyListDecoderFromFireStoreApi : Decoder (List EnemyListItem)
enemyListDecoderFromFireStoreApi =
    D.at [ "documents" ] (D.list enemyListItemFieldDecoderFromFireStoreApi)


enemyListItemFieldDecoderFromFireStoreApi : Decoder EnemyListItem
enemyListItemFieldDecoderFromFireStoreApi =
    FSApi.fields enemyListItemDecoderFromFireStoreApi


enemyListItemDecoderFromFireStoreApi : Decoder EnemyListItem
enemyListItemDecoderFromFireStoreApi =
    D.succeed EnemyListItem
        |> optional "enemyId" FSApi.string ""
        |> required "name" FSApi.string
        |> required "activePower" FSApi.int
        |> required "memo" FSApi.string
        |> optional "cardImage" FSApi.string ""
        |> optional "kana" FSApi.string ""
        |> optional "degreeOfThreat" FSApi.int 0
        |> optional "tags" Tag.tagsDecoderFromFireStoreApi []
        |> optional "cards" (FSApi.array Card.cardDecoderFromFireStoreApi) (Array.fromList [])


enemyListFromFireStoreApi : String -> List EnemyListItem
enemyListFromFireStoreApi json =
    case D.decodeString enemyListDecoderFromFireStoreApi json of
        Ok item ->
            item

        Err _ ->
            []
