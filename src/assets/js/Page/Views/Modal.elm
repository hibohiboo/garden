module Page.Views.Modal exposing (modalCardOpenButton)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


modalCardOpenButton : msg -> String -> Html msg
modalCardOpenButton modalMsg title =
    div [ onClick modalMsg, class "waves-effect waves-light btn" ] [ text title ]
