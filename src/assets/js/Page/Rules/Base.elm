module Page.Rules.Base exposing (character, commonRule, first, world)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


first : Html msg
first =
    section [ id "first" ]
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
        , div [ class "collection with-header" ]
            [ div [ class "collection-header" ] [ text "かっこの種類" ]
            , div [ class "collection-item" ] [ text "【】：キャラクターの〇を表す。" ]
            , div [ class "collection-item" ] [ text "《》：特技を表す。" ]
            , div [ class "collection-item" ] [ text "＜＞：このゲームで使われる固有名詞を表す。" ]
            ]
        , div [ class "collection with-header" ]
            [ div [ class "collection-header" ] [ text "端数の処理" ]
            , div [ class "collection-item" ] [ text "このゲームでは、割り算を行う場合、常に端数は切り上げとする。" ]
            ]
        ]


world =
    section [ id "world" ]
        [ h1 []
            [ text "ワールド" ]
        , h2 []
            [ text "異能因子発現個体群" ]
        , p
            [ class "content-doc" ]
            [ text """
特異な力を持った人間たちがこの世界には存在する。
獣の特徴を現し、人の限界を超えた運動能力を持った獣人。
見えない力を操る念動力者。
心の声を伝える精神感能力者。
炎、冷気、雷を生み出す変異体。
彼ら、異能の力を持ったものたちは異能因子発現個体群と称し研究対象とされた。
""" ]
        , h2 []
            [ text "箱庭の島 - ガーデン -" ]
        , p
            [ class "content-doc" ]
            [ text """
絶海に浮かぶ大きな島。
異能因子発現個体群の幼体の収集・管理・実験を目的とした隔離地域である。
島は管理団体ごとに高い壁で仕切られて各地区に分割されている。
各地区では研究施設、実験施設が林立し、研究者たちが各々様々な理論の研究・実証を行っていた。
""" ]
        , h2 []
            [ text "箱庭の中の箱庭 - 桜庭市 -" ]
        , p
            [ class "content-doc" ]
            [ text """
A2地区の臨海部に建造された東西90km南北40km程度の実験都市。
異能因子発現個体群と一般人が共存する環境の試験都市として建造された。
都市は地区を分割するのと同様の高い壁に囲まれている。
市内には小高い山、貯水池、緑地も設けられている。
学校もいくつも存在し、市内で進路もいくつか選べるようになっている。
異能因子発現個体群の研究施設も点在し、市内に家庭を持つ研究者たちが通勤している。
""" ]
        , h2 []
            [ text "崩壊の日" ]
        , p
            [ class "content-doc" ]
            [ text """
ある日、見えない力が島を覆い、大人たちは全滅した。
異能因子発現個体群の子供たちも、脳を揺さぶられるような力を受け取っている。
年齢の高いものほど力の影響が大きかった。
高校生以上の異能因子発現個体群は半数以上が精神に変調をきたし、異能を暴走させ狂い果てた。
""" ]
        , h2 []
            [ text "崩壊後の桜庭市" ]
        , p
            [ class "content-doc" ]
            [ text """
崩壊の日からしばらくは混乱が続いた。
管理する者たちがいなくなった街は火災・狂った異能因子発現個体による破壊、
研究施設から逃げ出した実験動物たちにより急速に荒廃していった。
混乱が落ち着いた後、街はいくつかの派閥に分かれた。
自分たちを閉じ込め、実験対象としてきた一般人に復讐すべきだという復讐派。
一般人と共に手を取り今後を考えるべきだという穏健派。
故郷に帰りたい脱出派。
崩壊の日を起こした者を解放の勇者だと崇めて探しだそうとする勇者探索派。
さらに、外部からも介入が入り始めている。
""" ]
        ]


character : Html msg
character =
    section [ id "character content-doc" ]
        [ h1 []
            [ text "キャラクター" ]
        , p
            []
            [ text """
プレイヤーの分身であるキャラクター（以下、PC)は、特異な力を持つ子供となる。
""" ]
        , h2 [] [ text "1. 変異器官の決定" ]
        , p
            []
            [ text """
異能の発生源となる変異器官を選択する。
""" ]
        ]
