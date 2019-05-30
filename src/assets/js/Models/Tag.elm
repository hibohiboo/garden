module Models.Tag exposing (Tag, encodeTagToValue, tagDecoder, tagsDecoder)

import Json.Decode as D exposing (Decoder)
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


tagDecoder : Decoder Tag
tagDecoder =
    D.map2 Tag
        (D.field "name" D.string)
        (D.field "level" D.int)



-- ==============================================================================================
-- エンコーダ
-- ==============================================================================================


encodeTagToValue : Tag -> E.Value
encodeTagToValue tag =
    E.object
        [ ( "name", E.string tag.name )
        , ( "level", E.int tag.level )
        ]
