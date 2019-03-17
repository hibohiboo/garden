module Page.RuleBook exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Skeleton exposing (viewLink)
import Url
import Url.Builder


view : Skeleton.Details msg
view =
    { title = "ルールブック"
    , attrs = []
    , kids =
        [ ul []
            [ text "test"
            ]
        ]
    }
