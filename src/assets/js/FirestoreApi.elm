module FirestoreApi exposing (bool, boolFromJson, characterUrl, int, intFromJson, string, stringFromJson, timestamp, timestampFromJson)

import Json.Decode as D



-- functionsを使った取得URL


storeUrl =
    "https://garden-2a6de.firebaseapp.com/api/v1"


characterUrl : String -> String
characterUrl characterId =
    storeUrl ++ "/characters/" ++ characterId



-- デコーダ


stringFromJson : String -> String -> String
stringFromJson target s =
    case D.decodeString (string target) s of
        Ok val ->
            val

        Err _ ->
            ""


string : String -> D.Decoder String
string target =
    stringHelper "stringValue" target


stringHelper : String -> String -> D.Decoder String
stringHelper type_ target =
    jsonHelper D.string type_ target


jsonHelper : D.Decoder a -> String -> String -> D.Decoder a
jsonHelper decoder type_ target =
    D.at [ "fields", target, type_ ] decoder


intFromJson : String -> String -> Int
intFromJson target s =
    case D.decodeString (int target) s of
        Ok val ->
            val

        Err _ ->
            0


int : String -> D.Decoder Int
int target =
    jsonHelper D.int "integerValue" target


timestampFromJson : String -> String -> String
timestampFromJson target s =
    case D.decodeString (timestamp target) s of
        Ok val ->
            val

        Err _ ->
            ""


timestamp : String -> D.Decoder String
timestamp =
    stringHelper "timestampValue"


boolFromJson : String -> String -> Bool
boolFromJson target s =
    case D.decodeString (bool target) s of
        Ok val ->
            val

        Err _ ->
            False


bool : String -> D.Decoder Bool
bool target =
    jsonHelper D.bool "booleanValue" target
