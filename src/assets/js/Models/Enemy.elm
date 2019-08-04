module Models.Enemy exposing
    ( EditorModel
    , Enemy
    , PageState(..)
    , defaultEditorModel
    , defaultEnemy
    , setEnemyName
    )

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
    , cardImageData : String
    , kana : String
    , degreeOfThreat : Int
    , tags : List Tag
    , cards : Array CardData
    , cardImageCreatorName : String
    , cardImageCreatorSite : String
    , cardImageCreatorUrl : String
    }


defaultEnemy : Enemy
defaultEnemy =
    Enemy "" "" 0 "" "" "" "" 0 [] Array.empty "" "" ""


setEnemyName : String -> Enemy -> Enemy
setEnemyName name enemy =
    { enemy | name = name }


type PageState
    = Create
    | Update
    | Read


type alias EditorModel msg =
    { editingEnemy : Enemy
    , isCreateState : Bool
    , cards : List Card.CardData
    , searchCardKind : String
    , modalTitle : String
    , modalContents : Modal.ModalContents msg
    , modalState : Modal.ModalState
    , isShowCardDetail : Bool
    }


defaultEditorModel : EditorModel msg
defaultEditorModel =
    EditorModel defaultEnemy True [] "" "" Modal.defaultModalContents Modal.Close False
