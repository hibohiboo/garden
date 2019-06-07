module Models.CharacterEditor exposing (EditorModel, initEditor)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models.Card as Card
import Utils.ModalWindow as Modal


type alias EditorModel msg =
    { organs : List ( String, String )
    , traits : List ( String, String )
    , cards : List Card.CardData
    , searchCardKind : String
    , modalTitle : String
    , modalContents : Html msg
    , modalState : Modal.ModalState
    }


initEditor : EditorModel msg
initEditor =
    EditorModel [] [] [] "" "" (text "") Modal.Close
