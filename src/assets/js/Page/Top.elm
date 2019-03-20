module Page.Top exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Skeleton exposing (NaviState(..), NavigationMenu, getNavigationPageClass, viewLink, viewMain, viewNav)
import Url
import Url.Builder
import Utils.Terms as Terms


type alias Model =
    { naviState : NaviState
    }


init : ( Model, Cmd Msg )
init =
    ( Model Close
    , Cmd.none
    )


type Msg
    = ToggleNavigation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            let
                ns =
                    case model.naviState of
                        Close ->
                            Open

                        Open ->
                            Close
            in
            ( { model | naviState = ns }, Cmd.none )


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "トップページ"
    , attrs = [ class naviClass ]
    , kids =
        [ viewMain viewTopPage
        , viewNav [ NavigationMenu "" "トップ", NavigationMenu "rulebook" "ルールブック" ]
        , button [ onClick ToggleNavigation, type_ "button", class "navi-btn page-btn" ] [ span [ class "fas fa-bars", title "メニューを開く" ] [] ]
        , button [ onClick ToggleNavigation, type_ "button", class "navi-btn page-btn-close" ] [ span [ class "fas fa-times", title "メニューを閉じる" ] [] ]
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
        , p
            [ class "content-doc" ]
            [ text """
ガーデンと呼ばれる絶海の孤島。
その島は異形の子供たちの研究施設であった。
ある日、見えない力が島を覆い、研究者たちは死に絶えた。
残された子供たち。逃げ出した実験動物。倒壊した建物。
彼らはこれからどのように生きるのか。
""" ]
        , ul []
            [ li [] [ a [ href (Url.Builder.absolute [ "rulebook" ] []) ] [ text "ルールを読む" ] ]
            ]
        ]
