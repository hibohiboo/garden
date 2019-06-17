module FirestoreApi exposing (characterUrl, int, intFromJson, string, stringFromJson)

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
    D.at [ "fields", target, "stringValue" ] D.string


intFromJson : String -> String -> Int
intFromJson target s =
    case D.decodeString (int target) s of
        Ok val ->
            val

        Err _ ->
            0


int : String -> D.Decoder Int
int target =
    D.at [ "fields", target, "integerValue" ] D.int
