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
    }


init : Session.Data -> ( Model, Cmd Msg )
init session =
    let
        characters =
            case Session.getCharacters session of
                Just json ->
                    CharacterListItem.characterListFromJson json

                Nothing ->
                    []

        cmd =
            if characters == [] then
                Session.fetchCharacters GotCharacters

            else
                Cmd.none
    in
    ( initModel session characters
    , cmd
    )


initModel : Session.Data -> List CharacterListItem -> Model
initModel session characters =
    Model session Close characters


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
        ]



-- <table>
--         <thead>
--           <tr>
--               <th>Name</th>
--               <th>Item Name</th>
--               <th>Item Price</th>
--           </tr>
--         </thead>
--         <tbody>
--           <tr>
--             <td>Alvin</td>
--             <td>Eclair</td>
--             <td>$0.87</td>
--           </tr>
--           <tr>
--             <td>Alan</td>
--             <td>Jellybean</td>
--             <td>$3.76</td>
--           </tr>
--           <tr>
--             <td>Jonathan</td>
--             <td>Lollipop</td>
--             <td>$7.00</td>
--           </tr>
--         </tbody>
--       </table>
