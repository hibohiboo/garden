module Page.Views.CharacterView exposing (characterCard)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Models.Card as Card
import Models.Character as Character exposing (Character)
import Page.Views.Tag exposing (tag)


characterCard : Character -> Html msg
characterCard char =
    let
        tagNameList =
            Card.getTraitList char.cards
    in
    div [ class "character-card" ]
        [ div [ class "wrapper" ]
            [ div [ class "base" ]
                [ div [ class "skillLabel" ] [ text ("キャラクター" ++ "/" ++ "検体") ]
                , div [ class "image" ]
                    [ img [ src char.cardImage ] []
                    , img [ src "" ] []
                    ]
                , div [ class "cardKana" ] [ text char.kana ]
                , div [ class "cardName" ] [ text char.name ]
                , div [ class "attrOrganLabel attrLabel border" ] [ text "変異器官" ]
                , div [ class "attrOrganValue border" ] [ text char.organ ]
                , div [ class "attrMutagenLabel attrLabel border" ] [ text "変異原" ]
                , div [ class "attrMutagenValue border" ] [ text char.mutagen ]
                , div [ class "attrReasonLabel attrLabel border" ] [ text "収容理由" ]
                , div [ class "attrReasonValue border" ] [ text char.reason ]
                , div [ class "attrLaboLabel attrLabel border" ] [ text "研究所" ]
                , div [ class "attrLaboValue attrLabel border" ] [ text char.labo ]
                , div [ class "tags" ] (List.map (\t -> tag t) tagNameList)
                , div [ class "mainContent border" ]
                    [ div [ class "effect " ] [ text ("行動力 : " ++ String.fromInt char.activePower) ]
                    , div [ class "description" ] [ text char.memo ]
                    ]
                , div [ class "bottomContent" ]
                    [ div [ class "cardId" ] [ text "" ]
                    , illustedBy char
                    ]
                ]
            ]
        ]


illustedBy char =
    let
        link url name =
            if name /= "" then
                a [ href url, target "_blank" ] [ text name ]

            else
                text ""

        separator a b =
            if a /= text "" && b /= text "" then
                text ","

            else
                text ""

        illust =
            link char.cardImageCreatorUrl char.cardImageCreatorName
    in
    div [ class "illustedBy" ]
        [ text "illust:"
        , illust
        ]
