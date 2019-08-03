module Models.Enemy exposing (Enemy)

import Array exposing (Array)
import FirestoreApi as FSApi
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E
import Models.Card as Card exposing (CardData)
import Models.Tag as Tag exposing (Tag)


type alias Enemy =
    { enemyId : String
    , name : String
    , activePower : Int
    , memo : String
    , cardImage : String
    , kana : String
    , degreeOfThreat : Int
    , tags : List Tag
    , cards : Array CardData
    }
