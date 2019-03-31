port module Page.MyPages.CharacterEditor exposing (Msg(..), editArea, update)

import Array exposing (Array)
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
    | AddTrait


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

        AddTrait ->
            let
                c =
                    { char | traits = Array.push "" char.traits }
            in
            ( c, Cmd.none )



-- 単純な入力


inputArea : String -> String -> String -> (String -> msg) -> Html msg
inputArea fieldId labelName val toMsg =
    div [ class "input-field" ]
        [ input [ placeholder labelName, id fieldId, type_ "text", class "validate", value val, onInput toMsg ] []
        , label [ for fieldId ] [ text labelName ]
        ]



-- 単純な入力。オートコンプリート付き


inputAreaWithAutocomplete : String -> String -> String -> (String -> msg) -> String -> List String -> Html msg
inputAreaWithAutocomplete fieldId labelName val toMsg listId autocompleteList =
    div [ class "input-field" ]
        [ input [ placeholder labelName, id fieldId, type_ "text", class "validate", value val, onInput toMsg, autocomplete True, list listId ] []
        , label [ for fieldId ] [ text labelName ]
        , datalist [ id listId ]
            (List.map (\s -> option [ value s ] [ text s ]) autocompleteList)
        ]


inputAreas : String -> String -> Array String -> (String -> msg) -> msg -> Html msg
inputAreas fieldId labelName arrays updateMsg addMsg =
    div []
        [ div []
            (List.concat
                [ Array.toList <| Array.map (\v -> inputArea fieldId labelName v updateMsg) arrays
                , addButton labelName addMsg
                ]
            )
        ]


addButton : String -> msg -> List (Html msg)
addButton labelName addMsg =
    [ text (labelName ++ "を追加  ")
    , button [ class "btn-floating btn-small waves-effect waves-light green", onClick addMsg ] [ i [ class "material-icons" ] [ text "add" ] ]
    ]


editArea : Character -> EditorModel -> Html Msg
editArea character editor =
    div [ class "character-edit-area" ]
        [ inputArea "name" "名前" character.name InputName
        , inputArea "kana" "フリガナ" character.name InputKana
        , inputAreaWithAutocomplete "organ" "変異器官" character.organ InputOrgan "organs" (List.map (\o -> o.name) editor.organs)
        , inputAreas "traits" "特性" character.traits InputKana AddTrait
        ]
