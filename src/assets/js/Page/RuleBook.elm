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
import Utils.ModalWindow as Modal
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.TextStrings as Tx


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , googleSheetApiKey : String
    , id : String
    , modalTitle : String
    , modalContents : Html Msg
    , texts : Dict String String
    , searchCardKind : String
    , modalState : Modal.ModalState
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
            ( Model session Close apiKey id "" (text "") texts "" Modal.Close, Cmd.batch [ jumpToBottom id, cmd ] )

        Nothing ->
            ( initModel session apiKey
            , cmd
            )


initModel : Session.Data -> String -> Model
initModel session apiKey =
    Model session Close apiKey "" "異形器官一覧" (text "") Dict.empty "" Modal.Close


type Msg
    = ToggleNavigation
    | NoOp
    | PageAnchor String
    | ModalReason String
    | GotReasons (Result Http.Error String)
    | GotTexts (Result Http.Error String)
    | ModalTrait String
    | GotTraits (Result Http.Error String)
    | ModalCard String String
    | GotCards (Result Http.Error String)
    | ModalFaq String
    | GotFaqs (Result Http.Error String)
    | ModalSampleCard String
    | CloseModal


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        PageAnchor id ->
            ( model, Navigation.load id )

        ModalReason title ->
            case Session.getReasons model.session of
                Just sheet ->
                    ( updateTupleListModel { model | modalTitle = title, modalState = Modal.Open } sheet Session.addReasons, Cmd.none )

                Nothing ->
                    ( { model | modalTitle = title, modalState = Modal.Open }, Session.fetchReasons GotReasons model.googleSheetApiKey )

        GotReasons (Ok json) ->
            ( updateTupleListModel model json Session.addReasons, Cmd.none )

        GotReasons (Err _) ->
            ( model, Cmd.none )

        GotTexts (Ok json) ->
            ( updateTextsModel model json, Cmd.none )

        GotTexts (Err _) ->
            ( model, Cmd.none )

        ModalTrait title ->
            case Session.getTraits model.session of
                Just sheet ->
                    ( updateTupleListModel { model | modalTitle = title, modalState = Modal.Open } sheet Session.addTraits, Cmd.none )

                Nothing ->
                    ( { model | modalTitle = title, modalState = Modal.Open }, Session.fetchTraits GotTraits model.googleSheetApiKey )

        GotTraits (Ok json) ->
            ( updateTupleListModel model json Session.addTraits, Cmd.none )

        GotTraits (Err _) ->
            ( model, Cmd.none )

        ModalCard title kind ->
            case Session.getCards model.session of
                Just sheet ->
                    ( updateCardListModel { model | modalTitle = title, searchCardKind = kind, modalState = Modal.Open } sheet Session.addCards, Cmd.none )

                Nothing ->
                    ( { model | modalTitle = title, searchCardKind = kind }, Session.fetchCards GotCards model.googleSheetApiKey )

        GotCards (Ok json) ->
            ( updateCardListModel { model | modalState = Modal.Open } json Session.addCards, Cmd.none )

        GotCards (Err _) ->
            ( model, Cmd.none )

        ModalFaq title ->
            case Session.getFaqs model.session of
                Just sheet ->
                    ( updateTupleListModel { model | modalTitle = title, modalState = Modal.Open } sheet Session.addFaqs, Cmd.none )

                Nothing ->
                    ( { model | modalTitle = title }, Session.fetchFaqs GotFaqs model.googleSheetApiKey )

        GotFaqs (Ok json) ->
            ( updateTupleListModel { model | modalState = Modal.Open } json Session.addFaqs, Cmd.none )

        GotFaqs (Err _) ->
            ( model, Cmd.none )

        ModalSampleCard title ->
            ( { model | modalTitle = title, modalContents = viewCardSample model.texts, modalState = Modal.Open }
            , Cmd.none
            )

        CloseModal ->
            ( { model | modalState = Modal.Close }
            , Cmd.none
            )


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

                    else if model.searchCardKind == "アイテム" then
                        List.filter (\card -> card.cardType == model.searchCardKind) cards

                    else
                        List.filter (\card -> card.kind == model.searchCardKind) cards
            in
            { model
                | modalContents = Card.cardList filteredCards
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
        , Modal.view model.modalTitle model.modalContents model.modalState CloseModal
        ]
    }


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
    [ ( "/", "トップに戻る" )

    -- 挙動がおかしいので一旦コメント
    -- , ( "#first", "はじめに" )
    -- , ( "#world", "ワールド" )
    , ( "/mypage", "マイページ" )
    , ( "/characters", "キャラクターリスト" )
    , ( "/enemies", "エネミーリスト" )
    ]


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

                -- , h3 [] [ dicText "rulebook.section.character.cardsampel" "データカードサンプル" ]
                -- , div []
                --     [ Card.skillCard
                --     ]
                , modalOpenButton texts ModalSampleCard "" "データカードの見方"

                -- , viewCardSample texts
                , h2 [] [ dicText "rulebook.section.character.organ.title" "1. 変異器官の決定" ]
                , p [] [ dicText "rulebook.section.character.organ.content" "異能の発生源となる変異器官を選択する。" ]

                --                , modalOpenButton texts ModalOrgan "chart.list.organ.title" "変異器官一覧"
                , modalCardOpenButton texts ModalCard "chart.list.card.title" "変異器官一覧" "器官"
                , h2 [] [ dicText "rulebook.section.character.mutagen.title" "2. 変異原の決定" ]
                , p [] [ dicText "rulebook.section.character.mutagen.content" "変異器官の発生原因を選択する。" ]

                -- , modalOpenButton texts ModalTrait "chart.list.mutagen.title" "変異原一覧"
                , modalCardOpenButton texts ModalCard "chart.list.card.title" "変異原一覧" "変異原"
                , h2 [] [ dicText "rulebook.section.character.trait.title" "3. 特性の決定" ]
                , p [] [ dicText "rulebook.section.character.trait.content" "異能の特性を選択する。" ]

                -- , modalOpenButton texts ModalTrait "chart.list.trait.title" "特性一覧"
                , modalCardOpenButton texts ModalCard "" "特性一覧" "特性"
                , h2 [] [ dicText "rulebook.section.character.skill.title" "4. 能力の決定" ]
                , p [] [ dicText "rulebook.section.character.skill.content" "能力とは" ]
                , h3 [] [ dicText "rulebook.section.character.skill.basic.title" "4.1 基本能力の決定" ]
                , p [] [ dicText "rulebook.section.character.skill.basic.content" "基本能力を選択する。" ]
                , modalCardOpenButton texts ModalCard "" "基本能力一覧" "基本能力"
                , h3 [] [ dicText "" "4.2 共通能力の決定" ]
                , p [] [ dicText "" "共通能力を選択して取得してもよい。" ]
                , modalCardOpenButton texts ModalCard "" "共通能力一覧" "共通能力"
                , h3 [] [ dicText "rulebook.section.character.skill.advance.title" "4.3 特性能力の決定" ]
                , p [] [ dicText "rulebook.section.character.skill.advance.content" "特性能力を選択して取得してもよい。" ]
                , ul [ class "skill-button-list" ]
                    [ li [] [ modalCardOpenButton texts ModalCard "" "特性能力一覧:身体強化" "身体強化" ]
                    , li [] [ modalCardOpenButton texts ModalCard "" "特性能力一覧:精神感応" "精神感応" ]
                    , li [] [ modalCardOpenButton texts ModalCard "" "特性能力一覧:外的念力" "外的念力" ]
                    , li [] [ modalCardOpenButton texts ModalCard "" "特性能力一覧:炎熱" "炎熱" ]
                    , li [] [ modalCardOpenButton texts ModalCard "" "特性能力一覧:氷冷" "氷冷" ]
                    , li [] [ modalCardOpenButton texts ModalCard "" "特性能力一覧:電磁" "電磁" ]
                    , li [] [ modalCardOpenButton texts ModalCard "" "特性能力一覧:流体" "流体" ]
                    ]
                , h2 [] [ dicText "rulebook.section.character.item.title" "5 アイテムの決定" ]
                , p [] [ dicText "rulebook.section.character.item.content" "アイテムを1つ取得する。" ]
                , modalCardOpenButton texts ModalCard "chart.list.item.title" "アイテム一覧" "アイテム"
                , h2 [] [ dicText "rulebook.section.actionpower.title" "6 行動力の決定" ]
                , p [] [ dicText "rulebook.section.actionpower.content" "【 4 + データカードで上昇する行動力】がキャラクターの行動力となる。" ]
                , h2 [] [ dicText "rulebook.section.character.reason.title" "7 理由の決定" ]
                , p [] [ dicText "rulebook.section.character.reason.content" "戦う理由を設定する" ]
                , modalOpenButton texts ModalReason "chart.list.reason.title" "理由一覧"
                , h2 [] [ dicText "rulebook.section.character.laboratory.title" "8 ラボの決定" ]
                , p [] [ dicText "rulebook.section.character.laboratory.content" "収容されていた研究所を設定する" ]
                , h2 [] [ dicText "rulebook.section.chart" "チャート" ]
                , modalCardOpenButton texts ModalCard "chart.list.card.title" "データカード一覧" ""
                ]
            , section [ id "session", class "content-doc" ]
                [ h1 [] [ dicText "rulebook.section.session.title" "セッション" ]
                , p [] [ dicText "rulebook.section.session.content" "セッションとは" ]
                , h2 [] [ dicText "rulebook.section.session.opening.title" "オープニング" ]
                , p [] [ dicText "rulebook.section.session.opening.content" "オープニングとは" ]
                , h2 [] [ dicText "rulebook.section.session.battle.title" "バトル" ]
                , p [] [ dicText "rulebook.section.session.battle.content" "バトルとは" ]
                , h2 [] [ dicText "rulebook.section.session.ending.title" "エンディング" ]
                , p [] [ dicText "rulebook.section.session.ending.content" "エンディングとは" ]
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
                , h3 [] [ dicText "rulebook.section.battle.attack.injury.title" "負傷" ]
                , p [] [ dicText "rulebook.section.battle.attack.injury.content" "負傷について" ]
                , h3 [] [ dicText "rulebook.section.battle.attack.roll.title" "判定時の能力の処理" ]
                , p [] [ dicText "rulebook.section.battle.attack.roll.content" "判定時の能力の処理について" ]
                , h2 [] [ dicText "" "FAQ" ]
                , modalOpenButton texts ModalFaq "faq.title" "FAQ"
                ]
            , section [ id "gm", class "content-doc" ]
                [ h1 [] [ dicText "rulebook.section.gm.title" "GMパート" ]
                , p [] [ dicText "rulebook.section.gm.content" "ここからはGM用の情報を掲載する" ]
                , h2 [] [ dicText "rulebook.section.gm.enemy.title" "エネミー" ]
                , p [] [ dicText "rulebook.section.gm.enemy.content" "エネミーについて" ]
                ]
            , section [ id "world-detail" ]
                [ h1 [] [ dicText "rulebook.section.world.detail.title" "ワールド詳細" ]
                , h2 [] [ dicText "rulebook.section.world.mutant.title" "異能因子発現個体群" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.world.mutant.content" "異能因子発現個体群とは" ]
                , h2 [] [ dicText "rulebook.section.world.garden.title" "箱庭の島 - ガーデン -" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.world.garden.content" "ガーデンとは" ]

                -- , h2 [] [ dicText "rulebook.section.world.sakuraba_city.title" "箱庭の中の箱庭 - 桜庭市 -" ]
                -- , p [ class "content-doc" ] [ dicText "rulebook.section.world.sakuraba_city.content" "桜庭市とは" ]
                , h2 [] [ dicText "rulebook.section.world.date_of_collapse.title" "崩壊の日" ]
                , p [ class "content-doc" ] [ dicText "rulebook.section.world.date_of_collapse.content" "崩壊の日に起きたこと" ]

                -- , h2 [] [ dicText "rulebook.section.world.sakuraba_city_after.title" "崩壊後の桜庭市" ]
                -- , p [ class "content-doc" ] [ dicText "rulebook.section.world.sakuraba_city_after.content" "桜庭市ナワバリバトル" ]
                ]
            ]
        ]


