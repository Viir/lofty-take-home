module Main exposing (main)

import API exposing (RoomDimensions)
import Browser
import Html
import Html.Attributes as HA
import Html.Events
import Http
import Svg
import Svg.Attributes as SA


main : Program () State Event
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type Event
    = MeasureRoomResult (Result Http.Error RoomDimensions)
    | UserInputGoTo ( Int, Int )


type alias AppAction =
    FinishOrContinue SessionResult ContinueSessionStructure


type FinishOrContinue finish continue
    = FinishSession finish
    | ContinueSession continue


type ContinueSessionStructure
    = WaitForPendingRequest RequestToServer
    | SendRequest RequestToServer


type RequestToServer
    = MeasureRoom


type alias SessionResult =
    Result String String


type alias State =
    List Event


chooseNextRequest : State -> FinishOrContinue SessionResult RequestToServer
chooseNextRequest state =
    case measureRoomResultFromState state of
        Nothing ->
            ContinueSession MeasureRoom

        Just (Err measureRoomError) ->
            FinishSession (Err ("Failed to measure room: " ++ describeHttpError measureRoomError))

        Just (Ok roomDimensions) ->
            FinishSession (Err "Not implemented: Continue after learning room size")


chooseNextAction : State -> AppAction
chooseNextAction state =
    case chooseNextRequest state of
        FinishSession finish ->
            FinishSession finish

        ContinueSession continue ->
            {-
               When we introduce events that should not trigger a new request, then we need to branch here and use `WaitForPendingRequest`
            -}
            ContinueSession (SendRequest continue)


cmdFromRequestToServer : RequestToServer -> Cmd Event
cmdFromRequestToServer request =
    case request of
        MeasureRoom ->
            Http.post
                { url = serverAddress ++ "/sonic/measure-room/rectangle"
                , body = Http.emptyBody
                , expect = Http.expectJson MeasureRoomResult API.jsonDecodeMeasureRoomResponse
                }


init : () -> ( State, Cmd Event )
init _ =
    let
        state =
            []

        maybeCmd =
            case chooseNextRequest state of
                FinishSession _ ->
                    Nothing

                ContinueSession request ->
                    Just (cmdFromRequestToServer request)
    in
    ( state, Maybe.withDefault Cmd.none maybeCmd )


update : Event -> State -> ( State, Cmd Event )
update event stateBefore =
    case chooseNextAction stateBefore of
        FinishSession _ ->
            ( stateBefore, Cmd.none )

        _ ->
            let
                state =
                    event :: stateBefore

                maybeCmd =
                    case chooseNextAction state of
                        FinishSession _ ->
                            Nothing

                        ContinueSession (WaitForPendingRequest _) ->
                            Nothing

                        ContinueSession (SendRequest request) ->
                            Just (cmdFromRequestToServer request)
            in
            ( state, Maybe.withDefault Cmd.none maybeCmd )


subscriptions : State -> Sub Event
subscriptions _ =
    Sub.none


view : State -> Html.Html Event
view state =
    let
        currentRequestText =
            case chooseNextRequest state of
                FinishSession (Err sessionError) ->
                    "Session finished with error: " ++ sessionError

                FinishSession (Ok success) ->
                    "Session completed: " ++ success

                ContinueSession request ->
                    "Session continuing: " ++ describeRequest request

        roomElement =
            case measureRoomResultFromState state of
                Nothing ->
                    Html.text "Did not yet measure room dimensions"

                Just (Err error) ->
                    Html.text ("Failed to measure room dimensions: " ++ describeHttpError error)

                Just (Ok roomDimensions) ->
                    let
                        roomBackgroundColor =
                            "black"

                        validLocationsSvgs =
                            List.range 1 roomDimensions.width
                                |> List.concatMap
                                    (\x ->
                                        List.range 1 roomDimensions.length
                                            |> List.map
                                                (\y ->
                                                    Svg.circle
                                                        [ SA.cx (String.fromInt x)
                                                        , SA.cy (String.fromInt y)
                                                        , SA.r "0.1"
                                                        , SA.stroke "none"
                                                        , SA.fill "DarkBlue"
                                                        , Html.Events.onClick (UserInputGoTo ( x, y ))
                                                        ]
                                                        []
                                                )
                                    )
                    in
                    [ Html.text
                        ("Width: "
                            ++ String.fromInt roomDimensions.width
                            ++ ", Length: "
                            ++ String.fromInt roomDimensions.length
                        )
                    , Svg.svg
                        [ SA.width "400px"
                        , SA.height "400px"
                        , SA.viewBox
                            ([ 0, 0, roomDimensions.width + 1, roomDimensions.length + 1 ]
                                |> List.map String.fromInt
                                |> String.join " "
                            )
                        ]
                        (Svg.rect
                            [ SA.fill roomBackgroundColor
                            , SA.x "-1"
                            , SA.y "-1"
                            , SA.width "99"
                            , SA.height "99"
                            ]
                            []
                            :: validLocationsSvgs
                        )
                    ]
                        |> List.map (List.singleton >> Html.div [])
                        |> Html.div []
    in
    [ ( "Status", Html.text currentRequestText )
    , ( "Room", roomElement )
    ]
        |> List.map
            (\( label, htmlElement ) ->
                [ [ Html.text label ] |> Html.h3 []
                , [ htmlElement ] |> Html.div [ HA.style "margin-left" "1em" ]
                ]
                    |> Html.div []
            )
        |> Html.div [ HA.style "margin" "1em" ]


describeRequest : RequestToServer -> String
describeRequest request =
    case request of
        MeasureRoom ->
            "Measure room"


serverAddress : String
serverAddress =
    "http://localhost:3000"


measureRoomResultFromState : State -> Maybe (Result Http.Error RoomDimensions)
measureRoomResultFromState =
    List.filterMap
        (\event ->
            case event of
                MeasureRoomResult measureRoomResult ->
                    Just measureRoomResult

                _ ->
                    Nothing
        )
        >> List.head


describeHttpError : Http.Error -> String
describeHttpError httpError =
    case httpError of
        Http.BadUrl errorMessage ->
            "Bad Url: " ++ errorMessage

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Network Error"

        Http.BadStatus statusCode ->
            "BadStatus: " ++ (statusCode |> String.fromInt)

        Http.BadBody errorMessage ->
            "BadPayload: " ++ errorMessage
