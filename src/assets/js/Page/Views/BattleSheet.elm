module Page.Views.BattleSheet exposing (countArea, countController, inputEnemies)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Events.Extra exposing (onChange)
import Models.BattleSheet exposing (..)


countArea : List Int -> Int -> Html msg
countArea countList current =
    div [ class "count-area" ]
        [ div [ style "text-align" "center" ] [ i [ class "material-icons" ] [ text "schedule" ] ]
        , ul [] <|
            List.map
                (\i ->
                    li
                        [ class
                            (if i == current then
                                "current"

                             else
                                ""
                            )
                        ]
                        [ text (String.fromInt i) ]
                )
                countList
        ]


countController : Int -> (String -> msg) -> msg -> msg -> Html msg
countController cnt changeMsg increaseMsg decreaseMsg =
    div [ style "display" "flex", style "margin" "0 auto", style "width" "fit-content" ]
        [ div [ class "input-field", style "width" "4rem", style "display" "flex", style "margin-right" "10px" ]
            [ input [ id "count", type_ "number", value (String.fromInt cnt), onChange changeMsg ] []
            , label [ class "active" ] [ text "カウント" ]
            ]
        , button [ class "btn-floating waves-effect waves-light red", style "align-self" "center", onClick increaseMsg ] [ i [ class "material-icons" ] [ text "add" ] ]
        , button [ class "btn-floating waves-effect waves-light red", style "align-self" "center", onClick decreaseMsg ] [ i [ class "material-icons" ] [ text "remove" ] ]
        ]


inputEnemies : msg -> (Int -> msg) -> (Int -> String -> msg) -> Array BattleSheetEnemy -> Html msg
inputEnemies =
    inputAreas "enemy" "エネミー"



-- 可変の入力欄


inputAreas : String -> String -> msg -> (Int -> msg) -> (Int -> String -> msg) -> Array (BattleSheetItem a) -> Html msg
inputAreas fieldId labelName addMsg deleteMsg updateMsg arrays =
    div []
        [ div []
            (List.concat
                [ Array.toList <| Array.indexedMap (\i v -> updateArea i fieldId labelName v updateMsg deleteMsg) arrays
                , addButton labelName addMsg
                ]
            )
        ]



-- インデックス付きの編集


updateArea : Int -> String -> String -> BattleSheetItem a -> (Int -> String -> msg) -> (Int -> msg) -> Html msg
updateArea index fieldId labelName val updateMsg deleteMsg =
    let
        fid =
            fieldId ++ String.fromInt index
    in
    div [ class "row" ]
        [ div [ class "col s11" ]
            [ div [ class "input-field" ]
                [ input [ placeholder labelName, id fid, type_ "text", class "validate", value val.name, onChange (updateMsg index) ] []
                , label [ class "active", for fid ] [ text labelName ]
                ]
            ]
        , div [ class "col s1" ]
            [ deleteButton deleteMsg index
            ]
        ]



-- 削除ボタン


deleteButton : (Int -> msg) -> Int -> Html msg
deleteButton deleteMsg index =
    button [ class "btn-small waves-effect waves-light grey", onClick (deleteMsg index) ] [ i [ class "material-icons" ] [ text "delete" ] ]



-- 追加ボタン


addButton : String -> msg -> List (Html msg)
addButton labelName addMsg =
    [ text (labelName ++ "を追加  ")
    , button [ class "btn-floating btn-small waves-effect waves-light green", onClick addMsg ] [ i [ class "material-icons" ] [ text "add" ] ]
    ]