viewCardSample : Dict String String -> Html msg
viewCardSample texts =
    let
        dicText key defaultValue =
            text (Tx.getText texts key defaultValue)
    in
    div [ class "skill-sample-wrapper" ]
        [ div [ class "skill-sample-decoration" ]
            [ div [ style "top" "10px", style "left" "10px" ] [ text "①" ]
            , div [ style "top" "10px", style "left" "120px" ] [ text "②" ]
            , div [ style "top" "50px", style "left" "0px" ] [ text "③" ]
            , div [ style "top" "80px", style "left" "0px" ] [ text "④" ]
            , div [ style "top" "80px", style "left" "80px" ] [ text "⑤" ]
            , div [ style "top" "100px", style "left" "80px" ] [ text "⑥" ]
            , div [ style "top" "120px", style "left" "80px" ] [ text "⑦" ]
            , div [ style "top" "140px", style "left" "80px" ] [ text "⑧" ]
            , div [ style "top" "170px", style "left" "0" ] [ text "⑨" ]
            , div [ style "top" "210px", style "left" "0" ] [ text "⑩" ]
            , div [ style "top" "310px", style "left" "60px" ] [ text "⑪" ]
            ]
        , Card.skillCard
        , div []
            [ div [] [ dicText "rulebook.section.character.card.sample.1" "①：カード名" ]
            , div [] [ dicText "rulebook.section.character.card.sample.2" "②：タイプ/種類" ]
            , div [] [ dicText "rulebook.section.character.card.sample.3" "③：タグ" ]
            , div [] [ dicText "rulebook.section.character.card.sample.4" "④：画像" ]
            , div [] [ dicText "rulebook.section.character.card.sample.5" "⑤：カードの使用タイミング。\n以下の種類がある。\nアクション以外のカードは使用すると使用済となる。\n・アクション:行動で使用できる。\n・常時：常に効果を発揮している。\n・割込：いつでも割込んで使用できる。\n・判定直後：判定ダイスを振った後に使用できる。\n・ダメージ:ダメージ決定時に使用できる。" ]
            , div [] [ dicText "rulebook.section.character.card.sample.6" "⑥：カードを使用するために消費する行動値。" ]
            , div [] [ dicText "rulebook.section.character.card.sample.7" "⑦：対象を選択できるエリアの距離。\nカード使用者のいるエリアを0とする。" ]
            , div [] [ dicText "rulebook.section.character.card.sample.8" "⑧：効果の対象。\n以下の種類がある。\n・自身:カードの使用者。\n・単体:対象1つ。\n・範囲:選択した1エリアに存在する全員。" ]
            , div [] [ dicText "rulebook.section.character.card.sample.9" "⑨：カードの効果。\n複数の場合、左から順に処理する。\n「/」で区切る場合、使用時にどちらか選択する。\n「+」で繋ぐ場合、攻撃判定成功で効果を発揮する。\n以下に代表的な効果をあげる。\n・ダメージn:命中判定を行い、n点のダメージを与える。\n・防御n：n点のダメージを減少する。\n・移動n:nマス以内のエリアに移動する。\n・移動妨害n:移動できるマスをnマス減少する。\n・回復n:負傷状態のカードをn個使用済とする。" ]
            , div [] [ dicText "rulebook.section.character.card.sample.10" "⑩：カードの解説。" ]
            , div [] [ dicText "rulebook.section.character.card.sample.11" "⑪：画像の著作者サイトへのリンク。" ]
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


jumpToBottom : String -> Cmd Msg
jumpToBottom id =
    Dom.getViewportOf id
        |> Task.andThen (\info -> Dom.setViewportOf id 0 info.scene.height)
        |> Task.attempt (\_ -> NoOp)
