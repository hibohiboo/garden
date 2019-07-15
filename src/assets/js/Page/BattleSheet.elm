module Page.BattleSheet exposing (Model, Msg, init, initModel, update, view)

import Array exposing (Array)
import FirestoreApi as FSApi
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Models.BattleSheet exposing (BattleSheetEnemy, initBatlleSheetEnemy, updateBatlleSheetEnemyActivePower, updateBatlleSheetEnemyName)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
import Page.Views.BattleSheet exposing (countArea, countController, inputEnemies)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.Util exposing (deleteAt)


type alias Model =
    { session : Session.Data
    , enemyList : List EnemyListItem
    , count : Int
    , modalState : Modal.ModalState
    , enemies : Array BattleSheetEnemy
    }


init : Session.Data -> ( Model, Cmd Msg )
init session =
    let
        enemyList =
            case Session.getEnemies session of
                Just json ->
                    EnemyListItem.enemyListFromJson json

                Nothing ->
                    []

        cmd =
            if enemyList == [] then
                Session.fetchEnemies GotEnemies

            else
                Cmd.none
    in
    ( initModel session enemyList
    , cmd
    )


initModel : Session.Data -> List EnemyListItem -> Model
initModel session enemyList =
    Model session enemyList 0 Modal.Close Array.empty


type Msg
    = GotEnemies (Result Http.Error String)
    | InputCount String
    | IncreaseCount
    | DecreaseCount
    | OpenModal
    | CloseModal
    | AddEnemy
    | DeleteEnemy Int
    | UpdateEnemyName Int String
    | UpdateEnemyActivePower Int String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotEnemies (Ok json) ->
            ( updateEnemiesModel model json, Cmd.none )

        GotEnemies (Err _) ->
            ( model, Cmd.none )

        InputCount count ->
            let
                newCnt =
                    case String.toInt count of
                        Just i ->
                            i

                        Nothing ->
                            0
            in
            ( { model | count = newCnt }, Cmd.none )

        IncreaseCount ->
            ( { model | count = model.count + 1 }, Cmd.none )

        DecreaseCount ->
            ( { model | count = model.count - 1 }, Cmd.none )

        OpenModal ->
            ( { model | modalState = Modal.Open }, Cmd.none )

        CloseModal ->
            ( { model | modalState = Modal.Close }, Cmd.none )

        AddEnemy ->
            ( { model | enemies = Array.push initBatlleSheetEnemy model.enemies }, Cmd.none )

        DeleteEnemy index ->
            ( { model | enemies = deleteAt index model.enemies }, Cmd.none )

        UpdateEnemyName index name ->
            ( { model | enemies = updateBatlleSheetEnemyName index name model.enemies }, Cmd.none )

        UpdateEnemyActivePower index name ->
            ( { model | enemies = updateBatlleSheetEnemyActivePower index name model.enemies }, Cmd.none )



--


updateEnemiesModel : Model -> String -> Model
updateEnemiesModel model json =
    { model
        | enemyList = EnemyListItem.enemyListFromJson json
        , session = Session.addEnemies model.session json
    }


view : Model -> Skeleton.Details Msg
view model =
    { title = "戦闘シート"
    , attrs = [ class "page-battlesheet" ]
    , kids =
        [ viewMain (viewTopPage model)
        ]
    }


viewTopPage : Model -> Html Msg
viewTopPage model =
    div [ class "wrapper" ]
        [ div [ class "main-area" ]
            [ h1 [ class "center", style "font-size" "2rem" ] [ text "戦闘シート" ]
            , countController model.count InputCount IncreaseCount DecreaseCount
            , inputEnemies AddEnemy DeleteEnemy UpdateEnemyName UpdateEnemyActivePower model.enemies
            ]
        , countArea (List.reverse <| List.range -10 20) model.count
        ]
