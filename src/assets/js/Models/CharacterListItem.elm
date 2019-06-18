module Models.CharacterListItem exposing (CharacterListItem, characterListItemDecoder)

import FirestoreApi as FSApi
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline


type alias CharacterListItem =
    { characterId : String
    , name : String
    , labo : String
    }


characterListItemDecoder : Decoder CharacterListItem
characterListItemDecoder =
    D.map3 CharacterListItem (FSApi.string "characterId") (FSApi.string "name") (FSApi.string "labo")
