port module Models.Card exposing
    ( CardData
    , CardLabelData
    , cardDataListDecodeFromJson
    , cardDecodeFromString
    , cardDecoderFromFireStoreApi
    , cardDecoderFromJson
    , cardList
    , cardView
    , encodeCardToValue
    , getActivePower
    , getBases
    , getNotDamagedCardNumber
    , getRange
    , getTraitList
    , illustedBy
    , initCard
    , skillCard
    , updateCardCost
    , updateCardName
    , updateCardTiming
    )

import Array exposing (Array)
import Browser.Dom as Dom
import Browser.Navigation as Navigation
import Dict exposing (Dict)
import FirestoreApi as FSApi
import GoogleSpreadSheetApi as GSAPI
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D exposing (..)
import Json.Decode.Pipeline exposing (custom, hardcoded, optional, required)
import Json.Encode as E
import Models.CardId as CardId exposing (CardId)
import Models.Tag as Tag exposing (Tag, encodeTagToValue, tagDecoder, tagsDecoder)
import Page.Views.Tag exposing (tag)
import Session
import Skeleton exposing (viewLink, viewMain)
import Task exposing (..)
import Url
import Url.Builder
import Utils.List.Extra exposing (findIndex, unique)
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
    , exp : Int
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
    , isUsed : Bool
    , isDamaged : Bool
    }


initCard =
    CardData (CardId.fromString "") "" "" "" 0 "" 0 0 0 "" 0 "" "" [] "" "" "" "" "" "" 0 False False



-- ==============================================================================================
-- HTML
-- ==============================================================================================


cardList : List CardData -> Html msg
cardList cards =
    div [ class "card-list" ] (List.map cardView cards)


skillCard =
    let
        cardData =
            CardData (CardId.fromString "B-001") "走る" "能力" "基本能力" 0 "アクション" 4 0 0 "自身" 1 "移動1" "逃げてもいいし、向かってもいい。\n君たちは何処にだっていける。\n一歩ずつではあるけれど。" [ Tag "移動" 0, Tag "基本" 0 ] "/assets/images/card/main/run.png" "ヒューマンピクトグラム2.0" "http://pictogram2.com/" "/assets/images/card/frame/report.gif" "" "https://google.com" 0 False False
    in
    cardView cardData


