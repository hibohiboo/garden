module Session exposing (Data, Version, addMarkdown, addOrgans, addSpreasSheetData, addTextStrings, empty, fetchMarkdown, fetchOrgans, fetchSpreasSheetData, fetchTextStrings, getMarkdown, getOrgans, getSpreasSheetData, getTextStrings, markdownUrl, organRange, organSheetId, organSheetVersion, testStringsRange, testStringsSheetId, testStringsSheetVersion, toMarkdownKey, toSpreasSheetDataKey)

import Dict
import GoogleSpreadSheetApi
import Http
import Json.Decode as Decode
import Url.Builder as Url


type alias Version =
    Float



-- SESSION DATA


type alias Data =
    { markdowns : Dict.Dict String String
    , sheets : Dict.Dict String String
    }


empty : Data
empty =
    Data Dict.empty Dict.empty



-- Markdown


toMarkdownKey : String -> Version -> String
toMarkdownKey fileName version =
    fileName ++ "@" ++ String.fromFloat version


getMarkdown : Data -> String -> Version -> Maybe String
getMarkdown data fileName version =
    Dict.get (toMarkdownKey fileName version) data.markdowns


addMarkdown : String -> Version -> String -> Data -> Data
addMarkdown fileName version markdown data =
    let
        newMarkdowns =
            Dict.insert (toMarkdownKey fileName version) markdown data.markdowns
    in
    { data | markdowns = newMarkdowns }


fetchMarkdown : (Result Http.Error String -> msg) -> String -> Cmd msg
fetchMarkdown toMsg fileName =
    Http.get
        { url = markdownUrl fileName
        , expect = Http.expectString toMsg
        }


markdownUrl : String -> String
markdownUrl fileName =
    Url.absolute [ "assets", "markdown", fileName ] []



-- SpreasSheetData


toSpreasSheetDataKey : String -> String -> Version -> String
toSpreasSheetDataKey documentId range version =
    documentId ++ "!" ++ range ++ "@" ++ String.fromFloat version


getSpreasSheetData : Data -> String -> String -> Version -> Maybe String
getSpreasSheetData data documentId range version =
    Dict.get (toSpreasSheetDataKey documentId range version) data.sheets


addSpreasSheetData : String -> String -> Version -> String -> Data -> Data
addSpreasSheetData documentId range version sheet data =
    let
        newSpreasSheetDatas =
            Dict.insert (toSpreasSheetDataKey documentId range version) sheet data.sheets
    in
    { data | sheets = newSpreasSheetDatas }


fetchSpreasSheetData : (Result Http.Error String -> msg) -> String -> String -> String -> Cmd msg
fetchSpreasSheetData toMsg apiKey documentId range =
    Http.get
        { url = GoogleSpreadSheetApi.sheetUrl apiKey documentId range
        , expect = Http.expectString toMsg
        }



-- 変異器官


organSheetId =
    "1cyGpEw4GPI2k5snngBPKz7rfETklKdSaIBqQKnTta1w"


organRange =
    "organList!A2:B11"


organSheetVersion =
    1.0


getOrgans : Data -> Maybe String
getOrgans data =
    getSpreasSheetData data organSheetId organRange organSheetVersion


addOrgans : Data -> String -> Data
addOrgans data json =
    addSpreasSheetData organSheetId organRange organSheetVersion json data


fetchOrgans : (Result Http.Error String -> msg) -> String -> Cmd msg
fetchOrgans toMsg apiKey =
    fetchSpreasSheetData toMsg apiKey organSheetId organRange



-- 文字列


testStringsSheetId =
    "1cyGpEw4GPI2k5snngBPKz7rfETklKdSaIBqQKnTta1w"


testStringsRange =
    "textStrings!A2:B29"


testStringsSheetVersion =
    1.0


getTextStrings : Data -> Maybe String
getTextStrings data =
    getSpreasSheetData data testStringsSheetId testStringsRange testStringsSheetVersion


addTextStrings : Data -> String -> Data
addTextStrings data json =
    addSpreasSheetData testStringsSheetId testStringsRange testStringsSheetVersion json data


fetchTextStrings : (Result Http.Error String -> msg) -> String -> Cmd msg
fetchTextStrings toMsg apiKey =
    fetchSpreasSheetData toMsg apiKey testStringsSheetId testStringsRange
