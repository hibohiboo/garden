module Page.Top exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Skeleton exposing (viewLink)
import Url
import Url.Builder
import Utils.Terms as Terms


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
    div [ class "center" ]
        [ div [ class "top-header" ]
            [ div [] [ text Terms.trpgGenre ]
            , h1 [] [ text "Garden" ]
            , h2 [] [ text "～ 箱庭の島の子供たち ～" ]
            , a [ class "top-image", href (Url.Builder.absolute [ "rulebook" ] []) ] [ img [ src "/assets/images/childrens.jpg" ] [] ]
            ]
        , p []
            [ text "海上に浮かぶ一つの島。"
            ]
        , p []
            [ text "その島は「 箱庭の島 - Graden 」と呼ばれている。"
            ]
        , p []
            [ text "異形の器官を持った突然変異の子供たちが集められ、日々、観察・実験が行われていた。"
            ]
        , p []
            [ text "ある日、協力な不可視の力が島全体を揺るがした。 " ]
        , p []
            [ text "大人たちは全滅し、年長者は狂い果てた。"
            ]
        , p []
            [ text "非道な実験を行う研究者も、優しく声をかけてくれたカウンセラーも、もういない。"
            ]
        , p []
            [ text "残された子供たちはこれからどう生きるのか。"
            ]
        , ul []
            [ li [] [ a [ href (Url.Builder.absolute [ "rulebook" ] []) ] [ text "ルールを読む" ] ]
            ]
        ]
