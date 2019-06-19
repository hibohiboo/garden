module FirestoreApi exposing (arrayFromJson, bool, boolFromJson, characterUrl, charactersUrl, fields, int, intFromJson, string, stringFromJson, timestamp, timestampFromJson)

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


fields : D.Decoder a -> D.Decoder a
fields decoder =
    D.at [ "fields" ] decoder


string : D.Decoder String
string =
    D.at [ "stringValue" ] D.string


int : D.Decoder Int
int =
    D.map (\x -> Maybe.withDefault 0 (String.toInt x)) <| D.at [ "integerValue" ] D.string


timestamp : D.Decoder String
timestamp =
    D.at [ "timestampValue" ] D.string


bool : D.Decoder Bool
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


decodeFromJsonHelper : D.Decoder a -> a -> String -> a
decodeFromJsonHelper decoder defaultValue s =
    case D.decodeString decoder s of
        Ok val ->
            val

        Err _ ->
            defaultValue