cardView : CardData -> Html msg
cardView cardData =
    let
        labelData =
            CardLabelData "能力" "経験点" "タイミング" "コスト" "射程" "対象" "最大Lv" "Lv" "▼効果 :" "▼解説 :"

        range =
            getRange cardData

        maxLvElement elm =
            if cardData.maxLevel <= 1 then
                text ""

            else
                elm

        expElement elm =
            if cardData.exp == 0 then
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
                , div [ class "attrTimingLabel attrLabel border" ] [ text labelData.timing ]
                , div [ class "attrTimingValue border" ] [ text cardData.timing ]
                , div [ class "attrCostLabel attrLabel border" ] [ text labelData.cost ]
                , div [ class "attrCostValue border" ] [ text (String.fromInt cardData.cost) ]
                , div [ class "attrRangeLabel attrLabel border" ] [ text labelData.range ]
                , div [ class "attrRangeValue border" ] [ text range ]
                , div [ class "attrTargetLabel attrLabel border" ] [ text labelData.target ]
                , div [ class "attrTargetValue attrLabel border" ] [ text cardData.target ]
                , expElement (div [ class "attrExpLabel attrLabel border" ] [ text labelData.exp ])
                , expElement (div [ class "attrExpValue border" ] [ text (String.fromInt cardData.exp) ])
                , div [ class "tags" ] (List.map (\t -> tag t.name) cardData.tags)
                , div [ class "mainContent border" ]
                    [ maxLvElement (div [ class "maxLevelLabel border" ] [ text labelData.maxLevel ])
                    , maxLvElement (div [ class "maxLevel border" ] [ text (String.fromInt cardData.maxLevel) ])
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


getRange cardData =
    if cardData.range == cardData.maxRange then
        String.fromInt cardData.range

    else
        String.fromInt cardData.range ++ " ～ " ++ String.fromInt cardData.maxRange


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



-- タグは別のビューで定義
-- tag : Tag -> Html msg
-- tag t =
--     let
--         tagText =
--             if t.level == 0 then
--                 t.name
--             else
--                 t.name ++ ":" ++ String.fromInt t.level
--     in
--     span [ class "tag" ] [ text tagText ]
-- ==============================================================================================
-- デコーダ
-- ==============================================================================================


cardDataListDecodeFromJson : String -> Result Error (List CardData)
cardDataListDecodeFromJson s =
    decodeString (field "values" (D.list cardDecoderFromSpreadSheet)) s


cardDecodeFromString : String -> Result Error CardData
cardDecodeFromString s =
    decodeString cardDecoderFromSpreadSheet s


cardDecoderFromSpreadSheet : Decoder CardData
cardDecoderFromSpreadSheet =
    D.succeed CardData
        |> custom (D.index 0 CardId.decoder)
        |> custom (D.index 1 D.string)
        |> custom (D.index 2 D.string)
        |> custom (D.index 3 D.string)
        |> custom (D.index 4 GSAPI.decoderIntFromString)
        |> custom (D.index 5 D.string)
        |> custom (D.index 6 GSAPI.decoderIntFromString)
        |> custom (D.index 7 GSAPI.decoderIntFromString)
        |> custom (D.index 8 GSAPI.decoderIntFromString)
        |> custom (D.index 9 D.string)
        |> custom (D.index 10 GSAPI.decoderIntFromString)
        |> custom (D.index 11 D.string)
        |> custom (D.index 12 D.string)
        |> custom (D.index 13 tagsDecoder)
        |> custom (D.index 14 D.string)
        |> custom (D.index 15 D.string)
        |> custom (D.index 16 D.string)
        |> custom (D.index 17 D.string)
        |> custom (D.index 18 D.string)
        |> custom (D.index 19 D.string)
        |> custom (D.index 20 GSAPI.decoderIntFromString)
        |> hardcoded False
        |> hardcoded False


cardDecoderFromJson : Decoder CardData
cardDecoderFromJson =
    D.succeed CardData
        |> required "cardId" CardId.decoder
        |> required "cardName" D.string
        |> required "cardType" D.string
        |> required "kind" D.string
        |> required "exp" D.int
        |> required "timing" D.string
        |> required "cost" D.int
        |> required "range" D.int
        |> required "maxRange" D.int
        |> required "target" D.string
        |> required "maxLevel" D.int
        |> required "effect" D.string
        |> required "description" D.string
        |> required "tags" (D.list tagDecoder)
        |> required "imgMain" D.string
        |> required "illustedByName" D.string
        |> required "illustedByUrl" D.string
        |> required "imgFrame" D.string
        |> required "frameByName" D.string
        |> required "frameByUrl" D.string
        |> required "deleteFlag" D.int
        |> optional "isUsed" D.bool False
        |> optional "isDamaged" D.bool False


cardDecoderFromFireStoreApi : Decoder CardData
cardDecoderFromFireStoreApi =
    D.succeed CardData
        |> optional "cardId" (D.map CardId.fromString FSApi.string) (CardId.fromString "")
        |> required "cardName" FSApi.string
        |> optional "cardType" FSApi.string ""
        |> optional "kind" FSApi.string ""
        |> optional "exp" FSApi.int 0
        |> required "timing" FSApi.string
        |> required "cost" FSApi.int
        |> required "range" FSApi.int
        |> optional "maxRange" FSApi.int 0
        |> required "target" FSApi.string
        |> optional "maxLevel" FSApi.int 0
        |> required "effect" FSApi.string
        |> optional "description" FSApi.string ""
        |> optional "tags" Tag.tagsDecoderFromFireStoreApi []
        |> optional "imgMain" FSApi.string ""
        |> optional "illustedByName" FSApi.string ""
        |> optional "illustedByUrl" FSApi.string ""
        |> optional "imgFrame" FSApi.string ""
        |> optional "frameByName" FSApi.string ""
        |> optional "frameByUrl" FSApi.string ""
        |> optional "deleteFlag" FSApi.int 0
        |> optional "isUsed" FSApi.bool False
        |> optional "isDamaged" FSApi.bool False



-- ==============================================================================================
-- エンコーダ
-- ==============================================================================================


encodeCardToValue : CardData -> E.Value
encodeCardToValue card =
    E.object
        [ ( "cardId", CardId.encodeIdToValue card.cardId )
        , ( "cardName", E.string card.cardName )
        , ( "cardType", E.string card.cardType )
        , ( "kind", E.string card.kind )
        , ( "exp", E.int card.exp )
        , ( "timing", E.string card.timing )
        , ( "cost", E.int card.cost )
        , ( "range", E.int card.range )
        , ( "maxRange", E.int card.maxRange )
        , ( "target", E.string card.target )
        , ( "maxLevel", E.int card.maxLevel )
        , ( "effect", E.string card.effect )
        , ( "description", E.string card.description )
        , ( "tags", E.list encodeTagToValue card.tags )
        , ( "imgMain", E.string card.imgMain )
        , ( "illustedByName", E.string card.illustedByName )
        , ( "illustedByUrl", E.string card.illustedByUrl )
        , ( "imgFrame", E.string card.imgFrame )
        , ( "frameByName", E.string card.frameByName )
        , ( "frameByUrl", E.string card.frameByUrl )
        , ( "deleteFlag", E.int card.deleteFlag )
        , ( "isUsed", E.bool card.isUsed )
        , ( "isDamaged", E.bool card.isDamaged )
        ]



-- ==============================================================================================
-- ユーティリティ
-- ==============================================================================================


getTraitList : Array CardData -> List String
getTraitList cards =
    cards
        |> Array.toList
        |> List.filter (\card -> List.member traitTag card.tags)
        |> List.map (\card -> card.tags)
        |> List.concat
        |> List.map (\t -> t.name)
        |> List.filter (\name -> name /= "特性")
        |> unique


traitTag : Tag
traitTag =
    Tag "特性" 0


baseCardTag : Tag
baseCardTag =
    Tag "基本" 0


getBases : List CardData -> List CardData
getBases cards =
    cards
        |> List.filter (\card -> List.member baseCardTag card.tags)



-- 行動タグのレベルを合計して、4を足したものを行動力とする


getActivePower : Array CardData -> Int
getActivePower cards =
    cards
        |> Array.toList
        |> List.map (\card -> card.tags)
        |> List.concat
        |> List.filter (\t -> t.name == "行動力")
        |> List.map (\t -> t.level)
        |> List.foldl (+) 4


getNotDamagedCardNumber : Array CardData -> Int
getNotDamagedCardNumber cards =
    cards
        |> Array.filter (\card -> not card.isDamaged)
        |> Array.length


updateCardName : Int -> String -> Array CardData -> Array CardData
updateCardName index name oldCards =
    case Array.get index oldCards of
        Just card ->
            let
                cards =
                    Array.set index { card | cardName = name } oldCards
            in
            cards

        Nothing ->
            oldCards


updateCardTiming : Int -> String -> Array CardData -> Array CardData
updateCardTiming index value oldCards =
    case Array.get index oldCards of
        Just card ->
            Array.set index { card | timing = value } oldCards

        Nothing ->
            oldCards


updateCardCost : Int -> String -> Array CardData -> Array CardData
updateCardCost index value oldCards =
    case Array.get index oldCards of
        Just card ->
            Array.set index { card | cost = value |> String.toInt |> Maybe.withDefault 0 } oldCards

        Nothing ->
            oldCards
