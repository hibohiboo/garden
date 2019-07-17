module Models.BattleSheet exposing (BattleSheetCharacter, BattleSheetEnemy, BattleSheetItem, CountAreaItem, TabState(..), getCharacters, getCountAreaItems, getEnemies, initBatlleSheetCharacter, initBatlleSheetEnemy, initCountAreaItem, updateBatlleSheetItemActivePower, updateBatlleSheetItemIsDisplay, updateBatlleSheetItemName, updateBatlleSheetItemPosition)

import Array exposing (Array)
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


getCharacters : Array BattleSheetCharacter -> List ( Int, BattleSheetCharacter )
getCharacters characters =
    characters
        |> Array.indexedMap (\i x -> ( i, x ))
        |> Array.toList
        |> List.filter (\( i, x ) -> x.data /= Nothing)



--      |> List.map (\( i, x ) -> ( i, Maybe.withDefault (Character.initCharacter "") x.data ))


getEnemies : Array BattleSheetEnemy -> List EnemyListItem
getEnemies enemies =
    enemies
        |> Array.toList
        |> List.filter (\x -> x.data /= Nothing)
        |> List.map (\x -> Maybe.withDefault EnemyListItem.init x.data)
