module Page.RuleBook exposing (Model, Msg(..), init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.Terms as Terms


type alias Model =
    { naviState : NaviState
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )


initModel : Model
initModel =
    Model Close


type Msg
    = ToggleNavigation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )


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
        , viewNav [ NavigationMenu "" "トップ", NavigationMenu "rulebook" "ルールブック" ]
        , openNavigationButton ToggleNavigation
        , closeNavigationButton ToggleNavigation
        ]
    }


viewRulebook : Html msg
viewRulebook =
    div []
        [ div [ class "rulebook-title" ] [ div [] [ text Terms.trpgGenre ], h1 [] [ text "Garden 基本ルールブック" ] ]
        , div [ class "content" ] [ first ]
        ]


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
