module Page.Top exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Skelton exposing (viewLink)
import Url
import Url.Builder


view : Html msg
view =
    viewTopPage


viewTopPage : Html msg
viewTopPage =
    ul []
        [ viewLink (Url.Builder.absolute [ "elm" ] [])
        , viewLink (Url.Builder.absolute [ "hibohiboo" ] [])
        ]
