module Page.Views.EnemyView exposing (view)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Split exposing (chunksOfLeft)
import Models.Card as Card exposing (CardData)
import Models.Enemy as Enemy exposing (Enemy)
import Page.Views.Card exposing (skillsCards, skillsCardsUpdatable)
import Page.Views.Tag exposing (tag)
import Url.Builder


view : Enemy -> Html msg
view enemy =
    enemyCardWithCards enemy


enemyCardWithCards : Enemy -> Html msg
enemyCardWithCards enemy =
    div [ class "card-set" ] (enemyCardMain enemy :: skillsCards enemy)


enemyCardMain : Enemy -> Html msg
enemyCardMain enemy =
    div [ class "enemy-card" ]
        [ div [ class "wrapper" ]
            [ div [ class "base" ]
                [ div [ class "skillLabel" ] [ text ("エネミー" ++ "/" ++ enemy.name) ]
                , div [ class "image" ]
                    [ img [ src enemy.cardImage ] []
                    , img [ src "" ] []
                    ]
                , div [ class "cardKana" ] [ text enemy.kana ]
                , div [ class "cardName" ] [ text enemy.name ]
                , div [ class "attrOrganLabel attrLabel border" ] [ text "脅威度" ]
                , div [ class "attrOrganValue border" ] [ text (String.fromInt enemy.degreeOfThreat) ]
                , div [ class "tags" ] (List.map (\t -> tag t.name) enemy.tags)
                , div [ class "mainContent border" ]
                    [ div [ class "effect " ] [ text ("行動力 : " ++ String.fromInt enemy.activePower) ]
                    , div [ class "description" ] [ text enemy.memo ]
                    ]
                , div [ class "bottomContent" ]
                    [ div [ class "cardId" ] [ text "" ]

                    -- , illustedBy char
                    ]
                ]
            ]
        ]
