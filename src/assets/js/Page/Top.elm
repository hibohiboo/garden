module Page.Top exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Skeleton exposing (viewLink)
import Url
import Url.Builder


view : Skeleton.Details msg
view =
    { title = "トップページ"
    , attrs = []
    , kids =
        [ viewTopPage
        ]
    }


viewTopPage : Html msg
viewTopPage =
    ul []
        [ li [] [ a [ href (Url.Builder.absolute [ "rulebook" ] []) ] [ text "ルールブック" ] ]
        , li [] [ a [ href (Url.Builder.absolute [ "privacy-policy" ] []) ] [ text "プライバシーポリシー" ] ]
        , li [] [ a [ href (Url.Builder.absolute [ "about" ] []) ] [ text "このサイトについて" ] ]
        ]
