module Page.Views.EnemyCrud exposing (view)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Models.Card as Card
import Models.Character as Character exposing (Character)
import Page.Views.Card exposing (skillsCards, skillsCardsUpdatable)
import Page.Views.Tag exposing (tag)


view =
    div [] [ text "test" ]
