module FirestoreApi exposing (arrayFromJson, bool, boolFromJson, characterUrl, charactersUrl, int, intFromJson, jsonHelper, string, stringFromJson, timestamp, timestampFromJson)

import Json.Decode as D



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



-- デコーダ


string : String -> D.Decoder String
string target =
    stringHelper "stringValue" target


stringHelper : String -> String -> D.Decoder String
stringHelper type_ target =
    jsonHelper type_ target D.string


jsonHelper : String -> String -> D.Decoder a -> D.Decoder a
jsonHelper type_ target decoder =
    D.at [ "fields", target, type_ ] decoder


int : String -> D.Decoder Int
int target =
    D.map (\x -> Maybe.withDefault 0 (String.toInt x)) <| jsonHelper "integerValue" target D.string


timestamp : String -> D.Decoder String
timestamp =
    stringHelper "timestampValue"


bool : String -> D.Decoder Bool
bool target =
    jsonHelper "booleanValue" target D.bool



-- テスト用
-- TODO:


arrayFromJson target s =
    True


stringFromJson : String -> String -> String
stringFromJson target s =
    case D.decodeString (string target) s of
        Ok val ->
            val

        Err _ ->
            ""


intFromJson : String -> String -> Int
intFromJson =
    decodeFromJsonHelper int 0


timestampFromJson : String -> String -> String
timestampFromJson =
    decodeFromJsonHelper timestamp ""


boolFromJson : String -> String -> Bool
boolFromJson target s =
    decodeFromJsonHelper bool False target s


decodeFromJsonHelper : (String -> D.Decoder a) -> a -> String -> String -> a
decodeFromJsonHelper decoder defaultValue target s =
    case D.decodeString (decoder target) s of
        Ok val ->
            val

        Err _ ->
            defaultValue
