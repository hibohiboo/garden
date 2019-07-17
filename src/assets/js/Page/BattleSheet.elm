module Page.BattleSheet exposing (Model, Msg, init, initModel, update, view)

import Array exposing (Array)
import FirestoreApi as FSApi
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Models.BattleSheet as BS exposing (BattleSheetCharacter, BattleSheetEnemy, CountAreaItem, TabState(..), getCountAreaItems, initBatlleSheetCharacter, initBatlleSheetEnemy, initCountAreaItem, updateBatlleSheetItemActivePower, updateBatlleSheetItemName, updateBatlleSheetItemPosition)
import Models.Character as Character exposing (Character)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
import Page.Views.BattleSheet exposing (characterCards, characterListModal, countArea, countController, enemyCards, enemyListModal, inputCharacters, inputEnemies, mainAreaTabs, positionArea)
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
    , tab : TabState
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
    Model session enemyList characterList initPageToken 0 Modal.Close Array.empty Array.empty maxAreaCount "" (text "") InputTab


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
    | SetInputTab
    | SetCardTab
    | SetPositionTab


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
            let
                -- 2回目に同じところをクリックした場合は閉じる（開くタブの数字を範囲外にする)
                newNumber =
                    if model.openCountAreaNumber == num then
                        maxAreaCount + 1

                    else
                        num
            in
            ( { model | openCountAreaNumber = newNumber }, Cmd.none )

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

        SetInputTab ->
            ( { model | tab = InputTab }, Cmd.none )

        SetCardTab ->
            ( { model | tab = CardTab }, Cmd.none )

        SetPositionTab ->
            ( { model | tab = PositionTab }, Cmd.none )


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
        [ mainArea model
        , countArea initAreaCount model.count model.openCountAreaNumber UpdateOpenCountAreaNumber (getCountAreaItems initAreaCount model.characters model.enemies)
        , Modal.view model.modalTitle model.modalContents model.modalState CloseModal
        ]


mainArea : Model -> Html Msg
mainArea model =
    let
        current =
            case model.tab of
                InputTab ->
                    "input-main-area"

                CardTab ->
                    "card-main-area"

                PositionTab ->
                    "position-main-area"
    in
    div [ class "main-area", class current ]
        [ h1 [] [ text "戦闘シート" ]
        , mainAreaTabs SetInputTab SetCardTab SetPositionTab model.tab
        , inputMainArea model
        , cardMainArea model
        , positionMainArea model
        ]


inputMainArea : Model -> Html Msg
inputMainArea model =
    div [ class "input-area" ]
        [ countController model.count InputCount IncreaseCount DecreaseCount
        , inputCharacters AddCharacter DeleteCharacter UpdateCharacterName UpdateCharacterActivePower UpdateCharacterPosition OpenCharacterModal model.characters
        , inputEnemies AddEnemy DeleteEnemy UpdateEnemyName UpdateEnemyActivePower UpdateEnemyPosition OpenEnemyModal model.enemies
        ]


cardMainArea : Model -> Html Msg
cardMainArea model =
    div [ class "card-area" ]
        [ characterCards (BS.getCharacters model.characters)
        , enemyCards (BS.getEnemies model.enemies)
        ]


positionMainArea : Model -> Html Msg
positionMainArea model =
    positionArea <|
        List.concat
            [ model.characters |> Array.toList |> List.map toCharacterListItem
            , model.enemies |> Array.toList |> List.map toCharacterListItem
            ]


toCharacterListItem : { a | name : String, position : Int } -> { name : String, position : Int }
toCharacterListItem x =
    { name = x.name, position = x.position }
