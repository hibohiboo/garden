module Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, getNavigationPageClass, toggleNavigationState, viewNav)

import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Builder


type alias NavigationMenu =
    { src : String
    , text : String
    }


type NaviState
    = Open
    | Close


viewNav : List NavigationMenu -> Html msg
viewNav menues =
    let
        navigations =
            List.map (\menu -> li [] [ a [ href (Url.Builder.absolute [ menu.src ] []) ] [ text menu.text ] ]) menues
    in
    nav [ class "page-nav" ]
        [ ul []
            navigations
        ]


toggleNavigationState : NaviState -> NaviState
toggleNavigationState naviState =
    case naviState of
        Close ->
            Open

        Open ->
            Close


getNavigationPageClass : NaviState -> String
getNavigationPageClass naviState =
    -- ナビゲーションの状態によってページに持たせるクラスを変える
    case naviState of
        Close ->
            ""

        Open ->
            "open"
