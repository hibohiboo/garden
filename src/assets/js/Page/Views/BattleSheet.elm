module Page.Views.BattleSheet exposing (characterListModal, countArea, countController, enemyListModal, inputCharacters, inputEnemies, inputField)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Events.Extra exposing (onChange)
import Html.Lazy exposing (lazy2)
import Models.BattleSheet exposing (BattleSheetCharacter, BattleSheetEnemy, BattleSheetItem, CountAreaItem)
import Models.Character as Character exposing (Character)
import Models.EnemyListItem exposing (EnemyListItem)
import Page.Views.CharacterView exposing (characterCard)
import Page.Views.Enemy exposing (enemyCardMain)
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

                    ulClass =
                        if isShowDetail then
                            ""

                        else
                            "hide"
                in
                div [ class "multiple-characers" ]
                    [ div [ class "triangle-wrapper" ]
                        [ div [ class "characters-title" ]
                            [ div [ class "character-name" ] [ text title ] ]
                        , div [ class "triangle" ] []
                        ]
                    , ul [ class ulClass ] (List.concat [ List.map (\name -> li [ class "character-name" ] [ text name ]) item.characters, List.map (\name -> li [ class "character-name" ] [ text name ]) item.enemies ])
                    ]
    in
    li [ onClick updateMsg ] [ content ]


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


inputCharacters : msg -> (Int -> msg) -> OnChangeMsg msg -> OnChangeMsg msg -> msg -> Array BattleSheetCharacter -> Html msg
inputCharacters =
    inputAreas "character" "キャラクター"


inputEnemies : msg -> (Int -> msg) -> OnChangeMsg msg -> OnChangeMsg msg -> msg -> Array BattleSheetEnemy -> Html msg
inputEnemies =
    inputAreas "enemy" "エネミー"


inputAreas : String -> String -> msg -> (Int -> msg) -> OnChangeMsg msg -> OnChangeMsg msg -> msg -> Array (BattleSheetItem a) -> Html msg
inputAreas fieldId labelName addMsg deleteMsg updateNameMsg updateApMsg openModalMsg arrays =
    div [ style "padding" "5px" ]
        [ div []
            (List.concat
                [ Array.toList <| Array.indexedMap (\i v -> updateArea i fieldId labelName deleteMsg updateNameMsg updateApMsg v) arrays
                , [ lazy2 modalCardOpenButton openModalMsg "一覧から追加" ]
                , addButton labelName addMsg
                ]
            )
        ]



-- インデックス付きの編集


updateArea : Int -> String -> String -> (Int -> msg) -> OnChangeMsg msg -> OnChangeMsg msg -> BattleSheetItem a -> Html msg
updateArea index fieldId labelName deleteMsg updateNameMsg updateApMsg val =
    let
        fid =
            fieldId ++ String.fromInt index
    in
    div [ class "row" ]
        [ div [ class "col s11" ]
            [ div [ style "display" "flex" ]
                [ inputField index (labelName ++ "名") "text" (fid ++ "Name") updateNameMsg val.name
                , inputField index "行動値" "number" (fid ++ "Ap") updateApMsg (String.fromInt val.activePower)
                ]
            ]
        , div [ class "col s1" ]
            [ deleteButton deleteMsg index
            ]
        ]


inputField : Int -> String -> String -> String -> OnChangeMsg msg -> String -> Html msg
inputField index labelName inputType fid updateMsg val =
    div [ class "input-field" ]
        [ input [ placeholder labelName, id fid, type_ inputType, class "validate", value val, onChange (updateMsg index) ] []
        , label [ class "active", for fid ] [ text labelName ]
        ]


deleteButton : (Int -> msg) -> Int -> Html msg
deleteButton deleteMsg index =
    button [ class "btn-small waves-effect waves-light grey", onClick (deleteMsg index) ] [ i [ class "material-icons" ] [ text "delete" ] ]


addButton : String -> msg -> List (Html msg)
addButton labelName addMsg =
    [ span [ style "padding-left" "5px" ] [ text ("空の" ++ labelName ++ "を追加  ") ]
    , button [ class "btn-floating btn-small waves-effect waves-light green", onClick addMsg ] [ i [ class "material-icons" ] [ text "add" ] ]
    ]


enemyListModal : (EnemyListItem -> msg) -> List EnemyListItem -> Html msg
enemyListModal msg enemies =
    div [ class "card-list" ] (enemies |> List.map (\enemy -> div [ onClick (msg enemy) ] [ enemyCardMain enemy ]))


characterListModal : (Character -> msg) -> List Character -> Html msg
characterListModal msg characters =
    div [ class "card-list" ] (characters |> List.map (\char -> div [ onClick (msg char) ] [ characterCard char ]))
