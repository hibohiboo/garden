port module Models.SandBox.Card exposing
    ( CardData
    , CardLabelData
    , cardDataListDecodeFromJson
    , cardDecodeFromString
    , cardDecoder
    , cardView
    , illustedBy
    , initCard
    , skillCard
    )

import Browser.Dom as Dom
import Browser.Navigation as Navigation
import Dict exposing (Dict)
import GoogleSpreadSheetApi as GSAPI
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D exposing (..)
import Json.Decode.Pipeline exposing (custom, hardcoded, optional, required)
import Json.Encode as E
import Models.CardId as CardId exposing (CardId, decoder, fromString, toString)
import Models.Tag exposing (Tag, tagsDecoder)
import Session
import Skeleton exposing (viewLink, viewMain)
import Task exposing (..)
import Url
import Url.Builder
import Utils.TextStrings as Tx


type alias CardLabelData =
    { skill : String
    , exp : String
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
    { cardId : Maybe CardId
    , cardName : String
    , cardType : String
    , kind : String
    , exp : String
    , timing : String
    , cost : String
    , range : String
    , maxRange : String
    , target : String
    , maxLevel : String
    , effect : String
    , description : String
    , tags : List Tag
    , imgMain : String
    , illustedByName : String
    , illustedByUrl : String
    , imgFrame : String
    , frameByName : String
    , frameByUrl : String
    , deleteFlag : Int
    }


initCard =
    CardData (CardId.fromString "") "" "" "" "" "" "" "" "" "" "" "" "" [] "" "" "" "" "" "" 0



-- ==============================================================================================
-- HTML
-- ==============================================================================================


skillCard =
    let
        cardData =
            CardData (CardId.fromString "B-001") "走る" "能力" "基本能力" "10" "アクション" "4" "0" "0" "自身" "1" "移動1" "逃げてもいいし、向かってもいい。\n君たちは何処にだっていける。\n一歩ずつではあるけれど。" [ Tag "移動" 0, Tag "基本" 0 ] "/assets/images/card/main/run.png" "ヒューマンピクトグラム2.0" "http://pictogram2.com/" "/assets/images/card/frame/report.gif" "" "https://google.com" 0
    in
    cardView cardData


cardView : CardData -> Html msg
cardView cardData =
    let
        labelData =
            CardLabelData "能力" "経験点" "タイミング" "コスト" "射程" "対象" "最大Lv" "Lv" "▼効果 :" "▼解説 :"

        range =
            if cardData.range == cardData.maxRange || cardData.maxRange == "0" then
                cardData.range

            else
                cardData.range ++ " ～ " ++ cardData.maxRange

        maxLvElement elm =
            if cardData.maxLevel == "0" then
                text ""

            else
                elm

        expElement elm =
            if cardData.exp == "0" then
                text ""

            else
                elm

        cardId =
            case cardData.cardId of
                Just id ->
                    CardId.toString id

                Nothing ->
                    ""
    in
    div [ class "skill-card" ]
        [ div [ class "wrapper" ]
            [ div [ class "base" ]
                [ div [ class "skillLabel" ] [ text (cardData.cardType ++ "/" ++ cardData.kind) ]
                , div [ class "image" ]
                    [ img [ src cardData.imgMain ] []
                    , img [ src cardData.imgFrame ] []
                    ]
                , div [ class "cardName" ] [ text cardData.cardName ]
                , div [ class "attrLabel attrTimingLabel border" ] [ text labelData.timing ]
                , div [ class "attrValue attrTimingValue border" ] [ text cardData.timing ]
                , div [ class "attrLabel attrCostLabel  border" ] [ text labelData.cost ]
                , div [ class "attrValue attrCostValue border" ] [ text cardData.cost ]
                , div [ class "attrLabel attrRangeLabel  border" ] [ text labelData.range ]
                , div [ class "attrValue attrRangeValue border" ] [ text range ]
                , div [ class "attrLabel attrTargetLabel  border" ] [ text labelData.target ]
                , div [ class "attrValue attrTargetValue  border" ] [ text cardData.target ]
                , expElement (div [ class "attrLabel attrExpLabel  border" ] [ text labelData.exp ])
                , expElement (div [ class "attrValue attrExpValue border" ] [ text cardData.exp ])
                , div [ class "tags" ] (List.map (\t -> tag t) cardData.tags)
                , div [ class "mainContent border" ]
                    [ maxLvElement (div [ class "maxLevelLabel border" ] [ text labelData.maxLevel ])
                    , maxLvElement (div [ class "maxLevel border" ] [ text cardData.maxLevel ])
                    , maxLvElement (div [ class "lvLavel border" ] [ text labelData.level ])
                    , maxLvElement (div [ class "level border" ] [ text "" ])
                    , div [ class "effect " ] [ text (labelData.effect ++ cardData.effect) ]
                    , div [ class "description" ] [ text (labelData.description ++ cardData.description) ]
                    ]
                , div [ class "bottomContent" ]
                    [ div [ class "cardId" ] [ text cardId ]
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



-- ==============================================================================================
-- デコーダ
-- ==============================================================================================


cardDataListDecodeFromJson : String -> Result Error (List CardData)
cardDataListDecodeFromJson s =
    decodeString (field "values" (D.list cardDecoder)) s


cardDecodeFromString : String -> Result Error CardData
cardDecodeFromString s =
    decodeString cardDecoder s


cardDecoder : Decoder CardData
cardDecoder =
    D.succeed CardData
        |> Json.Decode.Pipeline.custom (D.index 0 CardId.decoder)
        |> Json.Decode.Pipeline.custom (D.index 1 D.string)
        |> Json.Decode.Pipeline.custom (D.index 2 D.string)
        |> Json.Decode.Pipeline.custom (D.index 3 D.string)
        |> Json.Decode.Pipeline.custom (D.index 4 D.string)
        |> Json.Decode.Pipeline.custom (D.index 5 D.string)
        |> Json.Decode.Pipeline.custom (D.index 6 D.string)
        |> Json.Decode.Pipeline.custom (D.index 7 D.string)
        |> Json.Decode.Pipeline.custom (D.index 8 D.string)
        |> Json.Decode.Pipeline.custom (D.index 9 D.string)
        |> Json.Decode.Pipeline.custom (D.index 10 D.string)
        |> Json.Decode.Pipeline.custom (D.index 11 D.string)
        |> Json.Decode.Pipeline.custom (D.index 12 D.string)
        |> Json.Decode.Pipeline.custom (D.index 13 tagsDecoder)
        |> Json.Decode.Pipeline.custom (D.index 14 D.string)
        |> Json.Decode.Pipeline.custom (D.index 15 D.string)
        |> Json.Decode.Pipeline.custom (D.index 16 D.string)
        |> Json.Decode.Pipeline.custom (D.index 17 D.string)
        |> Json.Decode.Pipeline.custom (D.index 18 D.string)
        |> Json.Decode.Pipeline.custom (D.index 19 D.string)
        |> Json.Decode.Pipeline.custom (D.index 20 GSAPI.decoderIntFromString)
