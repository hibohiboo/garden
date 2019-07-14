module Models.BattleSheet exposing (BattleSheetEnemy)

import Array exposing (Array)
import Models.Card as Card exposing (CardData)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
import Models.Tag as Tag exposing (Tag)


type alias BattleSheetEnemy =
    { name : String
    , count : Int
    , activePower : Int
    , data : Maybe EnemyListItem
    }
