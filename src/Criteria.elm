module Criteria exposing (State, init, Config, config, view)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as E
import Json.Decode as Json

type State = State Bool

type Config msg filter = Config {toMsg : State -> msg, getFilterName : filter -> String, getSubFilters : filter -> List String}

init: State
init = State False

config :
  { toMsg: State -> msg
  , getFilterName : filter -> String
  , getSubFilters : filter -> List String
  } -> Config msg filter
config {toMsg, getFilterName, getSubFilters} =
  Config {toMsg = toMsg, getFilterName = getFilterName, getSubFilters = getSubFilters}



viewSubFilters : List String -> Html msg
viewSubFilters subFilters =
  case subFilters of
    [] -> span [] []
    _ -> div [] <| List.map (\subFilter -> viewFilter subFilter []) subFilters

viewFilter : String -> List String -> Html msg
viewFilter filter subFilters =
  div [style "margin-left" "20px"] [
    label []
      [
        input [type_ "checkbox"] []
      , text filter
      , viewSubFilters subFilters
      ]
    ]


viewFilters: (filter -> String) -> (filter -> List String) -> List filter -> Html msg
viewFilters getFilterName getSubFilters filters =
  div [] <| List.map (\f -> viewFilter (getFilterName f) (getSubFilters f)) filters


view : Config msg filter -> State -> List filter -> Html msg
view (Config {toMsg, getFilterName, getSubFilters}) (State open) filters =
  div []
    [ button [onClick (State (not open)) toMsg ] [text "Open/Close Filters"]
    , div [style "display" (if open then "block" else "none")] [viewFilters getFilterName getSubFilters filters]
    ]

onClick : State -> (State -> msg) -> Attribute msg
onClick state toMsg =
  E.on "click" <| Json.map toMsg <| Json.succeed state
