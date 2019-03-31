port module Page.MyPages.CharacterEditor exposing (Msg(..), editArea, update)

import GoogleSpreadSheetApi as GSAPI exposing (Organ)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Models.Character exposing (..)
import Url
import Url.Builder


type Msg
    = InputName String
    | InputKana String
    | InputOrgan String


update : Msg -> Character -> ( Character, Cmd Msg )
update msg char =
    case msg of
        InputName s ->
            let
                c =
                    { char | name = s }
            in
            ( c, Cmd.none )

        InputKana s ->
            let
                c =
                    { char | kana = s }
            in
            ( c, Cmd.none )

        InputOrgan s ->
            let
                c =
                    { char | organ = s }
            in
            ( c, Cmd.none )


editArea : Character -> EditorModel -> Html Msg
editArea character editor =
    div [ class "character-edit-area" ]
        [ div [ class "input-field" ]
            [ input [ placeholder "名前", id "name", type_ "text", class "validate", value character.name, onInput InputName ] []
            , label [ for "name" ] [ text "名前" ]
            ]
        , div [ class "input-field" ]
            [ input [ placeholder "フリガナ", id "kana", type_ "text", class "validate", value character.kana, onInput InputKana ] []
            , label [ for "kana" ] [ text "フリガナ" ]
            ]
        , organList editor.organs character.organ
        ]


organList : List Organ -> String -> Html Msg
organList organs organ =
    div [ class "input-field" ]
        [ label [ for "organ" ] [ text "変異器官" ]
        , input [ placeholder "変異器官", id "organ", type_ "text", class "validate", autocomplete True, list "organs", value organ, onInput InputOrgan ] []
        , datalist [ id "organs" ]
            (List.map (\o -> option [ value o.name ] [ text o.name ]) organs)
        ]
