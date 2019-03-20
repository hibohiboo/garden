module Skeleton exposing (Details, view, viewLink, viewMain)

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
        , Html.map toMsg <|
            div (class "page" :: details.attrs)
                (viewHeader
                    :: List.append
                        details.kids
                        [ viewFooter ]
                )
        ]
    }


viewMain : Html msg -> Html msg
viewMain m =
    main_ [ class "page-main" ]
        [ m ]


viewHeader : Html msg
viewHeader =
    header [ class "page-head" ]
        [ a [ href "/" ]
            [ img [ src "/assets/images/toy_hakoniwa.png" ] []
            ]
        ]


viewFooter : Html msg
viewFooter =
    footer [ class "page-foot" ]
        [ span [ class "copy-right" ] [ text "©hibo" ]
        , aside [ class "sns-icons" ]
            [ ul []
                [ li []
                    [ a [ href "https://twitter.com/hibohiboo", target "_blank" ]
                        [ span [ class "fab fa-twitter", title "Twitter" ] []
                        ]
                    ]
                , li []
                    [ a [ href "https://github.com/hibohiboo/garden", target "_blank" ]
                        [ span [ class "fab fa-github", title "Github" ] []
                        ]
                    ]
                ]
            ]
        , ul [ class "foot-links" ]
            [ li [] [ a [ href (Url.Builder.absolute [ "privacy-policy" ] []) ] [ text "プライバシーポリシー" ] ]
            , li [] [ a [ href (Url.Builder.absolute [ "about" ] []) ] [ text "このサイトについて" ] ]
            ]
        ]
