module GoogleSpreadSheetApi exposing (Organ, dictFromJson, organDecodeFromString, organDecoder, organsDecodeFromString, organsDecoder, organsInObjectDecodeFromString, organsInObjectDecoder, organsListFromJson, sheetUrl)

import Dict exposing (Dict)
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


organsListFromJson : String -> List Organ
organsListFromJson sheet =
    case organsInObjectDecodeFromString sheet of
        Ok organs ->
            organs

        Err _ ->
            []


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



-- テキスト文字列一覧


type alias Text =
    { key : String
    , value : String
    }


textStringDecoder : Decoder ( String, String )
textStringDecoder =
    D.map2 Tuple.pair
        (index 0 string)
        (index 1 string)


textStringsDecoder : String -> Result Error (List ( String, String ))
textStringsDecoder s =
    decodeString (field "values" (D.list textStringDecoder)) s


dictFromJson : String -> Dict String String
dictFromJson sheet =
    case textStringsDecoder sheet of
        Ok a ->
            Dict.fromList a

        Err _ ->
            Dict.empty
