port module Page.RuleBook exposing (Model, Msg(..), init, update, view)

import Browser.Dom as Dom
import Browser.Navigation as Navigation
import Dict exposing (Dict)
import GoogleSpreadSheetApi as GSAPI
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Models.Card as Card
import Session
import Skeleton exposing (viewLink, viewMain)
import Task exposing (..)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.TextStrings as Tx


port openModal : () -> Cmd msg


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , googleSheetApiKey : String
    , id : String
    , modalTitle : String
    , modalContents : Html Msg
    , texts : Dict String String
    , searchCardKind : String
    }


init : Session.Data -> String -> Maybe String -> ( Model, Cmd Msg )
init session apiKey s =
    let
        texts =
            case Session.getTextStrings session of
                Just sheet ->
                    GSAPI.dictFromSpreadSheet sheet

                Nothing ->
                    Dict.empty

        cmd =
            if texts == Dict.empty then
                Session.fetchTextStrings GotTexts apiKey

            else
                Cmd.none
    in
    case s of
        Just id ->
            ( Model session Close apiKey id "" (text "") texts "", Cmd.batch [ jumpToBottom id, cmd ] )

        Nothing ->
            ( initModel session apiKey
            , cmd
            )


initModel : Session.Data -> String -> Model
initModel session apiKey =
    Model session Close apiKey "" "異形器官一覧" (text "") Dict.empty ""


type Msg
    = ToggleNavigation
    | NoOp
    | PageAnchor String
    | ModalOrgan String
    | GotOrgans (Result Http.Error String)
    | GotTexts (Result Http.Error String)
    | ModalTrait String
    | GotTraits (Result Http.Error String)
    | ModalCard String String
    | GotCards (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        PageAnchor id ->
            ( model, Navigation.load id )

        ModalOrgan title ->
            case Session.getOrgans model.session of
                Just sheet ->
                    ( updateTupleListModel { model | modalTitle = title } sheet Session.addOrgans, openModal () )

                Nothing ->
                    ( { model | modalTitle = title }, Session.fetchOrgans GotOrgans model.googleSheetApiKey )

        GotOrgans (Ok json) ->
            ( updateTupleListModel model json Session.addOrgans, openModal () )

        GotOrgans (Err _) ->
            ( model, Cmd.none )

        GotTexts (Ok json) ->
            ( updateTextsModel model json, Cmd.none )

        GotTexts (Err _) ->
            ( model, Cmd.none )

        ModalTrait title ->
            case Session.getTraits model.session of
                Just sheet ->
                    ( updateTupleListModel { model | modalTitle = title } sheet Session.addTraits, openModal () )

                Nothing ->
                    ( { model | modalTitle = title }, Session.fetchTraits GotTraits model.googleSheetApiKey )

        GotTraits (Ok json) ->
            ( updateTupleListModel model json Session.addTraits, openModal () )

        GotTraits (Err _) ->
            ( model, Cmd.none )

        ModalCard title kind ->
            case Session.getCards model.session of
                Just sheet ->
                    ( updateCardListModel { model | modalTitle = title, searchCardKind = kind } sheet Session.addCards, openModal () )

                Nothing ->
                    ( { model | modalTitle = title, searchCardKind = kind }, Session.fetchCards GotCards model.googleSheetApiKey )

        GotCards (Ok json) ->
            ( updateCardListModel model json Session.addCards, openModal () )

        GotCards (Err _) ->
            ( model, Cmd.none )


updateTupleListModel : Model -> String -> (Session.Data -> String -> Session.Data) -> Model
updateTupleListModel model json addSession =
    case GSAPI.tuplesInObjectDecodeFromString json of
        Ok tuples ->
            { model
                | modalContents = tupleList tuples
                , session = addSession model.session json
            }

        Err _ ->
            { model | modalContents = text "error" }


updateTextsModel : Model -> String -> Model
updateTextsModel model json =
    { model
        | texts = GSAPI.dictFromSpreadSheet json
        , session = Session.addTextStrings model.session json
    }


updateCardListModel : Model -> String -> (Session.Data -> String -> Session.Data) -> Model
updateCardListModel model json addSession =
    case Card.cardDataListDecodeFromJson json of
        Ok cards ->
            let
                filteredCards =
                    if model.searchCardKind == "" then
                        cards

                    else
                        List.filter (\card -> card.kind == model.searchCardKind) cards
            in
            { model
                | modalContents = cardList filteredCards
                , session = addSession model.session json
            }

        Err _ ->
            { model | modalContents = text "error" }


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "基本ルール"
    , attrs = [ class naviClass ]
    , kids =
        [ viewMain (viewRulebook model.texts)
        , viewNavi (List.map (\( value, text ) -> NavigationMenu value text) tableOfContents)
        , openNavigationButton ToggleNavigation
        , closeNavigationButton ToggleNavigation
        , modalWindow model.modalTitle model.modalContents
        ]
    }


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


