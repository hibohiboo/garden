module Page.Views.Card exposing (skillsCards)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Split exposing (chunksOfLeft)
import Models.Card as Card exposing (CardData)
import Page.Views.Tag exposing (tag)
import Url.Builder


skillsCards : { a | name : String, cards : Array CardData } -> List (Html msg)
skillsCards item =
    let
        -- カードの大きさに合わせて1枚当たり4つのスキルを表示
        list =
            chunksOfLeft 4 (Array.toList item.cards)
    in
    List.map (\cards -> skillsCardMain item.name cards) list


skillsCardMain : String -> List CardData -> Html msg
skillsCardMain name cards =
    div [ class "skills-card" ]
        [ div [ class "wrapper" ]
            [ div [ class "base" ]
                [ div [ class "enemyName" ] [ text ("カード" ++ "/" ++ name) ]
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