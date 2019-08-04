module Page.Views.EnemyEditor exposing (editArea, view)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Models.Card as Card
import Models.Character as Character exposing (Character)
import Models.Enemy as Enemy exposing (EditorModel, Enemy, PageState)
import Page.Views.Card exposing (skillsCards, skillsCardsUpdatable)
import Page.Views.Form exposing (OnChangeMsg, inputArea)
import Page.Views.Tag exposing (tag)


view state =
    case state of
        Enemy.Create ->
            div [] [ text "create" ]

        _ ->
            div [] [ text "update" ]


editArea : OnChangeMsg msg -> EditorModel msg -> Html msg
editArea inputNameMsg editor =
    let
        enemy =
            editor.editingEnemy
    in
    div [ class "enemy-edit-area" ]
        [ inputArea "name" "名前" enemy.name inputNameMsg
        ]
