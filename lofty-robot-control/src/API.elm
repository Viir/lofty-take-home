module API exposing (..)

import Dict
import Json.Decode


type alias RoomDimensions =
    { width : Int, length : Int }


type BumpyObstacleSensorStatus
    = IDLE
    | OBSTACLE_DETECTED


type BumpyLighSensorStatus
    = DARK
    | BRIGHT


type alias BumpyMoveResponse =
    { obstacleSensorStatus : BumpyObstacleSensorStatus
    , lightSensorStatus : BumpyLighSensorStatus
    , message : String
    }


jsonDecodeMeasureRoomResponse : Json.Decode.Decoder RoomDimensions
jsonDecodeMeasureRoomResponse =
    Json.Decode.map2 RoomDimensions
        (Json.Decode.field "width" Json.Decode.int)
        (Json.Decode.field "length" Json.Decode.int)


parseBumpyMoveResponse : String -> Result String BumpyMoveResponse
parseBumpyMoveResponse =
    Json.Decode.decodeString jsonDecodeBumpyMoveResponse
        >> Result.mapError Json.Decode.errorToString


jsonDecodeBumpyMoveResponse : Json.Decode.Decoder BumpyMoveResponse
jsonDecodeBumpyMoveResponse =
    Json.Decode.map3 BumpyMoveResponse
        (Json.Decode.field "obstacleSensorStatus" jsonDecodeBumpyObstacleSensorStatus)
        (Json.Decode.field "lightSensorStatus" jsonDecodeBumpyLighSensorStatus)
        (Json.Decode.field "message" Json.Decode.string)


jsonDecodeBumpyObstacleSensorStatus : Json.Decode.Decoder BumpyObstacleSensorStatus
jsonDecodeBumpyObstacleSensorStatus =
    Json.Decode.string
        |> Json.Decode.andThen
            (\asString ->
                [ ( "IDLE", IDLE )
                , ( "OBSTACLE_DETECTED", OBSTACLE_DETECTED )
                ]
                    |> Dict.fromList
                    |> Dict.get asString
                    |> Maybe.map Json.Decode.succeed
                    |> Maybe.withDefault (Json.Decode.fail "Unsupported status value")
            )


jsonDecodeBumpyLighSensorStatus : Json.Decode.Decoder BumpyLighSensorStatus
jsonDecodeBumpyLighSensorStatus =
    Json.Decode.string
        |> Json.Decode.andThen
            (\asString ->
                [ ( "DARK", DARK )
                , ( "BRIGHT", BRIGHT )
                ]
                    |> Dict.fromList
                    |> Dict.get asString
                    |> Maybe.map Json.Decode.succeed
                    |> Maybe.withDefault (Json.Decode.fail "Unsupported status value")
            )
