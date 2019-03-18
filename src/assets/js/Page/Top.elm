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
    div [ class "center" ]
        [ div [ class "top-header" ]
            [ h1 [] [ text "Garden" ]
            , h2 [] [ text "～ 箱庭の島の子供たち ～" ]
            ]
        , p []
            [ text "海上に浮かぶ一つの島。"
            ]
        , p []
            [ text "その島は「 箱庭の島 - Graden 」と呼ばれている。"
            ]
        , p []
            [ text "獣の特徴を発現させた獣人。"
            ]
        , p []
            [ text "燃焼剤、冷却剤、電流などを生み出す臓器を持った変異種。"
            ]
        , p []
            [ text "不可視の力を操る念動力者。"
            ]
        , p []
            [ text "心を見透かす感能力者。"
            ]
        , p []
            [ text "異形の器官を持った突然変異の子供たち。"
            ]
        , p []
            [ text "日々、観察・実験が行われていた。"
            ]
        , p []
            [ text "ある日、協力な不可視の力が島全体を揺るがし、大人たちは全滅した。"
            ]
        , p []
            [ text "未成年の年長者も多くは狂い、暴走した。"
            ]
        , p []
            [ text "非道な実験を行う研究者はもういない。"
            ]
        , p []
            [ text "閉じ込めていた見張りはもういない。"
            ]
        , p []
            [ text "優しく声をかけ続けたカウンセラーはもういない。"
            ]
        , p []
            [ text "知らないことをいっぱい教えてくれた先生はもういない。"
            ]
        , p []
            [ text "残された子供たちはこれからどう生きるのか。"
            ]
        , ul []
            [ li [] [ a [ href (Url.Builder.absolute [ "rulebook" ] []) ] [ text "ルールを読む" ] ]
            ]
        ]
