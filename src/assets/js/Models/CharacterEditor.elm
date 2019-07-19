module Models.CharacterEditor exposing (EditorModel, cardDetailClass, initEditor)

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


cardDetailClass : Bool -> String
cardDetailClass isShowCardDetail =
    if isShowCardDetail then
        ""

    else
        "hide"
