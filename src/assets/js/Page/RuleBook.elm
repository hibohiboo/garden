module Page.RuleBook exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Skeleton exposing (viewLink)
import Url
import Url.Builder
import Utils.Terms as Terms


view : Skeleton.Details msg
view =
    { title = "基本ルール"
    , attrs = []
    , kids =
        [ div [ class "rulebook-title" ] [ div [] [ text Terms.trpgGenre ], h1 [] [ text "Garden 基本ルールブック" ] ]
        , div [ class "content" ] [ first ]
        ]
    }


first : Html msg
first =
    section []
        [ h1 []
            [ text "はじめに" ]
        , p
            [ class "content-doc" ]
            [ text """
ガーデンと呼ばれる絶海の孤島。
その島は異形の子供たちの研究施設であった。
ある日、見えない力が島を覆い、研究者たちは死に絶えた。
残された子供たち。逃げ出した実験動物。倒壊した建物。
彼らはこれからどのように生きるのか。
""" ]
        , p
            [ class "content-doc" ]
            [ text """
本ゲームは、孤島に集められた異形の子供を演じるゲームである。
プレイヤーの分身であるキャラクター（以下、PC)は、特異な力を持つ子供となる。
""" ]
        , commonRule
        ]


commonRule =
    section []
        [ h2 [ id "commonRule" ]
            [ text "このルールの読み方" ]
        , h3
            []
            [ text "かっこの種類" ]
        , ul []
            [ li [] [ text "【】：キャラクターの〇を表す。" ]
            , li [] [ text "《》：特技を表す。" ]
            , li [] [ text "＜＞：このゲームで使われる固有名詞を表す。" ]
            ]
        , h3 [] [ text "端数の処理" ]
        , p [] [ text "このゲームでは、割り算を行う場合、常に端数は切り上げとする。" ]
        ]
