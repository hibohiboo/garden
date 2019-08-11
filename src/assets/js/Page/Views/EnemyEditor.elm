module Page.Views.EnemyEditor exposing (editArea)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Models.Card as Card
import Models.Character as Character exposing (Character)
import Models.Enemy as Enemy exposing (EditorModel, Enemy, PageState)
import Models.Tag as Tag
import Page.Views.Card exposing (skillsCards, skillsCardsUpdatable)
import Page.Views.Form exposing (OnChangeMsg, inputArea, inputNumberArea, inputTextArea)
import Page.Views.Tag exposing (tag)



-- editArea : OnChangeMsg msg -> OnChangeMsg msg -> EditorModel msg -> Html msg


editArea nameMsg kanaMsg tagsMsg degreeOfThreatMsg activePowerMsg memoMsg creatorNameMsg creatorSiteMsg creatorUrlMsg editor =
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
        , inputArea "cardImageCreatorName" "画像作者" enemy.cardImageCreatorName creatorNameMsg
        , inputArea "cardImageCreatorSite" "画像作者サイト名" enemy.cardImageCreatorSite creatorSiteMsg
        , inputArea "cardImageCreatorUrl" "画像作者サイトURL" enemy.cardImageCreatorUrl creatorUrlMsg
        ]
