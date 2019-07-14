module Page.BattleSheet exposing (Model, Msg, init, initModel, update, view)

import FirestoreApi as FSApi
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
import Page.Views.BattleSheet exposing (..)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal


type alias Model =
    { session : Session.Data
    , enemies : List EnemyListItem
    , count : Int
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
    Model session enemies 0


type Msg
    = GotEnemies (Result Http.Error String)
    | InputCount String
    | IncreaseCount
    | DecreaseCount


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


updateEnemiesModel : Model -> String -> Model
updateEnemiesModel model json =
    { model
        | enemies = EnemyListItem.enemyListFromJson json
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
            [ h1 [ class "center", style "font-size" "3rem" ] [ text "戦闘シート" ]
            , countController model.count InputCount IncreaseCount DecreaseCount
            ]
        , countArea (List.reverse <| List.range -10 20) model.count
        ]
