module Page.Views.BattleSheet exposing (countArea)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)


countArea : List Int -> Int -> Html msg
countArea countList current =
    div [ class "count-area" ]
        [ div [] [ text "カウント" ]
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
