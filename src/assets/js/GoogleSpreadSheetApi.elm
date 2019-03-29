module GoogleSpreadSheetApi exposing (Organ, organDecodeFromString, organDecoder, organsDecodeFromString, organsDecoder, organsInObjectDecodeFromString, organsInObjectDecoder, sheetUrl)

import Http
import Json.Decode as D exposing (..)
import Url
import Url.Builder



-- 変異器官一覧


type alias Organ =
    { name : String
    , description : String
    }


sheetUrl : String -> String -> String -> String
sheetUrl apiKey documentId range =
    Url.Builder.crossOrigin "https://sheets.googleapis.com" [ "v4", "spreadsheets", documentId, "values", range ] [ Url.Builder.string "key" apiKey ]


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
