module Skeleton exposing (Details, view, viewLink)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)


type alias Details msg =
    { title : String
    , attrs : List (Attribute msg)
    , kids : List (Html msg)
    }


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]


view : (a -> msg) -> Details a -> Browser.Document msg
view toMsg details =
    { title =
        details.title
    , body =
        [ viewHeader
        , Html.map toMsg <|
            div (class "center" :: details.attrs) details.kids
        , viewFooter
        ]
    }


viewHeader : Html msg
viewHeader =
    header [] []


viewFooter : Html msg
viewFooter =
    footer [] []
