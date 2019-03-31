module Page.Top exposing (Model, Msg, init, initModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    }


init : Session.Data -> ( Model, Cmd Msg )
init session =
    ( initModel session
    , Cmd.none
    )


initModel : Session.Data -> Model
initModel session =
    Model session Close


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
    { title = "トップページ"
    , attrs = [ class naviClass ]
    , kids =
        [ viewMain viewTopPage
        , viewNav [ NavigationMenu "" "トップ", NavigationMenu "rulebook" "ルールブック", NavigationMenu "mypage" "マイページ" ]
        , openNavigationButton ToggleNavigation
        , closeNavigationButton ToggleNavigation
        ]
    }


viewTopPage : Html msg
viewTopPage =
    div [ class "center" ]
        [ div [ class "top-header" ]
            [ div [] [ text "孤島異能研究機関崩壊後TRPG" ]
            , h1 [] [ text "Sandbox Garden" ]
            , h2 [] [ text "～ 箱庭の島の子供たち ～" ]
            , a [ class "top-image", href (Url.Builder.absolute [ "rulebook" ] []) ] [ img [ src "/assets/images/childrens.png" ] [] ]
            ]
        , p
            [ class "content-doc" ]
            [ text """
コワレタセカイデアソビタイ
""" ]
        , ul []
            [ li [] [ a [ href (Url.Builder.absolute [ "rulebook" ] []) ] [ text "ルールを読む" ] ]
            ]
        ]
