module Page.Views.Form exposing (OnChangeIndexMsg, OnChangeMsg, addButton, deleteButton, inputArea, inputNumberArea, inputTextArea)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Events.Extra exposing (onChange)


type alias OnChangeMsg msg =
    String -> msg


type alias OnChangeIndexMsg msg =
    Int -> OnChangeMsg msg


inputArea : String -> String -> String -> OnChangeMsg msg -> Html msg
inputArea =
    inputAreaHelper "text"


inputNumberArea : String -> String -> Int -> OnChangeMsg msg -> Html msg
inputNumberArea fieldId labelName val toMsg =
    inputAreaHelper "number" fieldId labelName (String.fromInt val) toMsg


inputAreaHelper : String -> String -> String -> String -> OnChangeMsg msg -> Html msg
inputAreaHelper t fieldId labelName val toMsg =
    div [ class "input-field" ]
        [ input [ placeholder labelName, id fieldId, type_ t, class "validate", value val, onChange toMsg ] []
        , label [ class "active", for fieldId ] [ text labelName ]
        ]


inputTextArea fieldId labelName val toMsg =
    div [ class "input-field" ]
        [ textarea [ placeholder "labelName", id fieldId, class "materialize-textarea", value val, onChange toMsg, style "height" "200px", style "overflow-y" "auto" ] []
        , label [ class "active", for fieldId ] [ text labelName ]
        ]


addButton : String -> msg -> List (Html msg)
addButton labelName addMsg =
    [ text (labelName ++ "を追加  ")
    , button [ class "btn-floating btn-small waves-effect waves-light green", onClick addMsg ] [ i [ class "material-icons" ] [ text "add" ] ]
    ]


deleteButton : msg -> Html msg
deleteButton deleteMsg =
    button [ class "btn-small waves-effect waves-light grey", onClick deleteMsg ] [ i [ class "material-icons" ] [ text "delete" ] ]
