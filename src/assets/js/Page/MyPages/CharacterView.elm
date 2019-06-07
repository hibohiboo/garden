module Page.MyPages.CharacterView exposing (cardsView)

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Models.Card as Card
import Models.Character exposing (..)


cardsView : Character -> Html msg
cardsView char =
    div [ class "cards" ]
        [ Card.cardList (Array.toList char.cards)
        ]
