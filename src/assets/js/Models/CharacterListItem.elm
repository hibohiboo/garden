module Models.CharacterListItem exposing (CharacterListItem, characterListDecoder, characterListFromJson, characterListItemDecoder)

import FirestoreApi as FSApi
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline


type alias CharacterListItem =
    { characterId : String
    , name : String
    , labo : String
    }


characterListDecoder : Decoder (List CharacterListItem)
characterListDecoder =
    D.at [ "documents" ] (D.list characterListItemDecoder)


characterListItemDecoder : Decoder CharacterListItem
characterListItemDecoder =
    D.map3 CharacterListItem (FSApi.string "characterId") (FSApi.string "name") (FSApi.string "labo")


characterListFromJson : String -> List CharacterListItem
characterListFromJson json =
    case D.decodeString characterListDecoder json of
        Ok item ->
            item

        Err _ ->
            []
