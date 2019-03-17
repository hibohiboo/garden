module Skeleton exposing (Details, view, viewLink)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Builder


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
        "Garden - 箱庭の島の子供たち | " ++ details.title
    , body =
        [ -- Google Tag Manager (noscript)
          node "noscript"
            []
            [ iframe [ src "https://www.googletagmanager.com/ns.html?id=GTM-NM7RRXS", height 0, width 0, style "display" "none", style "visibility" "hidden" ] []
            ]
        , div [ class "page" ]
            [ viewHeader
            , main_ [ class "page-main" ]
                [ Html.map toMsg <|
                    div (class "center" :: details.attrs) details.kids
                ]
            , viewNav
            , button [ type_ "button", class "page-btn" ] [ span [ class "fas fa-bars", title "メニューを開く" ] [] ]
            , button [ type_ "button", class "page-btn-close" ] [ span [ class "fas fa-times", title "メニューを閉じる" ] [] ]
            , viewFooter
            ]
        ]
    }


viewHeader : Html msg
viewHeader =
    header [ class "page-head" ]
        [ a [ href "/" ]
            [ img [ src "/assets/images/toy_hakoniwa.png" ] []
            ]
        ]


viewNav : Html msg
viewNav =
    nav [ class "page-nav" ]
        [ ul []
            [ li [] [ a [ href (Url.Builder.absolute [ "" ] []) ] [ text "トップ" ] ]
            , li [] [ a [ href (Url.Builder.absolute [ "rulebook" ] []) ] [ text "ルールブック" ] ]
            , li [] [ a [ href (Url.Builder.absolute [ "privacy-policy" ] []) ] [ text "プライバシーポリシー" ] ]
            , li [] [ a [ href (Url.Builder.absolute [ "about" ] []) ] [ text "このサイトについて" ] ]
            ]
        ]


viewFooter : Html msg
viewFooter =
    footer [ class "page-footer" ] [ text "©hibo" ]
