module GoogleSpreadSheetApi exposing (Organ, organDecodeFromString, organDecoder, organsDecodeFromString, organsDecoder, organsInObjectDecodeFromString)

import Http
import Json.Decode as D exposing (..)
import Url
import Url.Builder


type alias Organ =
    { name : String
    , description : String
    }


organsInObjectDecodeFromString : String -> Result Error (List Organ)
organsInObjectDecodeFromString s =
    decodeString organsInObjectDecoder s


organsInObjectDecoder : Decoder (List Organ)
organsInObjectDecoder =
    field "values" organsDecoder


organsDecodeFromString : String -> Result Error (List Organ)
organsDecodeFromString s =
    decodeString organsDecoder s


organsDecoder : Decoder (List Organ)
organsDecoder =
    D.list organDecoder


organDecodeFromString : String -> Result Error Organ
organDecodeFromString s =
    decodeString organDecoder s


organDecoder : Decoder Organ
organDecoder =
    D.map2 Organ
        (index 0 string)
        (index 1 string)
