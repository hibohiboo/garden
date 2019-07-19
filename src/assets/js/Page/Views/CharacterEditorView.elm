module Page.Views.CharacterEditorView exposing (updateCardArea)

import Array exposing (Array)
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Events.Extra exposing (onChange)
import Models.Card as Card
import Models.Character exposing (Character)
import Models.CharacterEditor as CharacterEditor exposing (EditorModel)
import Models.Tag exposing (Tag)
import Task
import Url
import Url.Builder
import Utils.List.Extra exposing (findIndex)
import Utils.ModalWindow as Modal
import Utils.Util exposing (deleteAt)


updateCardArea : (Int -> msg) -> Bool -> Int -> Card.CardData -> Html msg
updateCardArea deleteMsg isShowCardDetail index card =
    let
        fid =
            "card_" ++ String.fromInt index

        delButton =
            if card.kind == "特性" || card.kind == "変異原" || card.kind == "器官" || card.kind == "基本" then
                text ""

            else
                deleteButton deleteMsg index

        detailClass =
            CharacterEditor.cardDetailClass isShowCardDetail
    in
    div []
        [ div [ class "row" ]
            [ div [ class "col s8" ]
                [ updateCardAreaInputField "カード名" card.cardName (fid ++ "-card_name")
                ]
            , div [ class "col s2" ]
                [ delButton
                ]

            -- , div [ class "col s6" ]
            --     [ updateCardAreaInputField "効果" card.effect (fid ++ "-card_effect")
            --     ]
            ]
        , div [ class "row", class detailClass ]
            [ div [ class "col s4" ]
                [ updateCardAreaInputField "Ti" card.timing (fid ++ "-card_timing")
                ]
            , div [ class "col s2" ]
                [ updateCardAreaInputField "Co" (String.fromInt card.cost) (fid ++ "-card_cost")
                ]
            , div [ class "col s3" ]
                [ updateCardAreaInputField "Ra" (Card.getRange card) (fid ++ "-card_range")
                ]
            , div [ class "col s3" ]
                [ updateCardAreaInputField "Ta" card.target (fid ++ "-card_target")
                ]
            ]
        ]


updateCardAreaInputField : String -> String -> String -> Html msg
updateCardAreaInputField labelText valueText fieldId =
    div [ class "input-field" ]
        [ input [ placeholder labelText, id fieldId, type_ "text", class "validate", value valueText, disabled True ] []
        , label [ class "active", for fieldId ] [ text labelText ]
        ]



-- 削除ボタン


deleteButton : (Int -> msg) -> Int -> Html msg
deleteButton deleteMsg index =
    button [ class "btn-small waves-effect waves-light grey", onClick (deleteMsg index) ] [ i [ class "material-icons" ] [ text "delete" ] ]



-- -- オートコンプリート付き可変の入力欄
-- inputAreasWithAutocomplete : String -> String -> Array String -> (Int -> String -> msg) -> msg -> (Int -> msg) -> String -> List String -> Html msg
-- inputAreasWithAutocomplete fieldId labelName arrays updateMsg addMsg deleteMsg listId autocompleteList =
--     div []
--         [ div []
--             (List.concat
--                 [ Array.toList <| Array.indexedMap (\i v -> updateAreaWithAutoComplete i fieldId labelName v updateMsg deleteMsg listId) arrays
--                 , addButton labelName addMsg
--                 ]
--             )
--         , datalist [ id listId ]
--             (List.map (\s -> option [ value s ] [ text s ]) autocompleteList)
--         ]
-- updateAreaWithAutoComplete : Int -> String -> String -> String -> (Int -> String -> msg) -> (Int -> msg) -> String -> Html msg
-- updateAreaWithAutoComplete idx fieldId labelName val updateMsg deleteMsg listId =
--     let
--         fid =
--             fieldId ++ String.fromInt idx
--     in
--     div [ class "row" ]
--         [ div [ class "col s10" ]
--             [ div [ class "input-field" ]
--                 [ input [ placeholder labelName, id fid, type_ "text", class "validate", value val, onInput (updateMsg idx), autocomplete True, list listId ] []
--                 , label [ class "active", for fid ] [ text labelName ]
--                 ]
--             ]
--         , div [ class "col s2" ]
--             [ deleteButton deleteMsg idx
--             ]
--         ]
-- -- 可変の入力欄
-- inputAreas : String -> String -> Array String -> (Int -> String -> msg) -> msg -> (Int -> msg) -> Html msg
-- inputAreas fieldId labelName arrays updateMsg addMsg deleteMsg =
--     div []
--         [ div []
--             (List.concat
--                 [ Array.toList <| Array.indexedMap (\i v -> updateArea i fieldId labelName v updateMsg deleteMsg) arrays
--                 , addButton labelName addMsg
--                 ]
--             )
--         ]
-- -- インデックス付きの編集
-- updateArea : Int -> String -> String -> String -> (Int -> String -> msg) -> (Int -> msg) -> Html msg
-- updateArea index fieldId labelName val updateMsg deleteMsg =
--     let
--         fid =
--             fieldId ++ String.fromInt index
--     in
--     div [ class "row" ]
--         [ div [ class "col s11" ]
--             [ div [ class "input-field" ]
--                 [ input [ placeholder labelName, id fid, type_ "text", class "validate", value val, onInput (updateMsg index) ] []
--                 , label [ class "active", for fid ] [ text labelName ]
--                 ]
--             ]
--         , div [ class "col s1" ]
--             [ deleteButton deleteMsg index
--             ]
--         ]
