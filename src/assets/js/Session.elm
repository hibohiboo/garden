module Session exposing (Data, Version, addCards, addCharacter, addCharacters, addFaqs, addJsonData, addMarkdown, addReasons, addSpreasSheetData, addTextStrings, addTraits, addUserCards, cardRange, cardSheetId, cardSheetVersion, empty, faqRange, faqSheetId, faqSheetVersion, fetchCards, fetchCharacter, fetchCharacters, fetchFaqs, fetchJsonData, fetchMarkdown, fetchReasons, fetchSpreasSheetData, fetchTextStrings, fetchTraits, fetchUserCards, getCards, getCharacter, getCharacters, getFaqs, getJsonData, getMarkdown, getReasons, getSpreasSheetData, getTextStrings, getTraits, getUserCards, markdownUrl, reasonRange, reasonSheetId, reasonSheetVersion, textStringsRange, textStringsSheetId, textStringsSheetVersion, toMarkdownKey, toSpreasSheetDataKey, traitRange, traitSheetId, traitSheetVersion, userCardRange, userCardSheetId, userCardSheetVersion)

import Dict
import FirestoreApi
import GoogleSpreadSheetApi
import Http
import Url.Builder as Url


type alias Version =
    Float



-- SESSION DATA


type alias Data =
    { markdowns : Dict.Dict String String
    , sheets : Dict.Dict String String
    , json : Dict.Dict String String
    }


empty : Data
empty =
    Data Dict.empty Dict.empty Dict.empty



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


getJsonData : Data -> String -> Maybe String
getJsonData data url =
    Dict.get url data.json


addJsonData : String -> String -> Data -> Data
addJsonData url json data =
    let
        newDatas =
            Dict.insert url json data.json
    in
    { data | json = newDatas }


fetchJsonData : (Result Http.Error String -> msg) -> String -> Cmd msg
fetchJsonData toMsg url =
    Http.get
        { url = url
        , expect = Http.expectString toMsg
        }



-- 文字列


textStringsSheetId =
    "1cyGpEw4GPI2k5snngBPKz7rfETklKdSaIBqQKnTta1w"


textStringsRange =
    "textStrings!A2:B100"


textStringsSheetVersion =
    1.0


getTextStrings : Data -> Maybe String
getTextStrings data =
    getSpreasSheetData data textStringsSheetId textStringsRange textStringsSheetVersion


addTextStrings : Data -> String -> Data
addTextStrings data json =
    addSpreasSheetData textStringsSheetId textStringsRange textStringsSheetVersion json data


fetchTextStrings : (Result Http.Error String -> msg) -> String -> Cmd msg
fetchTextStrings toMsg apiKey =
    fetchSpreasSheetData toMsg apiKey textStringsSheetId textStringsRange



-- 変異器官


reasonSheetId =
    "1cyGpEw4GPI2k5snngBPKz7rfETklKdSaIBqQKnTta1w"


reasonRange =
    "reasonList!A2:B11"


reasonSheetVersion =
    1.0


getReasons : Data -> Maybe String
getReasons data =
    getSpreasSheetData data reasonSheetId reasonRange reasonSheetVersion


addReasons : Data -> String -> Data
addReasons data json =
    addSpreasSheetData reasonSheetId reasonRange reasonSheetVersion json data


fetchReasons : (Result Http.Error String -> msg) -> String -> Cmd msg
fetchReasons toMsg apiKey =
    fetchSpreasSheetData toMsg apiKey reasonSheetId reasonRange



-- 特性


traitSheetId =
    "1cyGpEw4GPI2k5snngBPKz7rfETklKdSaIBqQKnTta1w"


traitRange =
    "traitList!A2:B6"


traitSheetVersion =
    1.0


getTraits : Data -> Maybe String
getTraits data =
    getSpreasSheetData data traitSheetId traitRange traitSheetVersion


addTraits : Data -> String -> Data
addTraits data json =
    addSpreasSheetData traitSheetId traitRange traitSheetVersion json data


fetchTraits : (Result Http.Error String -> msg) -> String -> Cmd msg
fetchTraits toMsg apiKey =
    fetchSpreasSheetData toMsg apiKey traitSheetId traitRange



-- カード


cardSheetId =
    "1cyGpEw4GPI2k5snngBPKz7rfETklKdSaIBqQKnTta1w"


cardRange =
    "cardList!A2:U200"


cardSheetVersion =
    1.0


getCards : Data -> Maybe String
getCards data =
    getSpreasSheetData data cardSheetId cardRange cardSheetVersion


addCards : Data -> String -> Data
addCards data json =
    addSpreasSheetData cardSheetId cardRange cardSheetVersion json data


fetchCards : (Result Http.Error String -> msg) -> String -> Cmd msg
fetchCards toMsg apiKey =
    fetchSpreasSheetData toMsg apiKey cardSheetId cardRange



-- ユーザカード


userCardSheetId =
    "1JFGLFnPtBfPJdt7YccFSxki2MsqNUzUQmlyIGX4gyZE"


userCardRange =
    "cardList!A2:U100"


userCardSheetVersion =
    1.0


getUserCards : Data -> Maybe String
getUserCards data =
    getSpreasSheetData data userCardSheetId userCardRange userCardSheetVersion


addUserCards : Data -> String -> Data
addUserCards data json =
    addSpreasSheetData userCardSheetId userCardRange userCardSheetVersion json data


fetchUserCards : (Result Http.Error String -> msg) -> String -> Cmd msg
fetchUserCards toMsg apiKey =
    fetchSpreasSheetData toMsg apiKey userCardSheetId userCardRange



-- FAQ


faqSheetId =
    "1cyGpEw4GPI2k5snngBPKz7rfETklKdSaIBqQKnTta1w"


faqRange =
    "faqList!A2:B11"


faqSheetVersion =
    1.0


getFaqs : Data -> Maybe String
getFaqs data =
    getSpreasSheetData data faqSheetId faqRange faqSheetVersion


addFaqs : Data -> String -> Data
addFaqs data json =
    addSpreasSheetData faqSheetId faqRange faqSheetVersion json data


fetchFaqs : (Result Http.Error String -> msg) -> String -> Cmd msg
fetchFaqs toMsg apiKey =
    fetchSpreasSheetData toMsg apiKey faqSheetId faqRange



-- Character


getCharacter : Data -> String -> Maybe String
getCharacter data characterId =
    getJsonData data (FirestoreApi.characterUrlFromFireStore characterId)


addCharacter : Data -> String -> String -> Data
addCharacter data json characterId =
    addJsonData (FirestoreApi.characterUrlFromFireStore characterId) json data


fetchCharacter toMsg characterId =
    fetchJsonData toMsg (FirestoreApi.characterUrlFromFireStore characterId)



-- Characters


getCharacters : Data -> Maybe String
getCharacters data =
    getJsonData data FirestoreApi.charactersUrl


addCharacters : Data -> String -> Data
addCharacters data json =
    addJsonData FirestoreApi.charactersUrl json data


fetchCharacters toMsg =
    fetchJsonData toMsg FirestoreApi.charactersUrl
