module FirestoreApi exposing (array, arrayFromJson, bool, boolFromJson, characterDetailsUrlWithPageToken, characterUrl, characterUrlFromFireStore, charactersUrl, charactersUrlWithLimit, charactersUrlWithPageToken, enemiesUrl, fields, int, intFromJson, list, nextTokenFromJson, string, stringFromJson, timestamp, timestampFromJson)

import Array exposing (Array)
import Json.Decode as D exposing (Decoder)



-- functionsを使った取得URL


storeUrl =
    "https://garden-2a6de.firebaseapp.com/api/v1"


characterUrl : String -> String
characterUrl characterId =
    storeUrl ++ "/characters/" ++ characterId


databaseUrl =
    "https://firestore.googleapis.com/v1/projects/garden-2a6de/databases"


charactersUrl : String
charactersUrl =
    databaseUrl ++ "/(default)/documents/publish/all/characters/"


pageLimit : Int
pageLimit =
    10


charactersUrlWithLimit : String
charactersUrlWithLimit =
    charactersUrl ++ "?pageSize=" ++ String.fromInt pageLimit


charactersUrlWithPageToken : String -> String
charactersUrlWithPageToken token =
    charactersUrl ++ "?pageSize=" ++ String.fromInt pageLimit ++ "&pageToken=" ++ token


characterUrlFromFireStore characterId =
    databaseUrl ++ "/(default)/documents/characters/" ++ characterId


characterDetailsUrl : String
characterDetailsUrl =
    databaseUrl ++ "/(default)/documents/characters/"


characterDetailsUrlWithPageToken : String -> String
characterDetailsUrlWithPageToken token =
    characterDetailsUrl ++ "?pageSize=" ++ String.fromInt pageLimit ++ "&pageToken=" ++ token


enemiesUrl : String
enemiesUrl =
    -- 登録画面未作成なので、取得できるjsonに似せたjsonファイルを直接読む。
    -- databaseUrl ++ "/(default)/documents/publish/all/enemies/"
    "/assets/json/enemies.json"



-- デコーダ


fields : Decoder a -> Decoder a
fields decoder =
    D.at [ "fields" ] decoder


list : Decoder a -> Decoder (List a)
list decoder =
    D.at [ "arrayValue", "values" ] <| D.list (D.at [ "mapValue", "fields" ] decoder)


array : Decoder a -> Decoder (Array a)
array decoder =
    D.at [ "arrayValue", "values" ] <| D.array (D.at [ "mapValue", "fields" ] decoder)


string : Decoder String
string =
    D.at [ "stringValue" ] D.string


int : Decoder Int
int =
    D.map (\x -> Maybe.withDefault 0 (String.toInt x)) <| D.at [ "integerValue" ] D.string


timestamp : Decoder String
timestamp =
    D.at [ "timestampValue" ] D.string


bool : Decoder Bool
bool =
    D.at [ "booleanValue" ] D.bool



-- テスト用
-- TODO:


arrayFromJson target s =
    True


stringFromJson : String -> String -> String
stringFromJson target s =
    decodeFromJsonHelper (fields (D.at [ target ] string)) "" s


intFromJson : String -> String -> Int
intFromJson target s =
    decodeFromJsonHelper (fields (D.at [ target ] int)) 0 s


timestampFromJson : String -> String -> String
timestampFromJson target s =
    decodeFromJsonHelper (fields (D.at [ target ] timestamp)) "" s


boolFromJson : String -> String -> Bool
boolFromJson target s =
    decodeFromJsonHelper (fields (D.at [ target ] bool)) False s


decodeFromJsonHelper : Decoder a -> a -> String -> a
decodeFromJsonHelper decoder defaultValue s =
    case D.decodeString decoder s of
        Ok val ->
            val

        Err _ ->
            defaultValue


nextTokenDecoder : Decoder String
nextTokenDecoder =
    D.at [ "nextPageToken" ] D.string


nextTokenFromJson : String -> String
nextTokenFromJson json =
    case D.decodeString nextTokenDecoder json of
        Ok token ->
            token

        Err _ ->
            ""
