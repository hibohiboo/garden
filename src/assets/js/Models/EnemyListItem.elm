module Models.EnemyListItem exposing (EnemyListItem, enemyListDecoder, enemyListFromJson, enemyListItemDecoder)

import FirestoreApi as FSApi
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
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
    }


enemyListDecoder : Decoder (List EnemyListItem)
enemyListDecoder =
    D.at [ "documents" ] (D.list enemyListItemFieldDecoder)


enemyListItemFieldDecoder : Decoder EnemyListItem
enemyListItemFieldDecoder =
    FSApi.fields enemyListItemDecoder


enemyListItemDecoder : Decoder EnemyListItem
enemyListItemDecoder =
    D.succeed EnemyListItem
        |> required "enemyId" FSApi.string
        |> required "name" FSApi.string
        |> required "activePower" FSApi.int
        |> required "memo" FSApi.string
        |> optional "cardImage" FSApi.string ""
        |> optional "kana" FSApi.string ""
        |> optional "degreeOfThreat" FSApi.int 0
        |> optional "tags" Tag.tagsDecoderFromFireStoreApi []


enemyListFromJson : String -> List EnemyListItem
enemyListFromJson json =
    case D.decodeString enemyListDecoder json of
        Ok item ->
            item

        Err _ ->
            []
