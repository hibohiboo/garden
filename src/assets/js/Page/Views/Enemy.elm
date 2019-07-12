module Page.Views.Enemy exposing (enemyList)

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
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
    div [ class "enemy-cards" ]
        [ enemyCardMain enemy
        , skillsCardMain enemy
        ]


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


skillsCardMain : EnemyListItem -> Html msg
skillsCardMain enemy =
    div [ class "skills-card" ]
        [ div [ class "wrapper" ]
            [ div [ class "base" ]
                [ div [ class "enemyName" ] [ text ("エネミー" ++ "/" ++ enemy.name) ]
                , ul [ class "cards collection" ] (cardList enemy)
                ]
            ]
        ]


cardList : EnemyListItem -> List (Html msg)
cardList enemy =
    List.map (\t -> card t.cardName) (Array.toList enemy.cards)


card name =
    li [ class "collection-item" ]
        [ div [ style "display" "flex" ]
            [ div [ class "skill-name", style "min-width" "0" ] [ span [] [ text "庇う" ], tag "身体強化" ]
            , div [ style "display" "flex", style "margin-left" "auto" ]
                [ div [ class "used" ] [ label [] [ input [ type_ "checkbox" ] [], span [] [ text "済" ] ] ]
                , div [ class "injury" ] [ label [] [ input [ type_ "checkbox" ] [], span [] [ text "傷" ] ] ]
                ]
            ]
        , div [ class "skill-description" ]
            [ div [] [ text "アクション/4/0/自身" ]
            , div [] [ text "対象が受けたダメージを、代わりに自身が受ける。このカードは使用済にならない。" ]
            ]
        ]



-- input [ type_ "checkbox", checked cardState.isUsed, onClick (ToggleUsed i) ] []
