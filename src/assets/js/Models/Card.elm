port module Models.Card exposing
    ( CardData
    , CardLabelData
    , Tag
    , cardDataListDecodeFromJson
    , cardDecodeFromString
    , cardDecoder
    , illustedBy
    , initCard
    , skillCard
    , tag
    , tagDecoder
    , tagParser
    , tagsDecoder
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
    , deleteFlag : Int
    }


type alias Tag =
    { name : String
    , level : Int
    }


initCard =
    CardData "" "" "" "" "" 0 0 0 "" 0 "" "" [] "" "" "" "" "" "" 0


skillCard =
    let
        labelData =
            CardLabelData "能力" "タイミング" "コスト" "射程" "対象" "最大Lv" "Lv" "▼効果 :" "▼解説 :"

        cardData =
            CardData "B-001" "走る" "能力" "基本能力" "アクション" 4 0 0 "自身" 1 "移動1" "逃げてもいいし、向かってもいい。\n君たちは何処にだっていける。\n一歩ずつではあるけれど。" [ Tag "移動" 0, Tag "基本能力" 0 ] "/assets/images/card/main/run.png" "ヒューマンピクトグラム2.0" "http://pictogram2.com/" "/assets/images/card/frame/report.gif" "" "https://google.com" 0

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


cardDataListDecodeFromJson : String -> Result Error (List CardData)
cardDataListDecodeFromJson s =
    decodeString (field "values" (D.list cardDecoder)) s


cardDecodeFromString : String -> Result Error CardData
cardDecodeFromString s =
    decodeString cardDecoder s


cardDecoder : Decoder CardData
cardDecoder =
    D.succeed CardData
        |> Json.Decode.Pipeline.custom (D.index 0 D.string)
        |> Json.Decode.Pipeline.custom (D.index 1 D.string)
        |> Json.Decode.Pipeline.custom (D.index 2 D.string)
        |> Json.Decode.Pipeline.custom (D.index 3 D.string)
        |> Json.Decode.Pipeline.custom (D.index 4 D.string)
        |> Json.Decode.Pipeline.custom (D.index 5 GSAPI.decoderIntFromString)
        |> Json.Decode.Pipeline.custom (D.index 6 GSAPI.decoderIntFromString)
        |> Json.Decode.Pipeline.custom (D.index 7 GSAPI.decoderIntFromString)
        |> Json.Decode.Pipeline.custom (D.index 8 D.string)
        |> Json.Decode.Pipeline.custom (D.index 9 GSAPI.decoderIntFromString)
        |> Json.Decode.Pipeline.custom (D.index 10 D.string)
        |> Json.Decode.Pipeline.custom (D.index 11 D.string)
        |> Json.Decode.Pipeline.custom (D.index 12 tagsDecoder)
        |> Json.Decode.Pipeline.custom (D.index 13 D.string)
        |> Json.Decode.Pipeline.custom (D.index 14 D.string)
        |> Json.Decode.Pipeline.custom (D.index 15 D.string)
        |> Json.Decode.Pipeline.custom (D.index 16 D.string)
        |> Json.Decode.Pipeline.custom (D.index 17 D.string)
        |> Json.Decode.Pipeline.custom (D.index 18 D.string)
        |> Json.Decode.Pipeline.custom (D.index 19 GSAPI.decoderIntFromString)


tagsDecoder : Decoder (List Tag)
tagsDecoder =
    D.map tagsParser string


tagsParser : String -> List Tag
tagsParser s =
    let
        list =
            String.split "," s
    in
    List.map (\str -> tagParser str) list


tagDecoder : Decoder Tag
tagDecoder =
    D.map tagParser string


tagParser : String -> Tag
tagParser s =
    let
        list =
            String.split ":" s

        name =
            case List.head list of
                Just a ->
                    a

                _ ->
                    s

        value =
            case List.tail list of
                Just t ->
                    case List.head t of
                        Just a ->
                            case String.toInt a of
                                Just n ->
                                    n

                                _ ->
                                    0

                        _ ->
                            0

                _ ->
                    0
    in
    Tag name value
