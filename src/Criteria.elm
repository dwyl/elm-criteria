module Criteria exposing (Config, State, config, getSelectedFilters, init, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as E
import Json.Decode as Json
import Set exposing (..)


type State
    = State Bool (Set String)


type Config msg filter
    = Config { toMsg : State -> msg, getFilterName : filter -> String, getSubFilters : filter -> List filter }


init : State
init =
    State False Set.empty


config :
    { toMsg : State -> msg
    , getFilterName : filter -> String
    , getSubFilters : filter -> List filter
    }
    -> Config msg filter
config { toMsg, getFilterName, getSubFilters } =
    Config { toMsg = toMsg, getFilterName = getFilterName, getSubFilters = getSubFilters }


viewSubFilters : Config msg filter -> State -> List filter -> Html msg
viewSubFilters configView state subFilters =
    case subFilters of
        [] ->
            span [] []

        _ ->
            div [] <| List.map (\subFilter -> viewFilter configView state subFilter) subFilters


viewFilter : Config msg filter -> State -> filter -> Html msg
viewFilter ((Config { toMsg, getFilterName, getSubFilters }) as configView) ((State _ selectedFilters) as state) filter =
    div [ style "margin-left" "20px" ]
        [ label []
            [ input
                [ type_ "checkbox"
                , checked <| Set.member (getFilterName filter) selectedFilters
                , onClick (toggleFilter (getFilterName filter) state) toMsg
                ]
                []
            , text <| getFilterName filter
            ]
        , viewSubFilters configView state (getSubFilters filter)
        ]


viewFilters : Config msg filter -> State -> List filter -> Html msg
viewFilters configView state filters =
    div [] <| List.map (\filter -> viewFilter configView state filter) filters


view : Config msg filter -> State -> List filter -> Html msg
view ((Config { toMsg }) as configView) ((State open selectedFilters) as state) filters =
    div []
        [ button [ onClick (State (not open) selectedFilters) toMsg ] [ text "Open/Close Filters" ]
        , div
            [ style "display"
                (if open then
                    "block"

                 else
                    "none"
                )
            ]
            [ viewFilters configView state filters ]
        ]


onClick : State -> (State -> msg) -> Attribute msg
onClick state toMsg =
    E.on "click" <| Json.map toMsg <| Json.succeed state


toggleFilter : String -> State -> State
toggleFilter filter ((State open selectedFilters) as state) =
    if Set.member filter selectedFilters then
        State open (Set.remove filter selectedFilters)

    else
        State open (Set.insert filter selectedFilters)


getSelectedFilters : State -> Set String
getSelectedFilters (State _ selectedFilters) =
    selectedFilters
