module Criteria exposing (State, init, Config, config, view)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as E
import Json.Decode as Json

type State = State Bool

type Config msg = Config {toMsg : State -> msg}

init: State
init = State False

config : {toMsg: State -> msg} -> Config msg
config {toMsg} = Config {toMsg = toMsg}

view : Config msg -> State -> Html msg
view (Config {toMsg}) (State open) =
  div []
    [ button [onClick (State (not open)) toMsg ] [text "Open/Close Filters"]
    , div [style "display" (if open then "block" else "none")] [ text "list of filters"]
    ]

onClick : State -> (State -> msg) -> Attribute msg
onClick state toMsg =
  E.on "click" <| Json.map toMsg <| Json.succeed state
