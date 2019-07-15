module Models.BattleSheet exposing (BattleSheetEnemy, BattleSheetItem, initBatlleSheetEnemy, updateBatlleSheetEnemyName)

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
    , data : Maybe EnemyListItem
    }


initBatlleSheetEnemy : BattleSheetEnemy
initBatlleSheetEnemy =
    BattleSheetEnemy "" 0 0 0 Nothing


updateBatlleSheetEnemyName : Int -> String -> Array BattleSheetEnemy -> Array BattleSheetEnemy
updateBatlleSheetEnemyName index name enemies =
    case Array.get index enemies of
        Just oldEnemy ->
            let
                enemy =
                    { oldEnemy | name = name }
            in
            Array.set index enemy enemies

        Nothing ->
            enemies
