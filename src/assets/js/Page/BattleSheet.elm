port module Page.BattleSheet exposing (Model, Msg, init, initModel, subscriptions, update, view)

import Array exposing (Array)
import FirestoreApi as FSApi
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Models.BattleSheet as BS exposing (BattleSheetCharacter, BattleSheetEnemy, BattleSheetModel, BattleSheetMsg(..), CountAreaItem, TabState(..), getCountAreaItems, initBatlleSheetCharacter, initBatlleSheetEnemy, initBattleSheetModel, initCountAreaItem, initPageToken, maxAreaCount, updateBatlleSheetItemActivePower, updateBatlleSheetItemName, updateBatlleSheetItemPosition)
import Models.Card as Card
import Models.Character as Character exposing (Character)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
import Page.Views.BattleSheet exposing (characterCards, characterListModal, countArea, countController, enemyCards, enemyListModal, inputCharacters, inputEnemies, inputSheetName, mainAreaTabs, positionArea, unUsedAllButton)
import Random
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.Util exposing (deleteAt)


port saveBattleSheet : String -> Cmd msg


port getBattleSheet : String -> Cmd msg


port gotBattleSheet : (String -> msg) -> Sub msg


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ gotBattleSheet GotBattleSheet
        ]


type alias Msg =
    BattleSheetMsg


type alias Model =
    BattleSheetModel


init : Session.Data -> ( Model, Cmd Msg )
init session =
    let
        enemyList =
            case Session.getEnemies session of
                Just json ->
                    EnemyListItem.enemyListFromFireStoreApi json

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
    , Cmd.batch [ cmd, cmd2, getBattleSheet "" ]
    )


initModel : Session.Data -> List EnemyListItem -> List Character -> Model
initModel =
    initBattleSheetModel



--openCountAreaNumberを maxAreaCountにすることで0の位置にあわせる


