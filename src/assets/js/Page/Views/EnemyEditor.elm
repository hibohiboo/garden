module Page.Views.EnemyEditor exposing (editArea)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Events.Extra exposing (onChange)
import Models.Card as Card
import Models.Character as Character exposing (Character)
import Models.Enemy as Enemy exposing (EditorModel, Enemy, PageState)
import Models.Tag as Tag
import Page.Views.Card exposing (skillsCards, skillsCardsUpdatable)
import Page.Views.Form exposing (..)
import Page.Views.Tag exposing (tag)



-- editArea : OnChangeMsg msg -> OnChangeMsg msg -> EditorModel msg -> Html msg


editArea nameMsg kanaMsg tagsMsg degreeOfThreatMsg activePowerMsg memoMsg creatorNameMsg creatorSiteMsg creatorUrlMsg openCardModal toggleDetailMsg deleteCardMsg nameCardMsg timingCardMsg costCardMsg rangeCardMsg maxRangeCardMsg targetCardMsg effectCardMsg descriptionCardMsg tagsCardMsg editor =
    let
        enemy =
            editor.editingEnemy
    in
    div [ class "enemy-edit-area" ]
        [ inputArea "name" "名前" enemy.name nameMsg
        , inputArea "kana" "カナ" enemy.kana kanaMsg
        , inputArea "tags" "タグ(カンマ(区切りで複数 ex. 機械,モブ)" (Tag.tagsToString enemy.tags) tagsMsg
        , inputNumberArea "degreeOfThreat" "脅威度" enemy.degreeOfThreat degreeOfThreatMsg
        , inputNumberArea "activePower" "行動力" enemy.activePower activePowerMsg
        , inputTextArea "memo" "メモ" enemy.memo memoMsg
        , skillArea openCardModal toggleDetailMsg deleteCardMsg nameCardMsg timingCardMsg costCardMsg rangeCardMsg maxRangeCardMsg targetCardMsg effectCardMsg descriptionCardMsg tagsCardMsg enemy editor
        , inputArea "cardImageCreatorName" "画像作者" enemy.cardImageCreatorName creatorNameMsg
        , inputArea "cardImageCreatorSite" "画像作者サイト名" enemy.cardImageCreatorSite creatorSiteMsg
        , inputArea "cardImageCreatorUrl" "画像作者サイトURL" enemy.cardImageCreatorUrl creatorUrlMsg
        ]


skillArea openCardModal toggleDetailMsg deleteCardMsg nameCardMsg timingCardMsg costCardMsg rangeCardMsg maxRangeCardMsg targetCardMsg effectCardMsg descriptionCardMsg tagsCardMsg enemy editor =
    div [ style "padding-bottom" "5px" ]
        [ h5 [] [ text "能力" ]
        , div [] [ label [] [ input [ type_ "checkbox", checked editor.isShowCardDetail, onClick toggleDetailMsg ] [], span [] [ text "詳細を表示" ] ] ]
        , div [ class (Card.cardDetailClass editor.isShowCardDetail) ]
            [ text "Ti:タイミング/Co:コスト/Ra:射程/MRa:最大射程/Ta:対象" ]
        , div []
            (List.concat
                [ [ div [ style "padding" "5px" ] (addButton "能力" openCardModal) ]
                , List.reverse <| Array.toList <| Array.indexedMap (\i card -> updateCardAreaWithMsg deleteCardMsg nameCardMsg timingCardMsg costCardMsg rangeCardMsg maxRangeCardMsg targetCardMsg effectCardMsg descriptionCardMsg tagsCardMsg i editor.isShowCardDetail card) enemy.cards
                ]
            )
        ]


updateCardAreaWithMsg deleteMsg nameMsg timingMsg costMsg rangeMsg maxRangeMsg targetMsg effectMsg descriptionMsg tagsMsg i =
    updateCardArea (deleteMsg i) (nameMsg i) (timingMsg i) (costMsg i) (rangeMsg i) (maxRangeMsg i) (targetMsg i) (effectMsg i) (descriptionMsg i) (tagsMsg i) ("card_" ++ String.fromInt i)


updateCardArea : msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> OnChangeMsg msg -> String -> Bool -> Card.CardData -> Html msg
updateCardArea deleteMsg updateNameMsg updateTimingMsg updateCostMsg updateRangeMsg updateMaxRangeMsg updateTargetMsg updateEffectMsg updateDescriptionMsg updateTagsMsg fid isShowCardDetail card =
    let
        detailClass =
            Card.cardDetailClass isShowCardDetail
    in
    div []
        [ div [ class "row" ]
            [ div [ class "col s8" ] [ updateCardAreaInputField updateNameMsg "カード名" card.cardName (fid ++ "-card_name") ]
            , div [ class "col s2" ] [ deleteButton deleteMsg ]
            ]
        , div [ class "row", class detailClass ]
            [ div [ class "col s12" ] [ updateCardAreaInputField updateTagsMsg "タグ" (Card.getTagsString card) (fid ++ "-card_tags") ]
            ]
        , div [ class "row", class detailClass ]
            [ div [ class "col s4" ] [ updateCardAreaInputField updateTimingMsg "Ti" card.timing (fid ++ "-card_timing") ]
            , div [ class "col s2" ] [ updateCardAreaInputNumberField updateCostMsg "Co" (String.fromInt card.cost) (fid ++ "-card_cost") ]
            , div [ class "col s2" ] [ updateCardAreaInputNumberField updateRangeMsg "Ra" (String.fromInt card.range) (fid ++ "-card_range") ]
            , div [ class "col s2" ] [ updateCardAreaInputNumberField updateMaxRangeMsg "MRa" (String.fromInt card.maxRange) (fid ++ "-card_range") ]
            , div [ class "col s2" ] [ updateCardAreaInputField updateTargetMsg "Ta" card.target (fid ++ "-card_target") ]
            ]
        , div [ class "row", class detailClass ]
            [ div [ class "col s12" ] [ updateCardAreaTextAreaField updateEffectMsg "効果" card.effect (fid ++ "-card_effect") ]
            ]
        , div [ class "row", class detailClass ]
            [ div [ class "col s12" ] [ updateCardAreaTextAreaField updateDescriptionMsg "解説" card.description (fid ++ "-card_description") ]
            ]
        ]


updateCardAreaInputField : OnChangeMsg msg -> String -> String -> String -> Html msg
updateCardAreaInputField msg labelText valueText fieldId =
    div [ class "input-field" ]
        [ input [ placeholder labelText, id fieldId, type_ "text", class "validate", value valueText, onChange msg ] []
        , label [ class "active", for fieldId ] [ text labelText ]
        ]


updateCardAreaInputNumberField : OnChangeMsg msg -> String -> String -> String -> Html msg
updateCardAreaInputNumberField msg labelText valueText fieldId =
    div [ class "input-field" ]
        [ input [ placeholder labelText, id fieldId, type_ "number", class "validate", value valueText, onChange msg ] []
        , label [ class "active", for fieldId ] [ text labelText ]
        ]


updateCardAreaTextAreaField : OnChangeMsg msg -> String -> String -> String -> Html msg
updateCardAreaTextAreaField msg labelText valueText fieldId =
    div [ class "input-field" ]
        [ textarea [ placeholder labelText, id fieldId, class "materialize-textarea", value valueText, onChange msg ] []
        , label [ class "active", for fieldId ] [ text labelText ]
        ]
