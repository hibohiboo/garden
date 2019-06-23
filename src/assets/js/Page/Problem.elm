module Page.Problem exposing
    ( notFound
    , offline
    , styles
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Skeleton exposing (viewLink, viewMain)
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)



-- type alias Model =
--     { naviState : NaviState
--     }
-- type Msg
--     = ToggleNavigation
-- update : Msg -> Model -> ( Model, Cmd Msg )
-- update msg model =
--     case msg of
--         ToggleNavigation ->
--             ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )
-- NOT FOUND


notFound : List (Html msg)
notFound =
    [ viewMain notFoundMain
    , viewNav [ NavigationMenu "" "トップ" ]

    -- , openNavigationButton ToggleNavigation
    -- , closeNavigationButton ToggleNavigation
    ]


notFoundMain =
    div []
        [ div [ style "font-size" "12em" ] [ text "404" ]
        , div [ style "font-size" "3em" ] [ text "I cannot find this page!" ]
        ]


styles : List (Attribute msg)
styles =
    [ style "text-align" "center"
    , style "color" "#9A9A9A"
    , style "padding" "6em 0"
    ]



-- OFFLINE


offline : String -> List (Html msg)
offline file =
    [ div [ style "font-size" "3em" ]
        [ text "Cannot find "
        , code [] [ text file ]
        ]
    , p [] [ text "Are you offline or something?" ]
    ]
