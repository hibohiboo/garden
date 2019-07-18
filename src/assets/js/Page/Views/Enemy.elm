module Page.Views.Enemy exposing (enemyCardMain, enemyCardWithCards, enemyList)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Split exposing (chunksOfLeft)
import Models.Card as Card exposing (CardData)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
import Page.Views.Card exposing (skillsCards)
import Page.Views.Tag exposing (tag)
import Url.Builder


enemyList : List EnemyListItem -> Html msg
enemyList enemies =
    div [ class "card-list" ]
        (List.map
            (\row ->
                enemyCard row
            )
            enemies
        )


enemyCard : EnemyListItem -> Html msg
enemyCard enemy =
    div [ class "card-set" ] (enemyCardMain enemy :: skillsCards enemy)


enemyCardMain : EnemyListItem -> Html msg
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

                -- , div [ class "attrMutagenLabel attrLabel border" ] [ text "変異原" ]
                -- , div [ class "attrMutagenValue border" ] [ text "" ]
                -- , div [ class "attrReasonLabel attrLabel border" ] [ text "収容理由" ]
                -- , div [ class "attrReasonValue border" ] [ text "" ]
                -- , div [ class "attrLaboLabel attrLabel border" ] [ text "研究所" ]
                -- , div [ class "attrLaboValue attrLabel border" ] [ text "enemy.labo" ]
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


enemyCardWithCards : EnemyListItem -> Bool -> Html msg
enemyCardWithCards enemy isDisplaySkills =
    let
        className =
            if isDisplaySkills then
                ""

            else
                "skills-hide"
    in
    div [ class "card-set", class className ] (enemyCard enemy :: skillsCards enemy)



-- input [ type_ "checkbox", checked cardState.isUsed, onClick (ToggleUsed i) ] []
