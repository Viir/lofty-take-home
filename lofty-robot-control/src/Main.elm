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
    = UserInputMeasureRoom
    | MeasureRoomResult (Result Http.Error RoomDimensions)



--| UserInputGoTo ( Int, Int )


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


type State
    = Initial
    | RequestingMeasureRoom
    | MeasureRoomErr Http.Error
    | MeasureRoomOk MeasureRoomOkState


type alias MeasureRoomOkState =
    API.RoomDimensions


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
    ( Initial, Cmd.none )


update : Event -> State -> ( State, Cmd Event )
update event stateBefore =
    case event of
        UserInputMeasureRoom ->
            ( RequestingMeasureRoom, cmdFromRequestToServer MeasureRoom )

        MeasureRoomResult (Err error) ->
            ( MeasureRoomErr error, Cmd.none )

        MeasureRoomResult (Ok ok) ->
            ( MeasureRoomOk ok, Cmd.none )



{-
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
-}


subscriptions : State -> Sub Event
subscriptions _ =
    Sub.none


view : State -> Html.Html Event
view state =
    let
        greetingScreen showButton =
            [ Html.text "Greeting text" ]
                |> Html.div []
    in
    case state of
        Initial ->
            greetingScreen True

        RequestingMeasureRoom ->
            greetingScreen False

        MeasureRoomErr error ->
            Html.text ("Failed to measure room dimensions: " ++ describeHttpError error)

        MeasureRoomOk ok ->
            viewMeasureRoomOk ok


viewMeasureRoomOk : MeasureRoomOkState -> Html.Html Event
viewMeasureRoomOk roomDimensions =
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

                                        -- , Html.Events.onClick (UserInputGoTo ( x, y ))
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


describeRequest : RequestToServer -> String
describeRequest request =
    case request of
        MeasureRoom ->
            "Measure room"


serverAddress : String
serverAddress =
    "http://localhost:3000"



{-
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
-}


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
