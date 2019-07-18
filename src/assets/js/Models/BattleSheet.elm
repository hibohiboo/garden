module Models.BattleSheet exposing (BattleSheetCharacter, BattleSheetEnemy, BattleSheetItem, CountAreaItem, TabState(..), getCountAreaItems, getIndexedCharacterCard, getIndexedEnemyCard, initBatlleSheetCharacter, initBatlleSheetEnemy, initCountAreaItem, updateBatlleSheetItemActivePower, updateBatlleSheetItemCardUsed, updateBatlleSheetItemIsDisplay, updateBatlleSheetItemName, updateBatlleSheetItemPosition)

import Array exposing (Array)
import Models.Card exposing (CardData)
import Models.Character as Character exposing (Character)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)


type alias BattleSheetItem a =
    { a | name : String, count : Int, activePower : Int, position : Int, isDisplaySkills : Bool }


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
    }


type alias BattleSheetCharacter =
    { name : String
    , count : Int
    , activePower : Int
    , position : Int
    , cardImage : String
    , data : Maybe Character
    , isDisplaySkills : Bool
    }


type alias CountAreaItem =
    { characters : List String
    , enemies : List String
    }


initCountAreaItem : CountAreaItem
initCountAreaItem =
    CountAreaItem [] []


initBatlleSheetEnemy : BattleSheetEnemy
initBatlleSheetEnemy =
    BattleSheetEnemy "" 0 0 1 "" Nothing True


initBatlleSheetCharacter : BattleSheetCharacter
initBatlleSheetCharacter =
    BattleSheetCharacter "" 0 0 1 "" Nothing True


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
