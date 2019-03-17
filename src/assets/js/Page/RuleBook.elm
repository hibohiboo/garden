module Page.RuleBook exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Skeleton exposing (viewLink)
import Url
import Url.Builder


view : Html msg
view =
    viewRuleBookPage


viewRuleBookPage : Html msg
viewRuleBookPage =
    ul []
        [ text "test"
        ]
