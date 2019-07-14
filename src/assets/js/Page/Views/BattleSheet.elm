module Page.Views.BattleSheet exposing (countArea, countController)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Events.Extra exposing (onChange)


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
