module Models.Enemy exposing (Enemy, PageState(..))

import Array exposing (Array)
import FirestoreApi as FSApi
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E
import Models.Card as Card exposing (CardData)
import Models.Tag as Tag exposing (Tag)
import Utils.ModalWindow as Modal


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


type PageState
    = Create
    | Update
    | Read


type alias EditorModel msg =
    { cards : List Card.CardData
    , searchCardKind : String
    , modalTitle : String
    , modalContents : Modal.ModalContents msg
    , modalState : Modal.ModalState
    , isShowCardDetail : Bool
    }
