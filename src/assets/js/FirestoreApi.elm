module FirestoreApi exposing (characterUrl)

-- functionsを使った取得URL


storeUrl =
    "https://garden-2a6de.firebaseapp.com/api/v1"


characterUrl : String -> String
characterUrl characterId =
    storeUrl ++ "/characters/" ++ characterId



-- "2fckXdCG5o5ZensdgmBZ"
