module Page.Views.BattleSheet exposing
    ( characterCards
    , characterListModal
    , countArea
    , countController
    , enemyCards
    , enemyListModal
    , inputCharacters
    , inputEnemies
    , inputField
    , inputSheetName
    , mainAreaTabs
    , positionArea
    , unUsedAllButton
    )

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Events.Extra exposing (onChange)
import Html.Lazy exposing (lazy2, lazy4)
import Json.Decode as D
import Models.BattleSheet exposing (BattleSheetCharacter, BattleSheetEnemy, BattleSheetItem, CountAreaItem, TabState(..))
import Models.Character as Character exposing (Character)
import Models.EnemyListItem as Enemy exposing (EnemyListItem)
import Page.Views.CharacterView exposing (characterCard, characterCardWithCardsUpdatable)
import Page.Views.Enemy exposing (enemyCardMain, enemyCardWithCards, enemyCardWithCardsUpdatable, enemyList)
import Page.Views.Modal exposing (modalCardOpenButton)


countArea : List Int -> Int -> Int -> (Int -> msg) -> List CountAreaItem -> Html msg
countArea countList current openNumber updateMsg areaItems =
    div [ class "count-area" ]
        [ div [ class "count-characters" ]
            [ div [ style "text-align" "center" ] [ i [ class "material-icons" ] [ text "person" ] ]
            , ul [ class "" ] <| Array.toList <| Array.indexedMap (\i c -> countCharacters (i == openNumber) c (updateMsg i)) <| Array.fromList <| areaItems
            ]
        , div [ class "count-numbers" ]
            [ div [ style "text-align" "center" ] [ i [ class "material-icons" ] [ text "schedule" ] ]
            , ul [] <| List.map (\i -> countNumbers i current) countList
            ]
        ]


countNumbers : Int -> Int -> Html msg
countNumbers i current =
    let
        className =
            if i == current then
                "current"

            else
                ""
    in
    li [ class className ] [ text (String.fromInt i) ]


countCharacters : Bool -> CountAreaItem -> msg -> Html msg
countCharacters isShowDetail item updateMsg =
    let
        enemiesCnt =
            List.length item.enemies

        charactersCnt =
            List.length item.characters

        content =
            if enemiesCnt == 0 && charactersCnt == 0 then
                text ""

            else if enemiesCnt == 1 && charactersCnt == 0 then
                let
                    name =
                        item.enemies |> List.head |> Maybe.withDefault ""
                in
                div [ class "triangle-wrapper" ]
                    [ div [ class "character-name" ] [ text name ]
                    , div [ class "triangle" ] []
                    ]

            else if enemiesCnt == 0 && charactersCnt == 1 then
                let
                    name =
                        item.characters |> List.head |> Maybe.withDefault ""
                in
                div [ class "triangle-wrapper" ]
                    [ div [ class "character-name" ] [ text name ]
                    , div [ class "triangle" ] []
                    ]

            else
                let
                    eCnt =
                        if enemiesCnt == 0 then
                            ""

                        else
                            "E:" ++ String.fromInt enemiesCnt

                    cCnt =
                        if charactersCnt == 0 then
                            ""

                        else
                            "C:" ++ String.fromInt charactersCnt

                    title =
                        if eCnt /= "" && cCnt /= "" then
                            eCnt ++ "," ++ cCnt

                        else if eCnt /= "" then
                            eCnt

                        else
                            cCnt

                    stateClass =
                        if isShowDetail then
                            "show-detail"

                        else
                            ""
                in
                div [ class "multiple-characers", class stateClass ]
                    [ div [ class "triangle-wrapper" ]
                        [ div [ class "characters-title" ]
                            [ div [ class "character-name" ] [ text title ] ]
                        , div [ class "triangle" ] []
                        ]
                    , ul [] (List.concat [ List.map (\name -> li [ class "character-name" ] [ text name ]) item.characters, List.map (\name -> li [ class "character-name" ] [ text name ]) item.enemies ])
                    ]
    in
    li [ onClick updateMsg ] [ content ]


inputSheetName : String -> (String -> msg) -> Html msg
inputSheetName name msg =
    div [ class "input-field" ]
        [ input [ id "sheetName", type_ "text", value name, onChange msg ] []
        , label [ class "active" ] [ text "戦闘シート名" ]
        ]


countController : Int -> (String -> msg) -> msg -> msg -> Html msg
countController cnt changeMsg increaseMsg decreaseMsg =
    div [ class "count-controller" ]
        [ div [ class "input-field" ]
            [ input [ id "count", type_ "number", value (String.fromInt cnt), onChange changeMsg ] []
            , label [ class "active" ] [ text "カウント" ]
            ]
        , button [ class "btn-floating waves-effect waves-light red", style "align-self" "center", onClick increaseMsg ] [ i [ class "material-icons" ] [ text "add" ] ]
        , button [ class "btn-floating waves-effect waves-light red", style "align-self" "center", onClick decreaseMsg ] [ i [ class "material-icons" ] [ text "remove" ] ]
        ]