viewNavi : List NavigationMenu -> Html Msg
viewNavi menues =
    let
        navigations =
            List.map
                (\menu ->
                    li []
                        [ a [ onClick (PageAnchor menu.src) ] [ text menu.text ]
                        ]
                )
                menues
    in
    nav [ class "page-nav" ]
        [ ul []
            navigations
        ]


tableOfContents : List ( String, String )
tableOfContents =
    [ ( "/", "トップに戻る" ), ( "#first", "はじめに" ), ( "#world", "ワールド" ) ]


viewRulebook : Dict String String -> Html Msg
viewRulebook texts =
    let
        -- 辞書からテキストを取得する。keyに指定した辞書がない場合は、defaultValueを表示する。
        dicText key defaultValue =
            text (Tx.getText texts key defaultValue)
    in
    div []
        [ div [ class "rulebook-title" ]
            [ div [] [ dicText "rulebook.genre" "孤島異能研究機関崩壊後TRPG" ]
            , h1 [] [ dicText "rulebook.title" "Garden 基本ルールブック" ]
            ]
        , div [ class "content" ]
            [ img [ src "/assets/images/childrens.png", class "front-cover", alt (Tx.getText texts "rulebook.title" "Garden 基本ルールブック") ] []
            , section [ id "first" ]
                [ h1 [] [ dicText "rulebook.section.first.title" "はじめに" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.first.content.1" "舞台設定" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.first.content.2" "どういうゲームか" ]
                , h2 [ id "commonRule" ] [ dicText "rulebook.section.first.notes_for_readming.title" "このルールの読み方" ]
                , div [ class "collection with-header" ]
                    [ div [ class "collection-header" ] [ dicText "rulebook.section.first.notes_for_readming.bracket_type" "かっこの種類" ]
                    , div [ class "collection-item" ] [ dicText "rulebook.section.first.notes_for_readming.bracket_type.1" "【】：キャラクターの〇を表す。" ]
                    , div [ class "collection-item" ] [ dicText "rulebook.section.first.notes_for_readming.bracket_type.2" "《》：特技を表す。" ]
                    , div [ class "collection-item" ] [ dicText "rulebook.section.first.notes_for_readming.bracket_type.3" "＜＞：このゲームで使われる固有名詞を表す。" ]
                    ]
                , div [ class "collection with-header" ]
                    [ div [ class "collection-header" ] [ dicText "rulebook.section.first.regarding_fractions.title" "端数の処理" ]
                    , div [ class "collection-item" ] [ dicText "rulebook.section.first.regarding_fractions.content" "このゲームでは、割り算を行う場合、常に端数は切り上げとする。" ]
                    ]
                ]
            , section
                [ id "world" ]
                [ h1 [] [ dicText "rulebook.section.world.title" "ワールド" ]
                , h2 [] [ dicText "rulebook.section.world.garden.title" "箱庭の島 - ガーデン -" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.world.garden.content" "ガーデンとは" ]
                , h2 [] [ dicText "rulebook.section.world.date_of_collapse.title" "崩壊の日" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.world.date_of_collapse.content" "崩壊の日に起きたこと" ]
                ]
            , section [ id "character", class "content-doc" ]
                [ h1 [] [ dicText "rulebook.section.character.title" "キャラクター" ]
                , p [] [ dicText "rulebook.section.character.description.1" "キャラクターとは" ]
                , h3 [] [ dicText "rulebook.section.character.cardsampel" "データカードサンプル" ]
                , div []
                    [ Card.skillCard
                    ]
                , h2 [] [ dicText "rulebook.section.character.organ.title" "1. 変異器官の決定" ]
                , p [] [ dicText "rulebook.section.character.organ.content" "異能の発生源となる変異器官を選択する。" ]

                --                , modalOpenButton texts ModalOrgan "chart.list.organ.title" "変異器官一覧"
                , modalCardOpenButton texts ModalCard "chart.list.card.title" "変異器官一覧" "器官"
                , h2 [] [ dicText "rulebook.section.character.trait.title" "2. 特性の決定" ]
                , p [] [ dicText "rulebook.section.character.trait.content" "異能の特性を選択する。" ]

                -- , modalOpenButton texts ModalTrait "chart.list.trait.title" "特性一覧"
                , modalCardOpenButton texts ModalCard "chart.list.card.title" "特性一覧" "特性"
                , h2 [] [ dicText "rulebook.section.character.mutagen.title" "3. 変異原の決定" ]
                , p [] [ dicText "rulebook.section.character.mutagen.content" "変異器官の発生原因を選択する。" ]

                -- , modalOpenButton texts ModalTrait "chart.list.mutagen.title" "変異原一覧"
                , modalCardOpenButton texts ModalCard "chart.list.card.title" "変異原一覧" "変異原"
                , h2 [] [ dicText "rulebook.section.character.skill.title" "4. 能力の決定" ]
                , p [] [ dicText "rulebook.section.character.skill.content" "能力とは" ]
                , h3 [] [ dicText "rulebook.section.character.skill.basic.title" "4.1 基本能力の決定" ]
                , p [] [ dicText "rulebook.section.character.skill.basic.content" "基本能力を選択する。" ]
                , modalCardOpenButton texts ModalCard "chart.list.card.title" "基本能力一覧" "基本能力"
                , h2 [] [ dicText "rulebook.section.character.item.title" "5 アイテムの決定" ]
                , modalCardOpenButton texts ModalCard "chart.list.item.title" "アイテム一覧" "アイテム"
                , h3 [] [ dicText "rulebook.section.chart" "チャート" ]
                , modalCardOpenButton texts ModalCard "chart.list.card.title" "データカード一覧" ""
                ]
            , section [ id "battle", class "content-doc" ]
                [ h1 [] [ dicText "rulebook.section.battle.title" "戦闘" ]
                , p [] [ dicText "rulebook.section.battle.content" "戦闘序文" ]
                , h2 [] [ dicText "rulebook.section.battle.pre.title" "戦闘の準備" ]
                , p [] [ dicText "rulebook.section.battle.pre.content" "戦闘の準備について" ]
                , h3 [] [ dicText "rulebook.section.battle.pre.battlesheet.title" "戦闘シートとエリア" ]
                , p [] [ dicText "rulebook.section.battle.pre.battlesheet.content" "エリアへの配置について" ]
                , h3 [] [ dicText "rulebook.section.battle.pre.victoryCondition.title" "勝利条件" ]
                , p [] [ dicText "rulebook.section.battle.pre.victoryCondition.content" "勝利条件について" ]
                , h2 [] [ dicText "rulebook.section.battle.flow.title" "戦闘の流れ" ]
                , p [] [ dicText "rulebook.section.battle.flow.content" "戦闘の流れについて" ]
                , h3 [] [ dicText "rulebook.section.battle.flow.turnStart.title" "ターン開始処理" ]
                , p [] [ dicText "rulebook.section.battle.flow.turnStart.content" "ターン開始処理について" ]
                , h3 [] [ dicText "rulebook.section.battle.flow.countDown.title" "カウントダウン" ]
                , p [] [ dicText "rulebook.section.battle.flow.countDown.content" "カウントダウン処理について" ]
                , h3 [] [ dicText "rulebook.section.battle.flow.turnEnd.title" "ターン終了処理" ]
                , p [] [ dicText "rulebook.section.battle.flow.turnEnd.content" "ターン終了処理について" ]
                , h3 [] [ dicText "rulebook.section.battle.end.title" "戦闘の終了" ]
                , p [] [ dicText "rulebook.section.battle.end.content" "戦闘の終了処理について" ]
                , h2 [] [ dicText "rulebook.section.battle.action.title" "行動" ]
                , p [] [ dicText "rulebook.section.battle.action.content" "行動について" ]
                , h3 [] [ dicText "rulebook.section.battle.action.skill.title" "能力" ]
                , p [] [ dicText "rulebook.section.battle.action.skill.content" "能力について " ]
                , h2 [] [ dicText "rulebook.section.battle.attack.title" "攻撃判定" ]
                , p [] [ dicText "rulebook.section.battle.attack.content" "攻撃判定について" ]
                , h3 [] [ dicText "rulebook.section.battle.attack.damage.title" "ダメージ" ]
                , p [] [ dicText "rulebook.section.battle.attack.damage.content" "ダメージについて" ]
                , h3 [] [ dicText "rulebook.section.battle.attack.roll.title" "判定時の能力の処理" ]
                , p [] [ dicText "rulebook.section.battle.attack.roll.content" "判定時の能力の処理について" ]
                ]
            , section [ id "world-detail" ]
                [ h1 [] [ dicText "rulebook.section.world.detail.title" "ワールド詳細" ]
                , h2 [] [ dicText "rulebook.section.world.mutant.title" "異能因子発現個体群" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.world.mutant.content" "異能因子発現個体群とは" ]
                , h2 [] [ dicText "rulebook.section.world.garden.title" "箱庭の島 - ガーデン -" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.world.garden.content" "ガーデンとは" ]
                , h2 [] [ dicText "rulebook.section.world.sakuraba_city.title" "箱庭の中の箱庭 - 桜庭市 -" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.world.sakuraba_city.content" "桜庭市とは" ]
                , h2 [] [ dicText "rulebook.section.world.date_of_collapse.title" "崩壊の日" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.world.date_of_collapse.content" "崩壊の日に起きたこと" ]
                , h2 [] [ dicText "rulebook.section.world.sakuraba_city_after.title" "崩壊後の桜庭市" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.world.sakuraba_city_after.content" "桜庭市ナワバリバトル" ]
                ]
            ]
        ]


modalOpenButton : Dict String String -> (String -> msg) -> String -> String -> Html msg
modalOpenButton texts modalMsg key defaultValue =
    a [ onClick (modalMsg (Tx.getText texts key defaultValue)), class "waves-effect waves-light btn", href "#" ] [ text (Tx.getText texts key defaultValue) ]


modalCardOpenButton : Dict String String -> (String -> String -> msg) -> String -> String -> String -> Html msg
modalCardOpenButton texts modalMsg key defaultValue kind =
    a [ onClick (modalMsg (Tx.getText texts key defaultValue) kind), class "waves-effect waves-light btn", href "#" ] [ text (Tx.getText texts key defaultValue) ]


tupleList : List ( String, String ) -> Html Msg
tupleList organs =
    dl [ class "collection with-header" ]
        (List.indexedMap
            (\i ( name, description ) ->
                [ dt [] [ text (String.fromInt (i + 1) ++ " : " ++ name) ]
                , dd [] [ text description ]
                ]
            )
            organs
            |> List.concat
        )


cardList : List Card.CardData -> Html Msg
cardList cards =
    div [ class "card-list" ] (List.map Card.cardView cards)


jumpToBottom : String -> Cmd Msg
jumpToBottom id =
    Dom.getViewportOf id
        |> Task.andThen (\info -> Dom.setViewportOf id 0 info.scene.height)
        |> Task.attempt (\_ -> NoOp)