initAreaCount =
    List.reverse <| List.range -10 maxAreaCount


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
            saveLocalStorage ( { model | count = newCnt }, Cmd.none )

        InputSheetName name ->
            saveLocalStorage ( { model | sheetName = name }, Cmd.none )

        IncreaseCount ->
            saveLocalStorage ( { model | count = model.count + 1 }, Cmd.none )

        DecreaseCount ->
            saveLocalStorage ( { model | count = model.count - 1 }, Cmd.none )

        OpenModal ->
            ( { model | modalState = Modal.Open }, Cmd.none )

        CloseModal ->
            saveLocalStorage ( { model | modalState = Modal.Close }, Cmd.none )

        AddEnemy ->
            saveLocalStorage ( { model | enemies = Array.push initBatlleSheetEnemy model.enemies }, Cmd.none )

        DeleteEnemy index ->
            saveLocalStorage ( { model | enemies = deleteAt index model.enemies }, Cmd.none )

        UpdateEnemyName index name ->
            saveLocalStorage ( { model | enemies = updateBatlleSheetItemName index name model.enemies }, Cmd.none )

        UpdateEnemyActivePower index ap ->
            saveLocalStorage ( { model | enemies = updateBatlleSheetItemActivePower index ap model.enemies }, Cmd.none )

        UpdateEnemyPosition index val ->
            saveLocalStorage ( { model | enemies = updateBatlleSheetItemPosition index val model.enemies }, Cmd.none )

        AddCharacter ->
            saveLocalStorage ( { model | characters = Array.push initBatlleSheetCharacter model.characters }, Cmd.none )

        DeleteCharacter index ->
            saveLocalStorage ( { model | characters = deleteAt index model.characters }, Cmd.none )

        UpdateCharacterName index name ->
            saveLocalStorage ( { model | characters = updateBatlleSheetItemName index name model.characters }, Cmd.none )

        UpdateCharacterActivePower index ap ->
            saveLocalStorage ( { model | characters = updateBatlleSheetItemActivePower index ap model.characters }, Cmd.none )

        UpdateCharacterPosition index val ->
            saveLocalStorage ( { model | characters = updateBatlleSheetItemPosition index val model.characters }, Cmd.none )

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
                    BattleSheetEnemy enemy.name enemy.activePower enemy.activePower 5 enemy.cardImage (Just enemy) True (Card.getNotDamagedCardNumber enemy.cards)
            in
            update CloseModal { model | enemies = Array.push bse model.enemies }

        OpenCharacterModal ->
            update OpenModal { model | modalContents = characterContent model.charactersPageToken model.characterList }

        InputCharacter char ->
            let
                bsc =
                    BattleSheetCharacter char.name char.activePower char.activePower 1 char.cardImage (Just char) True (Card.getNotDamagedCardNumber char.cards)
            in
            update CloseModal { model | characters = Array.push bsc model.characters }

        SetInputTab ->
            ( { model | tab = InputTab }, Cmd.none )

        SetCardTab ->
            ( { model | tab = CardTab }, Cmd.none )

        SetPositionTab ->
            ( { model | tab = PositionTab }, Cmd.none )

        SetSummaryTab ->
            ( { model | tab = SummaryTab }, Cmd.none )

        SetAllTab ->
            ( { model | tab = AllTab }, Cmd.none )

        ToggleCharacterCardSkillsDisplay iCharacter ->
            let
                characters =
                    BS.updateBatlleSheetItemIsDisplay iCharacter model.characters
            in
            ( { model | characters = characters }, Cmd.none )

        ToggleEnemyCardSkillsDisplay indexEnemy ->
            let
                enemies =
                    BS.updateBatlleSheetItemIsDisplay indexEnemy model.enemies
            in
            ( { model | enemies = enemies }, Cmd.none )

        ToggleCharacterSkillCardUsed indexCharacter indexSkill ->
            let
                characters =
                    BS.updateBatlleSheetItemCardUsed indexCharacter indexSkill model.characters
            in
            saveLocalStorage ( { model | characters = characters }, Cmd.none )

        ToggleCharacterSkillCardDamaged indexCharacter indexSkill ->
            let
                characters =
                    BS.updateBatlleSheetItemCardDamaged indexCharacter indexSkill model.characters
            in
            saveLocalStorage ( { model | characters = characters }, Cmd.none )

        ToggleEnemySkillCardUsed indexEnemy indexSkill ->
            let
                enemies =
                    BS.updateBatlleSheetItemCardUsed indexEnemy indexSkill model.enemies
            in
            saveLocalStorage ( { model | enemies = enemies }, Cmd.none )

        ToggleEnemySkillCardDamaged indexEnemy indexSkill ->
            let
                enemies =
                    BS.updateBatlleSheetItemCardDamaged indexEnemy indexSkill model.enemies
            in
            saveLocalStorage ( { model | enemies = enemies }, Cmd.none )

        GotBattleSheet json ->
            case BS.decodeBattleSheetFromJson json of
                Ok m ->
                    ( { model | sheetName = m.sheetName, count = m.count, enemies = m.enemies, characters = m.characters }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        UnUsedAll ->
            let
                enemies =
                    BS.updateBatlleSheetItemCardUnUsedAll model.enemies

                characters =
                    BS.updateBatlleSheetItemCardUnUsedAll model.characters
            in
            saveLocalStorage ( { model | enemies = enemies, characters = characters }, Cmd.none )

        RandomCharacterDamage indexCharacter ->
            let
                maxNumber =
                    BS.getCountNotDamagedUnUsedCard indexCharacter model.characters
            in
            saveLocalStorage ( model, Random.generate (RandomCharacterDamaged indexCharacter) (Random.int 1 maxNumber) )

        RandomCharacterDamaged indexCharacter damaged ->
            let
                characters =
                    BS.updateBatlleSheetItemCardRandomDamaged indexCharacter damaged model.characters
            in
            saveLocalStorage ( { model | characters = characters }, Cmd.none )

        RandomEnemyDamage indexEnemy ->
            let
                maxNumber =
                    BS.getCountNotDamagedUnUsedCard indexEnemy model.enemies
            in
            saveLocalStorage ( model, Random.generate (RandomEnemyDamaged indexEnemy) (Random.int 1 maxNumber) )

        RandomEnemyDamaged indexEnemy damaged ->
            let
                enemies =
                    BS.updateBatlleSheetItemCardRandomDamaged indexEnemy damaged model.enemies
            in
            saveLocalStorage ( { model | enemies = enemies }, Cmd.none )


saveLocalStorage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
saveLocalStorage ( model, cmd ) =
    ( model, Cmd.batch [ cmd, saveBattleSheet (BS.encodeBattleSheetToJson model) ] )


characterContent : String -> List Character -> Html Msg
characterContent token characterList =
    characterListModal InputCharacter GetNextCharacters token characterList



--


updateEnemiesModel : Model -> String -> Model
updateEnemiesModel model json =
    { model
        | enemyList = EnemyListItem.enemyListFromFireStoreApi json
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

                SummaryTab ->
                    "summary-main-area"

                AllTab ->
                    "input-main-area  card-main-area position-main-area summary-main-area"
    in
    div [ class "main-area", class current ]
        [ h1 [] [ text "戦闘シート" ]
        , mainAreaTabs SetInputTab SetCardTab SetPositionTab SetSummaryTab SetAllTab model.tab
        , inputMainArea model
        , cardMainArea model
        , positionMainArea model
        , summaryMainArea
        ]


inputMainArea : Model -> Html Msg
inputMainArea model =
    div [ class "input-area" ]
        [ inputSheetName model.sheetName InputSheetName
        , countController model.count InputCount IncreaseCount DecreaseCount
        , inputCharacters AddCharacter DeleteCharacter UpdateCharacterName UpdateCharacterActivePower UpdateCharacterPosition OpenCharacterModal model.characters
        , inputEnemies AddEnemy DeleteEnemy UpdateEnemyName UpdateEnemyActivePower UpdateEnemyPosition OpenEnemyModal model.enemies
        ]


cardMainArea : Model -> Html Msg
cardMainArea model =
    div [ class "card-area" ]
        [ p [] [ text "カードクリックでスキルカードの表示/非表示を切替。" ]
        , unUsedAllButton UnUsedAll
        , characterCards (BS.getIndexedCharacterCard model.characters) ToggleCharacterCardSkillsDisplay ToggleCharacterSkillCardUsed ToggleCharacterSkillCardDamaged RandomCharacterDamage
        , enemyCards (BS.getIndexedEnemyCard model.enemies) ToggleEnemyCardSkillsDisplay ToggleEnemySkillCardUsed ToggleEnemySkillCardDamaged RandomEnemyDamage
        ]


positionMainArea : Model -> Html Msg
positionMainArea model =
    positionArea <|
        List.concat
            [ model.characters |> Array.toList |> List.map toCharacterListItem
            , model.enemies |> Array.toList |> List.map toCharacterListItem
            ]


toCharacterListItem : { a | name : String, position : Int, cardImage : String, notDamagedCardNumber : Int } -> { name : String, position : Int, cardImage : String, notDamagedCardNumber : Int }
toCharacterListItem x =
    { name = x.name, position = x.position, cardImage = x.cardImage, notDamagedCardNumber = x.notDamagedCardNumber }


summaryMainArea =
    div [ class "summary-area" ]
        [ table []
            [ tr []
                [ th [] [ text "出目" ]
                , th [] [ text "効果" ]
                ]
            , tr []
                [ th [] [ text "6" ]
                , td [] [ text "攻撃された側が選んだカード" ]
                ]
            , tr []
                [ th [] [ text "7" ]
                , td [] [ text "攻撃された側が選んだ手札のカード" ]
                ]
            , tr []
                [ th [] [ text "8" ]
                , td [] [ text "攻撃された側が選んだ使用済置き場のカード" ]
                ]
            , tr []
                [ th [] [ text "9" ]
                , td [] [ text "攻撃した側が選んだ使用済置き場のカード" ]
                ]
            , tr []
                [ th [] [ text "10以上" ]
                , td [] [ text "ランダムに選んだ手札のカード" ]
                ]
            ]
        ]
