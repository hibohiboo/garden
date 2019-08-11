module Page.Views.Form exposing (OnChangeMsg, inputArea, inputNumberArea, inputTextArea)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events.Extra exposing (onChange)


type alias OnChangeMsg msg =
    String -> msg


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
