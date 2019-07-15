module Page.CharacterList exposing (Model, Msg, init, initModel, update, view)

import FirestoreApi as FSApi
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Models.CharacterListItem as CharacterListItem exposing (CharacterListItem)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , characters : List CharacterListItem
    , nextToken : String
    }


init : Session.Data -> String -> ( Model, Cmd Msg )
init session token =
    let
        json =
            if token == "" then
                Session.getCharacters session |> Maybe.withDefault ""

            else
                Session.getCharactersWithPageToken session token |> Maybe.withDefault ""

        characters =
            if json == "" then
                []

            else
                CharacterListItem.characterListFromJson json

        nextToken =
            if json == "" then
                ""

            else
                CharacterListItem.nextTokenFromJson json

        cmd =
            if characters == [] && token == "" then
                Session.fetchCharacters GotCharacters

            else if characters == [] then
                Session.fetchCharactersWithPageToken GotCharacters token

            else
                Cmd.none
    in
    ( initModel nextToken session characters
    , cmd
    )


initModel : String -> Session.Data -> List CharacterListItem -> Model
initModel nextToken session characters =
    Model session Close characters nextToken


type Msg
    = ToggleNavigation
    | GotCharacters (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        GotCharacters (Ok json) ->
            ( updateCharactersModel model json, Cmd.none )

        GotCharacters (Err _) ->
            ( model, Cmd.none )


updateCharactersModel : Model -> String -> Model
updateCharactersModel model json =
    { model
        | characters = CharacterListItem.characterListFromJson json
        , session = Session.addCharacters model.session json
        , nextToken = CharacterListItem.nextTokenFromJson json
    }


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "キャラクターリスト"
    , attrs = [ class naviClass ]
    , kids =
        [ viewMain (viewTopPage model)
        , viewNav [ NavigationMenu "" "トップ", NavigationMenu "rulebook" "ルールブック", NavigationMenu "mypage" "マイページ" ]
        , openNavigationButton ToggleNavigation
        , closeNavigationButton ToggleNavigation
        ]
    }


viewTopPage : Model -> Html msg
viewTopPage model =
    div [ class "center" ]
        [ div [ class "" ]
            [ h1 [ style "font-size" "3rem" ] [ text " キャラクター一覧" ]
            ]
        , div []
            [ table []
                [ thead []
                    [ tr []
                        [ th [] [ text "検体名" ]
                        , th [] [ text "研究所" ]
                        ]
                    ]
                , tbody []
                    (List.map
                        (\row ->
                            tr []
                                [ td []
                                    [ a [ href (Url.Builder.absolute [ "character", "view", row.characterId ] []) ]
                                        [ text row.name
                                        ]
                                    ]
                                , td [] [ text row.labo ]
                                ]
                        )
                        model.characters
                    )
                ]
            ]
        , nextPage model.nextToken
        ]


nextPage : String -> Html msg
nextPage token =
    if token == "" then
        text ""

    else
        a [ href (Url.Builder.absolute [ "characters/" ++ token ] []) ] [ text "次のページ" ]
