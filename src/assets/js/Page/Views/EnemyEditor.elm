module Page.Views.EnemyEditor exposing (view)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Models.Card as Card
import Models.Character as Character exposing (Character)
import Models.Enemy as Enemy exposing (Enemy, PageState)
import Page.Views.Card exposing (skillsCards, skillsCardsUpdatable)
import Page.Views.Tag exposing (tag)


view state =
    case state of
        Enemy.Create ->
            div [] [ text "create" ]

        _ ->
            div [] [ text "update" ]
