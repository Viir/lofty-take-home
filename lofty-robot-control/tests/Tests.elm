module Tests exposing (..)

import API
import Expect
import Test


suite : Test.Test
suite =
    Test.describe "Parse server responses"
        [ Test.test "Obstacle detected" <|
            \_ ->
                """
{"message":"Looks like I’ve bumped into a wall","obstacleSensorStatus":"OBSTACLE_DETECTED","lightSensorStatus":"DARK"}
"""
                    |> API.parseBumpyMoveResponse
                    |> Expect.equal
                        (Ok
                            { message = "Looks like I’ve bumped into a wall"
                            , obstacleSensorStatus = API.OBSTACLE_DETECTED
                            , lightSensorStatus = API.DARK
                            }
                        )
        , Test.test "Just hoverin'" <|
            \_ ->
                """
{"message":"Just hovering somewhere in the room","obstacleSensorStatus":"IDLE","lightSensorStatus":"DARK"}
"""
                    |> API.parseBumpyMoveResponse
                    |> Expect.equal
                        (Ok
                            { message = "Just hovering somewhere in the room"
                            , obstacleSensorStatus = API.IDLE
                            , lightSensorStatus = API.DARK
                            }
                        )
        ]
