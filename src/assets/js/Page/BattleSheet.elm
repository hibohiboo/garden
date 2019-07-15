module Page.BattleSheet exposing (Model, Msg, init, initModel, update, view)

import Array exposing (Array)
import FirestoreApi as FSApi
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Models.BattleSheet exposing (BattleSheetCharacter, BattleSheetEnemy, CountAreaItem, getCountAreaItems, initBatlleSheetCharacter, initBatlleSheetEnemy, initCountAreaItem, updateBatlleSheetItemActivePower, updateBatlleSheetItemName)
import Models.Character as Character exposing (Character)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
import Page.Views.BattleSheet exposing (countArea, countController, enemyListModal, inputCharacters, inputEnemies)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.Util exposing (deleteAt)


type alias Model =
    { session : Session.Data
    , enemyList : List EnemyListItem
    , characterList : List Character
    , count : Int
    , modalState : Modal.ModalState
    , enemies : Array BattleSheetEnemy
    , characters : Array BattleSheetCharacter
    , openCountAreaNumber : Int
    , modalTitle : String
    , modalContents : Html Msg
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

        characterList =
            case Session.getCharacterDetails session "" of
                Just json ->
                    Character.characterListFromJson json

                Nothing ->
                    []

        cmd =
            if enemyList == [] then
                Session.fetchEnemies GotEnemies

            else
                Cmd.none

        cmd2 =
            if enemyList == [] then
                Session.fetchCharacterDetails GotCharacters ""

            else
                Cmd.none
    in
    ( initModel session enemyList characterList
    , Cmd.batch [ cmd, cmd2 ]
    )


maxAreaCount =
    20



--openCountAreaNumberを maxAreaCountにすることで0の位置にあわせる


initModel : Session.Data -> List EnemyListItem -> List Character -> Model
initModel session enemyList characterList =
    Model session enemyList characterList 0 Modal.Close Array.empty Array.empty maxAreaCount "" (text "")


initAreaCount =
    List.reverse <| List.range -10 maxAreaCount


type Msg
    = GotEnemies (Result Http.Error String)
    | GotCharacters (Result Http.Error String)
    | InputCount String
    | IncreaseCount
    | DecreaseCount
    | OpenModal
    | CloseModal
    | OpenEnemyModal
    | InputEnemy EnemyListItem
    | AddEnemy
    | DeleteEnemy Int
    | UpdateEnemyName Int String
    | UpdateEnemyActivePower Int String
    | AddCharacter
    | DeleteCharacter Int
    | UpdateCharacterName Int String
    | UpdateCharacterActivePower Int String
    | UpdateOpenCountAreaNumber Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotEnemies (Ok json) ->
            ( updateEnemiesModel model json, Cmd.none )

        GotEnemies (Err _) ->
            ( model, Cmd.none )

        GotCharacters (Ok json) ->
            ( updateCharactersModel model json, Cmd.none )

        GotCharacters (Err _) ->
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
            ( { model | enemies = updateBatlleSheetItemName index name model.enemies }, Cmd.none )

        UpdateEnemyActivePower index ap ->
            ( { model | enemies = updateBatlleSheetItemActivePower index ap model.enemies }, Cmd.none )

        AddCharacter ->
            ( { model | characters = Array.push initBatlleSheetCharacter model.characters }, Cmd.none )

        DeleteCharacter index ->
            ( { model | characters = deleteAt index model.characters }, Cmd.none )

        UpdateCharacterName index name ->
            ( { model | characters = updateBatlleSheetItemName index name model.characters }, Cmd.none )

        UpdateCharacterActivePower index ap ->
            ( { model | characters = updateBatlleSheetItemActivePower index ap model.characters }, Cmd.none )

        UpdateOpenCountAreaNumber num ->
            ( { model | openCountAreaNumber = num }, Cmd.none )

        OpenEnemyModal ->
            let
                content =
                    enemyListModal InputEnemy model.enemyList
            in
            update OpenModal { model | modalContents = content }

        InputEnemy enemy ->
            let
                bse =
                    BattleSheetEnemy enemy.name enemy.activePower enemy.activePower 0 (Just enemy)
            in
            update CloseModal { model | enemies = Array.push bse model.enemies }



--


updateEnemiesModel : Model -> String -> Model
updateEnemiesModel model json =
    { model
        | enemyList = EnemyListItem.enemyListFromJson json
        , session = Session.addEnemies model.session json
    }


updateCharactersModel : Model -> String -> Model
updateCharactersModel model json =
    { model
        | characterList = List.concat [ model.characterList, Character.characterListFromJson json ]
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
            , inputCharacters AddCharacter DeleteCharacter UpdateCharacterName UpdateCharacterActivePower OpenEnemyModal model.characters
            , inputEnemies AddEnemy DeleteEnemy UpdateEnemyName UpdateEnemyActivePower OpenEnemyModal model.enemies
            ]
        , countArea initAreaCount model.count model.openCountAreaNumber UpdateOpenCountAreaNumber (getCountAreaItems initAreaCount model.characters model.enemies)
        , Modal.view model.modalTitle model.modalContents model.modalState CloseModal
        ]
