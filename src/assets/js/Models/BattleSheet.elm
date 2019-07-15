module Models.BattleSheet exposing (BattleSheetCharacter, BattleSheetEnemy, BattleSheetItem, CountAreaItem, getCountAreaItems, initBatlleSheetCharacter, initBatlleSheetEnemy, initCountAreaItem, updateBatlleSheetItemActivePower, updateBatlleSheetItemName)

import Array exposing (Array)
import Models.Character as Character exposing (Character)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)


type alias BattleSheetItem a =
    { a | name : String, count : Int, activePower : Int, position : Int }


type alias BattleSheetEnemy =
    { name : String
    , count : Int
    , activePower : Int
    , position : Int
    , data : Maybe EnemyListItem
    }


type alias BattleSheetCharacter =
    { name : String
    , count : Int
    , activePower : Int
    , position : Int
    , data : Maybe Character
    }


type alias CountAreaItem =
    { isShow : Bool
    , characters : List String
    , enemies : List String
    }


initCountAreaItem : CountAreaItem
initCountAreaItem =
    CountAreaItem False [] []


initBatlleSheetEnemy : BattleSheetEnemy
initBatlleSheetEnemy =
    BattleSheetEnemy "" 0 0 0 Nothing


initBatlleSheetCharacter : BattleSheetCharacter
initBatlleSheetCharacter =
    BattleSheetCharacter "" 0 0 0 Nothing


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


getCountAreaItems : List Int -> Array BattleSheetCharacter -> Array BattleSheetEnemy -> List CountAreaItem
getCountAreaItems counts characters enemies =
    List.map
        (\i ->
            CountAreaItem False (filterActivePower i characters) (filterActivePower i enemies)
        )
        counts


filterActivePower : Int -> Array { a | activePower : Int, name : String } -> List String
filterActivePower i characters =
    characters
        |> Array.toList
        |> List.filter (\x -> x.activePower == i)
        |> List.map (\x -> x.name)
