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
        [ div [ class "rulebook-title" ] [ div [] [ text "孤島異能研究機関崩壊後TRPG" ], h1 [] [ text "Garden 基本ルールブック" ] ]
        , div [ class "content" ] [ section1 ]
        ]
    }


section1 : Html msg
section1 =
    section []
        [ h1 []
            [ text "はじめに" ]
        , p
            [ class "content-doc" ]
            [ text """
ガーデンと呼ばれる絶海の孤島に。
その島は異形の子供たちの研究施設であった。
ある日、見えない力が島を覆い、研究者たちは死に絶えた。
残された子供たち。
これからどう生きていくのか。
""" ]
        , p
            [ class "content-doc" ]
            [ text """
本ゲームは、孤島に集められた異形の子供を演じるゲームである。
プレイヤーの分身であるキャラクター（以下、PC)は、特異な力を持つ子供となる。
""" ]
        ]
