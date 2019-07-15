module Page.Views.BattleSheet exposing (countArea, countController, inputCharacters, inputEnemies, inputField)

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


inputCharacters : msg -> (Int -> msg) -> (Int -> String -> msg) -> (Int -> String -> msg) -> Array BattleSheetCharacter -> Html msg
inputCharacters =
    inputAreas "character" "キャラクター"


inputEnemies : msg -> (Int -> msg) -> (Int -> String -> msg) -> (Int -> String -> msg) -> Array BattleSheetEnemy -> Html msg
inputEnemies =
    inputAreas "enemy" "エネミー"


inputAreas : String -> String -> msg -> (Int -> msg) -> (Int -> String -> msg) -> (Int -> String -> msg) -> Array { a | name : String, activePower : Int } -> Html msg
inputAreas fieldId labelName addMsg deleteMsg updateNameMsg updateApMsg arrays =
    div []
        [ div []
            (List.concat
                [ Array.toList <| Array.indexedMap (\i v -> updateArea i fieldId labelName v deleteMsg updateNameMsg updateApMsg) arrays
                , addButton labelName addMsg
                ]
            )
        ]



-- インデックス付きの編集


updateArea : Int -> String -> String -> { a | name : String, activePower : Int } -> (Int -> msg) -> (Int -> String -> msg) -> (Int -> String -> msg) -> Html msg
updateArea index fieldId labelName val deleteMsg updateNameMsg updateApMsg =
    let
        fid =
            fieldId ++ String.fromInt index
    in
    div [ class "row" ]
        [ div [ class "col s11" ]
            [ div [ style "display" "flex" ]
                [ inputField index (labelName ++ "名") "text" (fid ++ "Name") updateNameMsg val.name
                , inputField index "行動力" "number" (fid ++ "Ap") updateApMsg (String.fromInt val.activePower)
                ]
            ]
        , div [ class "col s1" ]
            [ deleteButton deleteMsg index
            ]
        ]


inputField : Int -> String -> String -> String -> (Int -> String -> msg) -> String -> Html msg
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
    [ text (labelName ++ "を追加  ")
    , button [ class "btn-floating btn-small waves-effect waves-light green", onClick addMsg ] [ i [ class "material-icons" ] [ text "add" ] ]
    ]
