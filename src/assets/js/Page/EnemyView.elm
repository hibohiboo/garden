module Page.EnemyView exposing (Model, Msg(..), init, update, view)

import Html exposing (text)
import Html.Attributes exposing (class)
import Http
import Models.Enemy as Enemy exposing (Enemy)
import Page.Views.EnemyView as EnemyView
import Session
import Skeleton exposing (viewLink, viewMain)
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , googleSheetApiKey : String
    , enemy : Enemy
    }


type Msg
    = GotEnemy (Result Http.Error String)


init : Session.Data -> String -> String -> ( Model, Cmd Msg )
init session apiKey enemyId =
    let
        enemy =
            Enemy.getEnemyFromSession session enemyId

        enemyCmd =
            case enemy of
                Just _ ->
                    Cmd.none

                Nothing ->
                    Session.fetchEnemy GotEnemy enemyId

        model =
            case enemy of
                Just e ->
                    Model session Close apiKey e

                Nothing ->
                    let
                        e =
                            Enemy.defaultEnemy
                    in
                    Model session Close apiKey { e | memo = "なうろーでぃんぐ" }
    in
    ( model, Cmd.batch [ enemyCmd ] )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotEnemy (Ok json) ->
            let
                enemy =
                    case Enemy.enemyDecoderFromFireStoreApiJson json of
                        Just e ->
                            e

                        Nothing ->
                            Enemy.defaultEnemy

                newModel =
                    { model
                        | enemy = enemy
                        , session = Session.addEnemy model.session json enemy.enemyId
                    }
            in
            ( newModel, Cmd.none )

        GotEnemy (Err _) ->
            ( model, Cmd.none )


view : Model -> Skeleton.Details Msg
view model =
    { title = model.enemy.name
    , attrs = [ class (getNavigationPageClass model.naviState), class "character-sheet" ]
    , kids = [ EnemyView.view model.enemy ]
    }
