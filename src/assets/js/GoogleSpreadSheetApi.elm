module GoogleSpreadSheetApi exposing
    ( decodeIntFromString
    , decodeTuplesBySplitCommmaString
    , decoderIntFromString
    , dictFromSpreadSheet
    , parseTupleBySplitCollonString
    , parseTuplesBySplitCommmaString
    , sheetUrl
    , tupleDecodeFromString
    , tupleDecoder
    , tuplesDecodeFromString
    , tuplesDecoder
    , tuplesInObjectDecodeFromString
    , tuplesInObjectDecoder
    , tuplesIntDecodeFromString
    , tuplesListFromJson
    )

import Dict exposing (Dict)
import Http
import Json.Decode as D exposing (..)
import Url
import Url.Builder



-- 変異器官一覧


sheetUrl : String -> String -> String -> String
sheetUrl apiKey documentId range =
    Url.Builder.crossOrigin "https://sheets.googleapis.com" [ "v4", "spreadsheets", documentId, "values", range ] [ Url.Builder.string "key" apiKey ]


tuplesListFromJson : String -> List ( String, String )
tuplesListFromJson sheet =
    case tuplesInObjectDecodeFromString sheet of
        Ok tuples ->
            tuples

        Err _ ->
            []


tuplesInObjectDecodeFromString : String -> Result Error (List ( String, String ))
tuplesInObjectDecodeFromString s =
    decodeString tuplesInObjectDecoder s


tuplesInObjectDecoder : Decoder (List ( String, String ))
tuplesInObjectDecoder =
    field "values" tuplesDecoder


tuplesDecodeFromString : String -> Result Error (List ( String, String ))
tuplesDecodeFromString s =
    decodeString tuplesDecoder s


tuplesDecoder : Decoder (List ( String, String ))
tuplesDecoder =
    D.list tupleDecoder


tupleDecodeFromString : String -> Result Error ( String, String )
tupleDecodeFromString s =
    decodeString tupleDecoder s


tupleDecoder : Decoder ( String, String )
tupleDecoder =
    D.map2 Tuple.pair
        (index 0 string)
        (index 1 string)



-- テキスト文字列一覧


textStringDecoder : Decoder ( String, String )
textStringDecoder =
    D.map2 Tuple.pair
        (index 0 string)
        (index 1 string)


textStringsDecoder : String -> Result Error (List ( String, String ))
textStringsDecoder s =
    decodeString (field "values" (D.list textStringDecoder)) s


dictFromSpreadSheet : String -> Dict String String
dictFromSpreadSheet sheet =
    case textStringsDecoder sheet of
        Ok a ->
            Dict.fromList a

        Err _ ->
            Dict.empty


decoderIntFromString : Decoder Int
decoderIntFromString =
    D.map
        (\s ->
            case String.toInt s of
                Just i ->
                    i

                _ ->
                    0
        )
        D.string


decodeIntFromString : String -> Result Error Int
decodeIntFromString s =
    decodeString decoderIntFromString s



-- カード一覧


parseTuplesBySplitCommmaString : String -> List ( String, Int )
parseTuplesBySplitCommmaString s =
    let
        list =
            String.split "," s
    in
    List.map (\str -> parseTupleBySplitCollonString str) list


decoderTuplesBySplitCommmaString : Decoder (List ( String, Int ))
decoderTuplesBySplitCommmaString =
    D.map parseTuplesBySplitCommmaString string


decodeTuplesBySplitCommmaString : String -> Result Error (List ( String, Int ))
decodeTuplesBySplitCommmaString s =
    decodeString decoderTuplesBySplitCommmaString s


parseTupleBySplitCollonString : String -> ( String, Int )
parseTupleBySplitCollonString s =
    let
        list =
            String.split ":" s

        name =
            case List.head list of
                Just a ->
                    a

                _ ->
                    s

        value =
            case List.tail list of
                Just t ->
                    case List.head t of
                        Just a ->
                            case String.toInt a of
                                Just n ->
                                    n

                                _ ->
                                    0

                        _ ->
                            0

                _ ->
                    0
    in
    Tuple.pair name value


decoderTupleBySplitCollonString : Decoder ( String, Int )
decoderTupleBySplitCollonString =
    D.map parseTupleBySplitCollonString string


tuplesIntDecodeFromString : String -> Result Error ( String, Int )
tuplesIntDecodeFromString s =
    decodeString decoderTupleBySplitCollonString s
