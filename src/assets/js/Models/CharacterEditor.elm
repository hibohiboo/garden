module Models.CharacterEditor exposing (EditorModel, closeModal, initEditor, showModal)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models.Card as Card
import Utils.ModalWindow as Modal


type alias EditorModel msg =
    { reasons : List ( String, String )
    , traits : List ( String, String )
    , cards : List Card.CardData
    , searchCardKind : String
    , modalTitle : String
    , modalContents : Html msg
    , modalState : Modal.ModalState
    , isShowCardDetail : Bool
    }


initEditor : EditorModel msg
initEditor =
    EditorModel [] [] [] "" "" (text "") Modal.Close False


showModal : EditorModel msg -> EditorModel msg
showModal modal =
    { modal | modalState = Modal.Open }


closeModal : EditorModel msg -> EditorModel msg
closeModal modal =
    { modal | modalState = Modal.Close }
