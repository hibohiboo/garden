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


type alias OnChangeMsg msg =
    String -> msg


updateCardArea : msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> String -> Bool -> Card.CardData -> Html msg
updateCardArea deleteMsg updateNameMsg updateTimingMsg updateCostMsg updateRangeMsg updateMaxRangeMsg updateTargetMsg updateEffectMsg updateDescriptionMsg fid isShowCardDetail card =
    let
        delButton =
            if card.kind == "特性" || card.kind == "変異原" || card.kind == "器官" || card.kind == "基本" then
                text ""

            else
                deleteButton deleteMsg

        detailClass =
            CharacterEditor.cardDetailClass isShowCardDetail
    in
    div []
        [ div [ class "row" ]
            [ div [ class "col s8" ]
                [ updateCardAreaInputField updateNameMsg "カード名" card.cardName (fid ++ "-card_name")
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
                [ updateCardAreaInputField updateTimingMsg "Ti" card.timing (fid ++ "-card_timing")
                ]
            , div [ class "col s2" ]
                [ updateCardAreaInputNumberField updateCostMsg "Co" (String.fromInt card.cost) (fid ++ "-card_cost")
                ]
            , div [ class "col s2" ]
                [ updateCardAreaInputNumberField updateRangeMsg "Ra" (String.fromInt card.range) (fid ++ "-card_range")
                ]
            , div [ class "col s2" ]
                [ updateCardAreaInputNumberField updateMaxRangeMsg "MRa" (String.fromInt card.maxRange) (fid ++ "-card_range")
                ]
            , div [ class "col s2" ]
                [ updateCardAreaInputField updateTargetMsg "Ta" card.target (fid ++ "-card_target")
                ]
            ]
        , div [ class "row", class detailClass ]
            [ div [ class "col s12" ]
                [ updateCardAreaTextAreaField updateEffectMsg "効果" card.effect (fid ++ "-card_effect")
                ]
            ]
        , div [ class "row", class detailClass ]
            [ div [ class "col s12" ]
                [ updateCardAreaTextAreaField updateDescriptionMsg "解説" card.description (fid ++ "-card_description")
                ]
            ]
        ]


updateCardAreaInputField : (String -> msg) -> String -> String -> String -> Html msg
updateCardAreaInputField msg labelText valueText fieldId =
    div [ class "input-field" ]
        [ input [ placeholder labelText, id fieldId, type_ "text", class "validate", value valueText, onChange msg ] []
        , label [ class "active", for fieldId ] [ text labelText ]
        ]


updateCardAreaInputNumberField : (String -> msg) -> String -> String -> String -> Html msg
updateCardAreaInputNumberField msg labelText valueText fieldId =
    div [ class "input-field" ]
        [ input [ placeholder labelText, id fieldId, type_ "number", class "validate", value valueText, onChange msg ] []
        , label [ class "active", for fieldId ] [ text labelText ]
        ]


updateCardAreaTextAreaField : (String -> msg) -> String -> String -> String -> Html msg
updateCardAreaTextAreaField msg labelText valueText fieldId =
    div [ class "input-field" ]
        [ textarea [ placeholder labelText, id fieldId, class "materialize-textarea", value valueText, onChange msg ] []
        , label [ class "active", for fieldId ] [ text labelText ]
        ]



-- 削除ボタン


deleteButton : msg -> Html msg
deleteButton deleteMsg =
    button [ class "btn-small waves-effect waves-light grey", onClick deleteMsg ] [ i [ class "material-icons" ] [ text "delete" ] ]



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