type alias OnChangeMsg msg =
    Int -> String -> msg


inputCharacters : msg -> (Int -> msg) -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> msg -> Array BattleSheetCharacter -> Html msg
inputCharacters =
    inputAreas "character" "PC"


inputEnemies : msg -> (Int -> msg) -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> msg -> Array BattleSheetEnemy -> Html msg
inputEnemies =
    inputAreas "enemy" "エネミー"


inputAreas : String -> String -> msg -> (Int -> msg) -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> msg -> Array (BattleSheetItem a) -> Html msg
inputAreas fieldId labelName addMsg deleteMsg updateNameMsg updateApMsg updatePositionMsg openModalMsg arrays =
    div [ style "padding" "5px" ]
        [ div []
            (List.concat
                [ Array.toList <| Array.indexedMap (\i v -> updateArea i fieldId labelName deleteMsg updateNameMsg updateApMsg updatePositionMsg v) arrays
                , [ lazy2 modalCardOpenButton openModalMsg (labelName ++ "一覧から追加") ]
                , addButton labelName addMsg
                ]
            )
        ]



-- インデックス付きの編集


updateArea : Int -> String -> String -> (Int -> msg) -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> BattleSheetItem a -> Html msg
updateArea index fieldId labelName deleteMsg updateNameMsg updateApMsg updatePositionMsg val =
    let
        fid =
            fieldId ++ String.fromInt index
    in
    div [ class "row" ]
        [ div [ class "col s12" ]
            [ div [ class "input-field-wrapper" ]
                [ inputField index "名前" "text" (fid ++ "Name") updateNameMsg val.name
                , lazy4 apSelectedField (fid ++ "Ap") updateApMsg index (String.fromInt val.activePower)
                , positionSelectdField (fid ++ "position") updatePositionMsg index (String.fromInt val.position)
                , deleteButton deleteMsg index
                ]
            ]
        ]


inputField : Int -> String -> String -> String -> OnChangeMsg msg -> String -> Html msg
inputField index labelName inputType fid updateMsg val =
    div [ class "input-field" ]
        [ input [ placeholder labelName, id fid, type_ inputType, class "validate", value val, onChange (updateMsg index) ] []
        , label [ class "active", for fid ] [ text labelName ]
        ]


apSelectedField fid updateMsg index val =
    selectField -10 20 "行動値" (fid ++ "Ap") updateMsg index val


positionSelectdField : String -> OnChangeMsg msg -> Int -> String -> Html msg
positionSelectdField fid updateMsg index val =
    selectField 1 5 "位置" (fid ++ "position") updateMsg index val


selectField : Int -> Int -> String -> String -> OnChangeMsg msg -> Int -> String -> Html msg
selectField min max labelName fid updateMsg index val =
    div [ class "input-field" ]
        [ select
            [ placeholder labelName, id fid, class "browser-default", value val, onChange (updateMsg index), style "min-width" "60px" ]
            (List.range min max |> List.reverse |> List.map (\i -> String.fromInt i) |> List.map (\num -> option [ value num, selected (val == num) ] [ text num ]))
        , label [ class "active", for fid ] [ text labelName ]
        ]


deleteButton : (Int -> msg) -> Int -> Html msg
deleteButton deleteMsg index =
    button [ class "delete-button btn-small waves-effect waves-light grey", onClick (deleteMsg index) ] [ i [ class "material-icons" ] [ text "delete" ] ]


addButton : String -> msg -> List (Html msg)
addButton labelName addMsg =
    [ div [ onClick addMsg, class "waves-effect waves-light btn" ] [ text "ブランク追加" ]
    ]


enemyListModal : (EnemyListItem -> msg) -> List EnemyListItem -> Html msg
enemyListModal msg enemies =
    div [ class "card-list" ] (enemies |> List.map (\enemy -> div [ onClick (msg enemy) ] [ enemyCardMain enemy ]))


characterListModal : (Character -> msg) -> msg -> String -> List Character -> Html msg
characterListModal characterAddMsg fetchMsg token characters =
    let
        nextButton =
            if token /= "" then
                button [ onClick fetchMsg ] [ text "もっと見る" ]

            else
                text ""
    in
    div []
        [ div [ class "card-list" ] (characters |> List.map (\char -> div [ onClick (characterAddMsg char) ] [ characterCard char ]))
        , nextButton
        ]



-- メインエリア切替


