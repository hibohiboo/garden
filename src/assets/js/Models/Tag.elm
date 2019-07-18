module Models.Tag exposing
    ( Tag
    , encodeTagToValue
    , tagDecoder
    , tagsDecoder
    , tagsDecoderFromFireStoreApi
    , tagsDecoderFromJson
    )

import FirestoreApi as FSApi
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E


type alias Tag =
    { name : String
    , level : Int
    }


fromString : String -> Maybe Tag
fromString str =
    case String.split ":" str of
        [ "" ] ->
            Nothing

        [] ->
            Nothing

        name :: level :: _ ->
            Just <| Tag name (String.toInt level |> Maybe.withDefault 0)

        name :: _ ->
            Just <| Tag name 0


tagsDecoder : Decoder (List Tag)
tagsDecoder =
    D.map
        (\str ->
            String.split "," str
                |> List.filterMap fromString
        )
        D.string


tagsDecoderFromJson : Decoder (List Tag)
tagsDecoderFromJson =
    D.oneOf
        [ D.list tagDecoder
        , D.succeed []
        ]


tagDecoder : Decoder Tag
tagDecoder =
    D.map2 Tag
        (D.field "name" D.string)
        (D.field "level" D.int)


tagsDecoderFromFireStoreApi : Decoder (List Tag)
tagsDecoderFromFireStoreApi =
    D.oneOf
        [ FSApi.list tagDecoderFromFireStoreApi

        -- タグが登録されていないとき、{}が返ってくる。対応しないとデコードに失敗するため、そのような場合のためにデコードができなければ空の配列を返す。
        , D.succeed []
        ]


tagDecoderFromFireStoreApi : Decoder Tag
tagDecoderFromFireStoreApi =
    D.succeed Tag
        |> required "name" FSApi.string
        |> optional "level" FSApi.int 0



-- ==============================================================================================
-- エンコーダ
-- ==============================================================================================


encodeTagToValue : Tag -> E.Value
encodeTagToValue tag =
    E.object
        [ ( "name", E.string tag.name )
        , ( "level", E.int tag.level )
        ]
