port module Page.MyPages.CharacterUpdate exposing (Model, Msg, init, initModel, subscriptions, update, view)

import Array
import Browser.Navigation as Navigation
import GoogleSpreadSheetApi as GSAPI
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as D
import Models.Card as Card
import Models.Character as Character exposing (..)
import Models.CharacterEditor exposing (EditorModel)
import Page.MyPages.CharacterEditor as CharacterEditor exposing (deleteModal, editArea)
import Page.MyPages.CharacterView exposing (cardsView)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


port updateCharacter : String -> Cmd msg


port updatedCharacter : (Bool -> msg) -> Sub msg


port deleteCharacter : D.Value -> Cmd msg


port deletedCharacter : (Bool -> msg) -> Sub msg


port getCharacter : ( String, String ) -> Cmd msg


port gotCharacter : (String -> msg) -> Sub msg


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ gotCharacter GotCharacter
        , updatedCharacter UpdatedCharacter
        , deletedCharacter DeletedCharacter
        ]


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , googleSheetApiKey : String
    , character : Character
    , editorModel : EditorModel CharacterEditor.Msg
    }


init : Session.Data -> String -> String -> String -> ( Model, Cmd Msg )
init session apiKey storeUserId characterId =
    let
        reasons =
            case Session.getReasons session of
                Just sheet ->
                    GSAPI.tuplesListFromJson sheet

                Nothing ->
                    []

        reasonsCmd =
            if reasons == [] then
                Session.fetchReasons GotReasons apiKey

            else
                Cmd.none

        traits =
            case Session.getTraits session of
                Just sheet ->
                    GSAPI.tuplesListFromJson sheet

                Nothing ->
                    []

        traitsCmd =
            if traits == [] then
                Session.fetchTraits GotTraits apiKey

            else
                Cmd.none

        cards =
            case Session.getCards session of
                Just sheet ->
                    case Card.cardDataListDecodeFromJson sheet of
                        Ok list ->
                            list

                        Err _ ->
                            []

                Nothing ->
                    []

        cardsCmd =
            if cards == [] then
                Session.fetchCards GotCards apiKey

            else
                Cmd.none
    in
    ( initModel session apiKey storeUserId reasons traits cards
    , Cmd.batch [ getCharacter ( storeUserId, characterId ), reasonsCmd, traitsCmd, cardsCmd ]
    )


initModel : Session.Data -> String -> String -> List ( String, String ) -> List ( String, String ) -> List Card.CardData -> Model
initModel session apiKey storeUserId reasons traits cards =
    let
        editor =
            Models.CharacterEditor.initEditor
    in
    Model session Close apiKey (initCharacter storeUserId) { editor | reasons = reasons, traits = traits, cards = cards }


type Msg
    = ToggleNavigation
    | EditorMsg CharacterEditor.Msg
    | Save
    | GotCharacter String
    | UpdatedCharacter Bool
    | GotReasons (Result Http.Error String)
    | GotTraits (Result Http.Error String)
    | GotCards (Result Http.Error String)
    | DeletedCharacter Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        -- キャラクターデータの更新
        EditorMsg emsg ->
            case emsg of
                CharacterEditor.Delete ->
                    ( model, deleteCharacter (Character.encodeCharacterIdsToValue model.character) )

                _ ->
                    let
                        ( ( char, editor ), s ) =
                            CharacterEditor.update emsg model.character model.editorModel
                    in
                    ( { model | character = char, editorModel = editor }, Cmd.map EditorMsg s )

        Save ->
            ( model, model.character |> encodeCharacter |> updateCharacter )

        GotCharacter s ->
            let
                m =
                    case D.decodeString characterDecoder s of
                        Err a ->
                            initCharacter ""

                        Ok char ->
                            char
            in
            ( { model | character = m }, Cmd.none )

        UpdatedCharacter _ ->
            -- 一旦キャラシートのキャッシュを削除
            ( { model | session = Session.deleteCharacter model.session model.character.characterId }, Navigation.load (Url.Builder.absolute [ "mypage" ] []) )

        GotReasons (Ok json) ->
            case GSAPI.tuplesInObjectDecodeFromString json of
                Ok reasons ->
                    let
                        oldEditorModel =
                            model.editorModel

                        newEditorModel =
                            { oldEditorModel | reasons = reasons }
                    in
                    ( { model
                        | editorModel = newEditorModel
                        , session = Session.addReasons model.session json
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        GotReasons (Err _) ->
            ( model, Cmd.none )

        GotTraits (Ok json) ->
            case GSAPI.tuplesInObjectDecodeFromString json of
                Ok traits ->
                    let
                        oldEditorModel =
                            model.editorModel

                        newEditorModel =
                            { oldEditorModel | traits = traits }
                    in
                    ( { model
                        | editorModel = newEditorModel
                        , session = Session.addTraits model.session json
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        GotTraits (Err _) ->
            ( model, Cmd.none )

        GotCards (Ok json) ->
            case Card.cardDataListDecodeFromJson json of
                Ok cards ->
                    let
                        oldEditorModel =
                            model.editorModel

                        newEditorModel =
                            { oldEditorModel | cards = cards }
                    in
                    ( { model
                        | editorModel = newEditorModel
                        , session = Session.addCards model.session json
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        GotCards (Err _) ->
            ( model, Cmd.none )

        DeletedCharacter _ ->
            ( model, Navigation.load (Url.Builder.absolute [ "mypage" ] []) )


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "更新"
    , attrs = [ class naviClass, class "character-sheet" ]
    , kids =
        [ viewMain <| viewHelper model
        ]
    }


viewHelper : Model -> Html Msg
viewHelper model =
    div [ class "" ]
        [ h1 []
            [ text "更新" ]
        , div
            [ class "edit-karte" ]
            [ edit model

            -- , karte model
            , cardsView model.character
            ]
        ]


edit : Model -> Html Msg
edit model =
    div [ class "edit-area" ]
        [ Html.map EditorMsg (editArea model.character model.editorModel)
        , button [ onClick Save, class "btn waves-effect waves-light", type_ "button", name "save" ]
            [ text "更新"
            , i [ class "material-icons right" ] [ text "send" ]
            ]
        , Html.map EditorMsg (deleteModal model.character model.editorModel)
        ]


karte : Model -> Html Msg
karte model =
    let
        char =
            model.character
    in
    div [ class "karte" ]
        [ div [ class "label-personal" ] [ text "個体識別用情報" ]
        , div [ class "label-kana" ] [ text "フリガナ" ]
        , div [ class "kana" ] [ text char.kana ]
        , div [ class "label-name" ] [ text "名前" ]
        , div [ class "name" ] [ text char.name ]
        , div [ class "label-organ" ] [ text "変異器官" ]
        , div [ class "organ" ] [ text char.organ ]
        , div [ class "outer-line" ] []
        ]
