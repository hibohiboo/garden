module Page.Views.Enemy exposing (enemyCardMain, enemyList)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Split exposing (chunksOfLeft)
import Models.Card as Card exposing (CardData)
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
    div [ class "enemy-cards" ] (enemyCardMain enemy :: skillsCards enemy)


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


skillsCards : EnemyListItem -> List (Html msg)
skillsCards enemy =
    let
        -- カードの大きさに合わせて1枚当たり4つのスキルを表示
        list =
            chunksOfLeft 4 (Array.toList enemy.cards)
    in
    List.map (\cards -> skillsCardMain enemy.name cards) list


skillsCardMain : String -> List CardData -> Html msg
skillsCardMain name cards =
    div [ class "skills-card" ]
        [ div [ class "wrapper" ]
            [ div [ class "base" ]
                [ div [ class "enemyName" ] [ text ("エネミー" ++ "/" ++ name) ]
                , ul [ class "cards collection" ] (cardList cards)
                ]
            ]
        ]


cardList : List CardData -> List (Html msg)
cardList cards =
    List.map (\d -> card d) cards


card : CardData -> Html msg
card data =
    li [ class "collection-item" ]
        [ div [ style "display" "flex" ]
            [ div [ class "skill-name", style "min-width" "0" ] (span [] [ text data.cardName ] :: List.map (\t -> tag t.name) data.tags)
            , div [ style "display" "flex", style "margin-left" "auto" ]
                [ div [ class "used" ] [ label [] [ input [ type_ "checkbox" ] [], span [] [ text "済" ] ] ]
                , div [ class "injury" ] [ label [] [ input [ type_ "checkbox", class "filled-in" ] [], span [] [ text "傷" ] ] ]
                ]
            ]
        , div [ class "skill-description" ]
            [ div [] [ text (data.timing ++ "/" ++ String.fromInt data.cost ++ "/" ++ Card.getRange data ++ "/" ++ data.target) ]
            , div [] [ text data.effect ]
            ]
        ]



-- input [ type_ "checkbox", checked cardState.isUsed, onClick (ToggleUsed i) ] []
