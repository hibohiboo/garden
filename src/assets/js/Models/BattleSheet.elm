module Models.BattleSheet exposing (BattleSheetCharacter, BattleSheetEnemy, BattleSheetItem, BattleSheetModel, BattleSheetMsg(..), CountAreaItem, TabState(..), getCountAreaItems, getIndexedCharacterCard, getIndexedEnemyCard, initBatlleSheetCharacter, initBatlleSheetEnemy, initBattleSheetModel, initCountAreaItem, initPageToken, maxAreaCount, updateBatlleSheetItemActivePower, updateBatlleSheetItemCardDamaged, updateBatlleSheetItemCardUsed, updateBatlleSheetItemIsDisplay, updateBatlleSheetItemName, updateBatlleSheetItemPosition)

import Array exposing (Array)
import Html exposing (Html, text)
import Http
import Models.Card as Card exposing (CardData)
import Models.Character as Character exposing (Character)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
import Session
import Utils.ModalWindow as Modal


type alias BattleSheetModel =
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
    , modalContents : Html BattleSheetMsg
    , tab : TabState
    }


maxAreaCount =
    20


initPageToken : String
initPageToken =
    ""


initBattleSheetModel : Session.Data -> List EnemyListItem -> List Character -> BattleSheetModel
initBattleSheetModel session enemyList characterList =
    BattleSheetModel session enemyList characterList initPageToken 0 Modal.Close Array.empty Array.empty maxAreaCount "" (text "") InputTab


type BattleSheetMsg
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
    | SetSummaryTab
    | SetAllTab
    | ToggleCharacterCardSkillsDisplay Int
    | ToggleCharacterSkillCardUsed Int Int
    | ToggleCharacterSkillCardDamaged Int Int
    | ToggleEnemyCardSkillsDisplay Int
    | ToggleEnemySkillCardUsed Int Int
    | ToggleEnemySkillCardDamaged Int Int
    | GotBattleSheet String


type alias BattleSheetItem a =
    { a | name : String, count : Int, activePower : Int, position : Int, isDisplaySkills : Bool, notDamagedCardNumber : Int }


type TabState
    = InputTab
    | CardTab
    | PositionTab
    | SummaryTab
    | AllTab


type alias BattleSheetEnemy =
    { name : String
    , count : Int
    , activePower : Int
    , position : Int
    , cardImage : String
    , data : Maybe EnemyListItem
    , isDisplaySkills : Bool
    , notDamagedCardNumber : Int
    }


type alias BattleSheetCharacter =
    { name : String
    , count : Int
    , activePower : Int
    , position : Int
    , cardImage : String
    , data : Maybe Character
    , isDisplaySkills : Bool
    , notDamagedCardNumber : Int
    }


type alias CountAreaItem =
    { characters : List String
    , enemies : List String
    }



-- encodeBattleSheet =


initCountAreaItem : CountAreaItem
initCountAreaItem =
    CountAreaItem [] []


initBatlleSheetEnemy : BattleSheetEnemy
initBatlleSheetEnemy =
    BattleSheetEnemy "" 0 0 1 "" Nothing True 0


initBatlleSheetCharacter : BattleSheetCharacter
initBatlleSheetCharacter =
    BattleSheetCharacter "" 0 0 1 "" Nothing True 0


updateBatlleSheetItemName : Int -> String -> Array { a | name : String } -> Array { a | name : String }
updateBatlleSheetItemName index name enemies =
    case Array.get index enemies of
        Just oldEnemy ->
            let
                enemy =
                    { oldEnemy | name = name }
            in
            Array.set index enemy enemies

        Nothing ->
            enemies


updateBatlleSheetItemActivePower : Int -> String -> Array { a | activePower : Int } -> Array { a | activePower : Int }
updateBatlleSheetItemActivePower index ap enemies =
    case Array.get index enemies of
        Just oldEnemy ->
            let
                iAp =
                    ap |> String.toInt |> Maybe.withDefault 0

                enemy =
                    { oldEnemy | activePower = iAp }
            in
            Array.set index enemy enemies

        Nothing ->
            enemies


