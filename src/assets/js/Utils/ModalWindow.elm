module Utils.ModalWindow exposing (ModalContents, ModalState(..), defaultModalContents, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


type alias ModalContents msg =
    Html msg


defaultModalContents : ModalContents msg
defaultModalContents =
    text ""


type ModalState
    = Open
    | Close


view : String -> Html msg -> ModalState -> msg -> Html msg
view title content state closeMsg =
    let
        openClass =
            case state of
                Open ->
                    "open"

                Close ->
                    ""
    in
    div []
        [ div [ id "mainModal", class ("modal " ++ openClass), style "z-index" "1002" ]
            [ div [ class "modal-content" ]
                [ h4 [] [ text title ]
                , div [] [ content ]
                ]
            , div [ class "modal-footer" ]
                [ button [ class "modal-close waves-effect waves-lignt btn-flat btn", onClick closeMsg ] [ text "閉じる" ]
                ]
            ]
        , div [ class ("modal-overlay " ++ openClass), style "z-index" "1001", onClick closeMsg ] []
        ]
