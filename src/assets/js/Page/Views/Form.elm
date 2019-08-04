module Page.Views.Form exposing (OnChangeMsg, inputArea)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events.Extra exposing (onChange)


type alias OnChangeMsg msg =
    String -> msg


inputArea : String -> String -> String -> (String -> msg) -> Html msg
inputArea fieldId labelName val toMsg =
    div [ class "input-field" ]
        [ input [ placeholder labelName, id fieldId, type_ "text", class "validate", value val, onChange toMsg ] []
        , label [ class "active", for fieldId ] [ text labelName ]
        ]
