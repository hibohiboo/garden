module Page.RuleBook exposing (Model, Msg(..), init, update, view)

import Browser.Dom as Dom
import Browser.Navigation as Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Skeleton exposing (viewLink, viewMain)
import Task exposing (..)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.Terms as Terms


type alias Model =
    { naviState : NaviState
    , id : String
    }


init : Maybe String -> ( Model, Cmd Msg )
init s =
    case s of
        Just id ->
            ( Model Close id, jumpToBottom id )

        Nothing ->
            ( initModel
            , Cmd.none
            )


initModel : Model
initModel =
    Model Close ""


type Msg
    = ToggleNavigation
    | NoOp
    | PageAnchor String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        PageAnchor id ->
            ( model, Navigation.load id )


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "基本ルール"
    , attrs = [ class naviClass ]
    , kids =
        [ viewMain viewRulebook
        , viewNavi [ NavigationMenu "#first" "はじめに", NavigationMenu "#world" "ワールド" ]
        , openNavigationButton ToggleNavigation
        , closeNavigationButton ToggleNavigation
        ]
    }


viewNavi : List NavigationMenu -> Html Msg
viewNavi menues =
    let
        navigations =
            List.map
                (\menu ->
                    li []
                        [ a [ href "#", onClick (PageAnchor menu.src) ] [ text menu.text ]
                        ]
                )
                menues
    in
    nav [ class "page-nav" ]
        [ ul []
            navigations
        ]


tableOfContents : List ( String, String )
tableOfContents =
    [ ( "first", "はじめに" ), ( "world", "ワールド" ) ]


viewRulebook : Html msg
viewRulebook =
    div []
        [ div [ class "rulebook-title" ] [ div [] [ text Terms.trpgGenre ], h1 [] [ text "Garden 基本ルールブック" ] ]
        , div [ class "content" ] [ first, world, character ]
        ]


jumpToBottom : String -> Cmd Msg
jumpToBottom id =
    Dom.getViewportOf id
        |> Task.andThen (\info -> Dom.setViewportOf id 0 info.scene.height)
        |> Task.attempt (\_ -> NoOp)


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
    section [ id "character" ]
        [ h1 []
            [ text "キャラクター" ]
        , p
            [ class "content-doc" ]
            [ text """
プレイヤーの分身であるキャラクター（以下、PC)は、特異な力を持つ子供となる。
""" ]
        ]
