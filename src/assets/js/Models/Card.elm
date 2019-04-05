port module Models.Card exposing (CardData, CardLabelData, Tag, illustedBy, skillCard, tag)

import Browser.Dom as Dom
import Browser.Navigation as Navigation
import Dict exposing (Dict)
import GoogleSpreadSheetApi as GSAPI
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Session
import Skeleton exposing (viewLink, viewMain)
import Task exposing (..)
import Url
import Url.Builder
import Utils.TextStrings as Tx


type alias CardLabelData =
    { skill : String
    , timing : String
    , cost : String
    , range : String
    , target : String
    , maxLevel : String
    , level : String
    , effect : String
    , description : String
    }


type alias CardData =
    { cardId : String
    , cardName : String
    , cardType : String
    , kind : String
    , timing : String
    , cost : Int
    , range : Int
    , maxRange : Int
    , target : String
    , maxLevel : Int
    , effect : String
    , description : String
    , tags : List Tag
    , imgMain : String
    , illustedByName : String
    , illustedByUrl : String
    , imgFrame : String
    , frameByName : String
    , frameByUrl : String
    }


type alias Tag =
    { name : String
    , level : Int
    }


skillCard =
    let
        labelData =
            CardLabelData "能力" "タイミング" "コスト" "射程" "対象" "最大Lv" "Lv" "▼効果 :" "▼解説 :"

        cardData =
            CardData "B-001" "走る" "能力" "基本能力" "アクション" 4 0 0 "自身" 1 "移動1" "逃げてもいいし、向かってもいい。\n君たちは何処にだっていける。\n一歩ずつではあるけれど。" [ Tag "移動" 0, Tag "基本能力" 0 ] "/assets/images/card/main/run.png" "ヒューマンピクトグラム2.0" "http://pictogram2.com/" "/assets/images/card/frame/report.gif" "" "https://google.com"

        range =
            if cardData.range == cardData.maxRange then
                String.fromInt cardData.range

            else
                String.fromInt cardData.range ++ " ～ " ++ String.fromInt cardData.maxRange
    in
    div [ class "skill-card" ]
        [ div [ class "wrapper" ]
            [ div [ class "base" ]
                [ div [ class "skillLabel" ] [ text (labelData.skill ++ "/" ++ cardData.kind) ]
                , div [ class "image" ]
                    [ img [ src cardData.imgMain ] []
                    , img [ src cardData.imgFrame ] []
                    ]
                , div [ class "cardName" ] [ text cardData.cardName ]
                , div [ class "attrTimingLabel attrLabel border" ] [ text labelData.timing ]
                , div [ class "attrTimingValue border" ] [ text cardData.timing ]
                , div [ class "attrCostLabel attrLabel border" ] [ text labelData.cost ]
                , div [ class "attrCostValue border" ] [ text (String.fromInt cardData.cost) ]
                , div [ class "attrRangeLabel attrLabel border" ] [ text labelData.range ]
                , div [ class "attrRangeValue border" ] [ text range ]
                , div [ class "attrTargetLabel attrLabel border" ] [ text labelData.target ]
                , div [ class "attrTargetValue attrLabel border" ] [ text cardData.target ]
                , div [ class "tags" ] (List.map (\t -> tag t) cardData.tags)
                , div [ class "mainContent border" ]
                    [ div [ class "maxLevelLabel border" ] [ text labelData.maxLevel ]
                    , div [ class "maxLevel border" ] [ text (String.fromInt cardData.maxLevel) ]
                    , div [ class "lvLavel border" ] [ text labelData.level ]
                    , div [ class "level border" ] [ text "" ]
                    , div [ class "effect " ] [ text (labelData.effect ++ cardData.effect) ]
                    , div [ class "description" ] [ text (labelData.description ++ cardData.description) ]
                    ]
                , div [ class "bottomContent" ]
                    [ div [ class "cardId" ] [ text cardData.cardId ]
                    , illustedBy cardData
                    ]
                ]
            ]
        ]


illustedBy cardData =
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
            link cardData.illustedByUrl cardData.illustedByName

        frame =
            link cardData.frameByUrl cardData.frameByName

        separater1 =
            separator illust frame
    in
    div [ class "illustedBy" ]
        [ text "illust:"
        , illust
        , separater1
        , frame
        ]


tag : Tag -> Html msg
tag t =
    let
        tagText =
            if t.level == 0 then
                t.name

            else
                t.name ++ ":" ++ String.fromInt t.level
    in
    span [ class "tag" ] [ text tagText ]