mainAreaTabs : msg -> msg -> msg -> msg -> msg -> TabState -> Html msg
mainAreaTabs inputTabMsg cardTabMsg positionTabMsg summaryTabMsg allTabMsg current =
    let
        inputTabClass =
            case current of
                InputTab ->
                    "active"

                _ ->
                    ""

        cardTabClass =
            case current of
                CardTab ->
                    "active"

                _ ->
                    ""

        positionTabClass =
            case current of
                PositionTab ->
                    "active"

                _ ->
                    ""

        summaryTabClass =
            case current of
                SummaryTab ->
                    "active"

                _ ->
                    ""

        allTabClass =
            getCurrentClassName AllTab current
    in
    ul [ class "tabs" ]
        [ li [ onClick inputTabMsg, class "tab waves-effect waves-light btn", class inputTabClass ] [ span [] [ text "入力" ] ]
        , li [ onClick cardTabMsg, class "tab waves-effect waves-light btn", class cardTabClass ] [ span [] [ text "カード" ] ]
        , li [ onClick positionTabMsg, class "tab waves-effect waves-light btn", class positionTabClass ] [ span [] [ text "盤面" ] ]
        , li [ onClick summaryTabMsg, class "tab waves-effect waves-light btn", class summaryTabClass ] [ span [] [ text "サマリ" ] ]
        , li [ onClick allTabMsg, class "tab waves-effect waves-light btn", class allTabClass ] [ span [] [ text "全て" ] ]
        ]


getCurrentClassName : TabState -> TabState -> String
getCurrentClassName expect actual =
    if expect == actual then
        "active"

    else
        ""


enemyCards : List ( Int, BattleSheetEnemy ) -> (Int -> msg) -> (Int -> Int -> msg) -> (Int -> Int -> msg) -> Html msg
enemyCards enemies toggleMsg toggleCardUsedMsg toggleCardDamagedMsg =
    div []
        [ div [ class "card-list" ] (enemies |> List.map (\( i, bse ) -> enemyCardWithCardsWrapper bse (toggleMsg i) (toggleCardUsedMsg i) (toggleCardDamagedMsg i)))
        ]


enemyCardWithCardsWrapper : BattleSheetEnemy -> msg -> (Int -> msg) -> (Int -> msg) -> Html msg
enemyCardWithCardsWrapper bse toggleMsg toggleCardUsedMsg toggleCardDamagedMsg =
    div [ onClick toggleMsg ] [ enemyCardWithCardsUpdatable (Maybe.withDefault Enemy.init bse.data) bse.isDisplaySkills toggleCardUsedMsg toggleCardDamagedMsg ]


characterCards : List ( Int, BattleSheetCharacter ) -> (Int -> msg) -> (Int -> Int -> msg) -> (Int -> Int -> msg) -> Html msg
characterCards characters toggleMsg toggleCardUsedMsg toggleCardDamagedMsg =
    div []
        [ div [ class "card-list" ] (characters |> List.map (\( i, bsc ) -> characterCardWithCardsWrapper bsc (toggleMsg i) (toggleCardUsedMsg i) (toggleCardDamagedMsg i)))
        ]


characterCardWithCardsWrapper : BattleSheetCharacter -> msg -> (Int -> msg) -> (Int -> msg) -> Html msg
characterCardWithCardsWrapper bsc toggleMsg toggleCardUsedMsg toggleCardDamagedMsg =
    div [ onClick toggleMsg ] [ characterCardWithCardsUpdatable (Maybe.withDefault (Character.initCharacter "") bsc.data) bsc.isDisplaySkills toggleCardUsedMsg toggleCardDamagedMsg ]


positionArea : List { a | name : String, cardImage : String, position : Int, notDamagedCardNumber : Int } -> Html msg
positionArea items =
    div [ class "position-area" ]
        [ div [] [ positionNameArea "エリア5", positionCardArea <| List.filter (\item -> item.position == 5) <| items ]
        , div [] [ positionNameArea "エリア4", positionCardArea <| List.filter (\item -> item.position == 4) <| items ]
        , div [] [ positionNameArea "エリア3", positionCardArea <| List.filter (\item -> item.position == 3) <| items ]
        , div [] [ positionNameArea "エリア2", positionCardArea <| List.filter (\item -> item.position == 2) <| items ]
        , div [] [ positionNameArea "エリア1", positionCardArea <| List.filter (\item -> item.position == 1) <| items ]
        ]


positionNameArea : String -> Html msg
positionNameArea areaName =
    div [ class "area-name" ] [ text areaName ]


positionCardArea : List { a | name : String, cardImage : String, position : Int, notDamagedCardNumber : Int } -> Html msg
positionCardArea items =
    div [ class "position-card-area" ]
        (List.map (\item -> positionCardItem item) items)


positionCardItem : { a | name : String, cardImage : String, notDamagedCardNumber : Int } -> Html msg
positionCardItem item =
    let
        cardImage =
            if item.cardImage == "" then
                text ""

            else
                img [ src item.cardImage ] []

        notDamagedCardNumber =
            if item.notDamagedCardNumber == 0 then
                text ""

            else
                div [ class "not-damaged-card-number" ] [ text (String.fromInt item.notDamagedCardNumber) ]
    in
    div [ class "position-card-item" ]
        [ div [ class "name" ] [ text item.name ]
        , notDamagedCardNumber
        , cardImage
        ]


unUsedAllButton : msg -> Html msg
unUsedAllButton msg =
    div [ onClick msg, class "waves-effect waves-light btn" ] [ span [] [ text "使用済をすべて未使用" ] ]
