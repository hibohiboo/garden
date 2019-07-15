module Page.EnemyList exposing (Model, Msg, init, initModel, update, view)

import FirestoreApi as FSApi
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
import Page.Views.Enemy exposing (enemyList)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , enemies : List EnemyListItem
    }


init : Session.Data -> ( Model, Cmd Msg )
init session =
    let
        enemies =
            case Session.getEnemies session of
                Just json ->
                    EnemyListItem.enemyListFromJson json

                Nothing ->
                    []

        cmd =
            if enemies == [] then
                Session.fetchEnemies GotEnemies

            else
                Cmd.none
    in
    ( initModel session enemies
    , cmd
    )


initModel : Session.Data -> List EnemyListItem -> Model
initModel session enemies =
    Model session Close enemies


type Msg
    = ToggleNavigation
    | GotEnemies (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        GotEnemies (Ok json) ->
            ( updateEnemiesModel model json, Cmd.none )

        GotEnemies (Err _) ->
            ( model, Cmd.none )


updateEnemiesModel : Model -> String -> Model
updateEnemiesModel model json =
    { model
        | enemies = EnemyListItem.enemyListFromJson json
        , session = Session.addEnemies model.session json
    }


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "エネミーリスト"
    , attrs = [ class naviClass ]
    , kids =
        [ viewMain (viewTopPage model)
        , viewNav [ NavigationMenu "" "トップ", NavigationMenu "rulebook" "ルールブック", NavigationMenu "mypage" "マイページ" ]
        , openNavigationButton ToggleNavigation
        , closeNavigationButton ToggleNavigation
        ]
    }


viewTopPage : Model -> Html msg
viewTopPage model =
    div []
        [ div [ class "" ]
            [ h1 [ class "center", style "font-size" "3rem" ] [ text " エネミー一覧" ]
            ]
        , div [] [ enemyList model.enemies ]
        ]
