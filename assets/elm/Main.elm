module Main exposing (..)

import Html exposing (Html, program, text, div, button)
import Html.Events exposing (onClick)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode
import Debug

main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

init : ( Model, Cmd Msg )
init =
    let
        channel =
            Phoenix.Channel.init "room:lobby"
                |> Phoenix.Channel.withPayload ( Json.Encode.object [ ( "hello", Json.Encode.string "world" ) ] )
                |> Phoenix.Channel.onJoin (always PingServer)
        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel initialModel.phxSocket
    in
        { initialModel | phxSocket = phxSocket } ! [ Cmd.map PhoenixMsg phxCmd ]


initialModel : Model
initialModel =
    { phxSocket = Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "hello" "room:lobby" ReceiveHello
    }

type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    }

type Msg
    = PhoenixMsg (Phoenix.Socket.Msg Msg)
    | PingServer
    | ReceiveHello Json.Encode.Value
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) = Phoenix.Socket.update msg model.phxSocket
            in
               { model | phxSocket = phxSocket } ! [ Cmd.map PhoenixMsg phxCmd ]
        PingServer ->
            let
                _ = Debug.log "hello" "hello"
                payload =
                    Json.Encode.object [ ( "pinghello", Json.Encode.string "pingworld" ) ]
                push_ =
                    Phoenix.Push.init "ping" "room:lobby"
                        |> Phoenix.Push.withPayload payload

                ( phxSocket, phxCmd ) = Phoenix.Socket.push push_ model.phxSocket
            in
               { model | phxSocket = phxSocket } ! [ Cmd.map PhoenixMsg phxCmd ]
        ReceiveHello m ->
            let
                _ = Debug.log "hello" m
            in
                model ! []
        NoOp ->
            model ! []

view : Model -> Html Msg
view model =
    div []
        [ text "hello world"
        , button [ onClick PingServer ] [ text "ping server" ]
        ]

subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg
