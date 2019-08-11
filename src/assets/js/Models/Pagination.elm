module Models.Pagination exposing
    ( Pagination
    , empty
    , encodePaginationToValue
    , enemyPaginationDecoder
    , init
    , updateToken
    )

import Json.Decode as D
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E
import Models.Enemy as Enemy exposing (Enemy)


type alias UserId =
    String


type alias PageToken =
    String


type alias PageLimit =
    Int


type alias Pagination =
    { storeUserId : UserId
    , limit : PageLimit
    , pageToken : PageToken
    , isNext : Bool
    }


limit : PageLimit
limit =
    2


init : String -> Pagination
init userId =
    Pagination userId limit "" True


empty : Pagination
empty =
    Pagination "" limit "" True


{-| tokenが空の場合、次のページはないものとする
-}
updateToken : String -> Pagination -> Pagination
updateToken token model =
    { model | pageToken = token, isNext = token /= "" }


encodePaginationToValue : Pagination -> E.Value
encodePaginationToValue m =
    E.object
        [ ( "storeUserId", E.string m.storeUserId )
        , ( "limit", E.int m.limit )
        , ( "pageToken", E.string m.pageToken )
        , ( "isNext", E.bool m.isNext )
        ]


enemyPaginationDecoder : D.Decoder ( PageToken, List Enemy )
enemyPaginationDecoder =
    D.succeed Tuple.pair
        |> required "nextPageToken" D.string
        |> required "enemies" (D.list Enemy.enemyDecoder)