updateBatlleSheetItemPosition : Int -> String -> Array { a | position : Int } -> Array { a | position : Int }
updateBatlleSheetItemPosition index stVal items =
    case Array.get index items of
        Just oldItem ->
            let
                val =
                    stVal |> String.toInt |> Maybe.withDefault 0
            in
            Array.set index { oldItem | position = val } items

        Nothing ->
            items


updateBatlleSheetItemIsDisplay : Int -> Array { a | isDisplaySkills : Bool } -> Array { a | isDisplaySkills : Bool }
updateBatlleSheetItemIsDisplay index items =
    case Array.get index items of
        Just oldItem ->
            Array.set index { oldItem | isDisplaySkills = not oldItem.isDisplaySkills } items

        Nothing ->
            items


updateBatlleSheetItemCardUsed : Int -> Int -> Array { a | data : Maybe { b | cards : Array CardData } } -> Array { a | data : Maybe { b | cards : Array CardData } }
updateBatlleSheetItemCardUsed itemIndex skillIndex items =
    case Array.get itemIndex items of
        Just oldItem ->
            let
                data =
                    oldItem.data |> Maybe.andThen (updateCardUsed skillIndex)
            in
            Array.set itemIndex { oldItem | data = data } items

        Nothing ->
            items


updateCardUsed : Int -> { b | cards : Array CardData } -> Maybe { b | cards : Array CardData }
updateCardUsed index data =
    case Array.get index data.cards of
        Just card ->
            let
                cards =
                    Array.set index { card | isUsed = not card.isUsed } data.cards
            in
            Just { data | cards = cards }

        Nothing ->
            Nothing


updateBatlleSheetItemCardDamaged : Int -> Int -> Array { a | data : Maybe { b | cards : Array CardData }, notDamagedCardNumber : Int } -> Array { a | data : Maybe { b | cards : Array CardData }, notDamagedCardNumber : Int }
updateBatlleSheetItemCardDamaged itemIndex skillIndex items =
    case Array.get itemIndex items of
        Just oldItem ->
            let
                data =
                    oldItem.data |> Maybe.andThen (updateCardDamaged skillIndex)

                notDamagedCardNumber =
                    data |> Maybe.andThen (\d -> Just (Card.getNotDamagedCardNumber d.cards)) |> Maybe.withDefault 0
            in
            Array.set itemIndex { oldItem | data = data, notDamagedCardNumber = notDamagedCardNumber } items

        Nothing ->
            items


updateCardDamaged : Int -> { b | cards : Array CardData } -> Maybe { b | cards : Array CardData }
updateCardDamaged index data =
    case Array.get index data.cards of
        Just card ->
            let
                cards =
                    Array.set index { card | isDamaged = not card.isDamaged } data.cards
            in
            Just { data | cards = cards }

        Nothing ->
            Nothing


getCountAreaItems : List Int -> Array BattleSheetCharacter -> Array BattleSheetEnemy -> List CountAreaItem
getCountAreaItems counts characters enemies =
    List.map
        (\i ->
            CountAreaItem (filterActivePower i characters) (filterActivePower i enemies)
        )
        counts


filterActivePower : Int -> Array { a | activePower : Int, name : String } -> List String
filterActivePower i characters =
    characters
        |> Array.toList
        |> List.filter (\x -> x.activePower == i)
        |> List.map (\x -> x.name)


getIndexedCharacterCard : Array BattleSheetCharacter -> List ( Int, BattleSheetCharacter )
getIndexedCharacterCard characters =
    characters
        |> Array.indexedMap (\i x -> ( i, x ))
        |> Array.toList
        |> List.filter (\( i, x ) -> x.data /= Nothing)



--      |> List.map (\( i, x ) -> ( i, Maybe.withDefault (Character.initCharacter "") x.data ))


getIndexedEnemyCard : Array BattleSheetEnemy -> List ( Int, BattleSheetEnemy )
getIndexedEnemyCard enemies =
    enemies
        |> Array.indexedMap (\i x -> ( i, x ))
        |> Array.toList
        |> List.filter (\( i, x ) -> x.data /= Nothing)
