module Utils.Modal exposing (modalWindow)

import Html exposing (..)
import Html.Attributes exposing (..)


modalWindow : String -> Html msg -> Html msg
modalWindow title content =
    div [ id "mainModal", class "modal" ]
        [ div [ class "modal-content" ]
            [ h4 [] [ text title ]
            , p [] [ content ]
            ]

        -- elmの遷移と干渉して、 close のときにM.Modal._modalsOpenの値が １から0にならない
        -- , div [ class "modal-footer" ]
        --     [ a [ href "#", class "modal-close waves-effect waves-green btn-flat" ] [ text "閉じる" ]
        --     ]
        ]
