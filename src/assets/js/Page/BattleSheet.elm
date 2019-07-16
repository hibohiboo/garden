module Page.BattleSheet exposing (Model, Msg, init, initModel, update, view)

import Array exposing (Array)
import FirestoreApi as FSApi
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Models.BattleSheet exposing (BattleSheetCharacter, BattleSheetEnemy, CountAreaItem, getCountAreaItems, initBatlleSheetCharacter, initBatlleSheetEnemy, initCountAreaItem, updateBatlleSheetItemActivePower, updateBatlleSheetItemName, updateBatlleSheetItemPosition)
import Models.Character as Character exposing (Character)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
import Page.Views.BattleSheet exposing (characterListModal, countArea, countController, enemyListModal, inputCharacters, inputEnemies)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.Util exposing (deleteAt)


type alias Model =
    { session : Session.Data

    -- モーダルダイアログで選択用のリスト
    , enemyList : List EnemyListItem
    , characterList : List Character
    , charactersPageToken : String
    , count : Int
    , modalState : Modal.ModalState

    -- 選択したキャラクター・エネミーのリスト
    , enemies : Array BattleSheetEnemy
    , characters : Array BattleSheetCharacter
    , openCountAreaNumber : Int
    , modalTitle : String
    , modalContents : Html Msg
    }


initPageToken : String
initPageToken =
    ""


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
            case Session.getCharacterDetails session initPageToken of
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
                Session.fetchCharacterDetails GotCharacters initPageToken

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
    Model session enemyList characterList initPageToken 0 Modal.Close Array.empty Array.empty maxAreaCount "" (text "")


initAreaCount =
    List.reverse <| List.range -10 maxAreaCount


type Msg
    = GotEnemies (Result Http.Error String)
    | GotCharacters (Result Http.Error String)
    | GetNextCharacters
    | InputCount String
    | IncreaseCount
    | DecreaseCount
    | OpenModal
    | CloseModal
    | OpenEnemyModal
    | InputEnemy EnemyListItem
    | OpenCharacterModal
    | InputCharacter Character
    | AddEnemy
    | DeleteEnemy Int
    | UpdateEnemyName Int String
    | UpdateEnemyActivePower Int String
    | UpdateEnemyPosition Int String
    | AddCharacter
    | DeleteCharacter Int
    | UpdateCharacterName Int String
    | UpdateCharacterActivePower Int String
    | UpdateCharacterPosition Int String
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

        GetNextCharacters ->
            ( model, Session.fetchCharacterDetails GotCharacters model.charactersPageToken )

        InputCount count ->
            let
                newCnt =
                    count |> String.toInt |> Maybe.withDefault 0
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

        UpdateEnemyPosition index val ->
            ( { model | enemies = updateBatlleSheetItemPosition index val model.enemies }, Cmd.none )

        AddCharacter ->
            ( { model | characters = Array.push initBatlleSheetCharacter model.characters }, Cmd.none )

        DeleteCharacter index ->
            ( { model | characters = deleteAt index model.characters }, Cmd.none )

        UpdateCharacterName index name ->
            ( { model | characters = updateBatlleSheetItemName index name model.characters }, Cmd.none )

        UpdateCharacterActivePower index ap ->
            ( { model | characters = updateBatlleSheetItemActivePower index ap model.characters }, Cmd.none )

        UpdateCharacterPosition index val ->
            ( { model | characters = updateBatlleSheetItemPosition index val model.characters }, Cmd.none )

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

        OpenCharacterModal ->
            update OpenModal { model | modalContents = characterContent model.charactersPageToken model.characterList }

        InputCharacter char ->
            let
                bsc =
                    BattleSheetCharacter char.name char.activePower char.activePower 0 (Just char)
            in
            update CloseModal { model | characters = Array.push bsc model.characters }


characterContent : String -> List Character -> Html Msg
characterContent token characterList =
    characterListModal InputCharacter GetNextCharacters token characterList



--


updateEnemiesModel : Model -> String -> Model
updateEnemiesModel model json =
    { model
        | enemyList = EnemyListItem.enemyListFromJson json
        , session = Session.addEnemies model.session json
    }


updateCharactersModel : Model -> String -> Model
updateCharactersModel model json =
    let
        -- _ =
        --     Debug.log "decodeUser" (Character.characterListFromJson json)
        characterList =
            Character.characterListFromJson json
                |> List.filter (\c -> c.isPublished)

        nexCharacterList =
            List.concat [ model.characterList, characterList ]

        nextPageToken =
            FSApi.nextTokenFromJson json
    in
    { model
        | characterList = nexCharacterList
        , session = Session.addCharacterDetails model.session json model.charactersPageToken
        , charactersPageToken = nextPageToken
        , modalContents = characterContent nextPageToken nexCharacterList
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
            , inputCharacters AddCharacter DeleteCharacter UpdateCharacterName UpdateCharacterActivePower UpdateCharacterPosition OpenCharacterModal model.characters
            , inputEnemies AddEnemy DeleteEnemy UpdateEnemyName UpdateEnemyActivePower UpdateEnemyPosition OpenEnemyModal model.enemies
            ]
        , countArea initAreaCount model.count model.openCountAreaNumber UpdateOpenCountAreaNumber (getCountAreaItems initAreaCount model.characters model.enemies)
        , Modal.view model.modalTitle model.modalContents model.modalState CloseModal
        ]
