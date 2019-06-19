module Models.CharacterListItem exposing (CharacterListItem, characterListDecoder, characterListFromJson, characterListItemDecoder)

import FirestoreApi as FSApi
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


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
    D.succeed CharacterListItem
        |> required "characterId" FSApi.string
        |> required "name" FSApi.string
        |> required "labo" FSApi.string
        |> FSApi.fields



-- FSApi.fields <| D.map3 CharacterListItem (D.at [ "characterId" ] FSApi.string) (D.at [ "name" ] FSApi.string) (D.at [ "labo" ] FSApi.string)


characterListFromJson : String -> List CharacterListItem
characterListFromJson json =
    case D.decodeString characterListDecoder json of
        Ok item ->
            item

        Err _ ->
            []
