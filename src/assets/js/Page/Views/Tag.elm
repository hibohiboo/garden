module Page.Views.Tag exposing (tag)

import Html exposing (..)
import Html.Attributes exposing (..)


tag : String -> Html msg
tag tagText =
    span [ class "tag" ] [ text tagText ]
