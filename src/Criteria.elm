module Criteria exposing
    ( view
    , Config, config
    , State, init
    , selectedIdFilters
    )

{-| This package help you create a hierarchy of "filters"
contained in a dropdown

Have a look at a live [example] and its [code]

[example]: https://dwyl.github.io/elm-criteria/example.html
[code]: https://github.com/dwyl/elm-criteria/blob/master/examples/Example.elm


# View

@docs view


# Config

@docs Config, config


# State

@docs State, init


# Helpers

@docs selectedIdFilters

-}

import Html exposing (Attribute, Html, button, div, input, label, span, text)
import Html.Attributes exposing (checked, style, type_)
import Html.Events as E
import Json.Decode as Json
import Set exposing (Set, empty, insert, member, remove)
import SvgImages exposing (arrowDown, arrowUp)



-- STATE


{-| Define if the hierarchy of filters is open
the set of the selected filters
the set of filters where the sub-filters are displayed
State False Set.empty
-}
type State
    = State Bool (Set String) (Set String)


{-| Initialise the state, ie filters are hidden and no filter selected yet

    import Criteria

    Criteria.init

-}
init : State
init =
    State False Set.empty Set.empty



-- CONFIG


{-| Configuration for displaying the hierarchy of filters
-}
type Config msg filter
    = Config
        { title : String
        , toMsg : State -> msg
        , toId : filter -> String
        , toString : filter -> String
        , getSubFilters : filter -> List filter
        }


{-| Create the configuation to pass in your view.

  - `title` &mdash; A string displayed for the button text
  - `toMsg` &mdash; The message which is responsible for updating the `Criteria.State` in your model
  - `toId` &mdash; A function taking a filter and returning a unique string which represent the filter
  - `tostring` &mdash; A function taking a filter and returning a string which will be used as label in the hierarchy
  - `getSubFilters` &mdash; A fuction taking a filter and returning the a list of its sub-filters

-}
config :
    { title : String
    , toMsg : State -> msg
    , toId : filter -> String
    , toString : filter -> String
    , getSubFilters : filter -> List filter
    }
    -> Config msg filter
config { title, toMsg, toId, toString, getSubFilters } =
    Config
        { title = title
        , toMsg = toMsg
        , toId = toId
        , toString = toString
        , getSubFilters = getSubFilters
        }



-- VIEW


viewToggleSubFilters : Config msg filter -> State -> filter -> Set String -> Html msg
viewToggleSubFilters ((Config { toId, toMsg, getSubFilters }) as c) state filter openSubFilters =
    case getSubFilters filter of
        [] ->
            text ""

        _ ->
            if isFilterOpen (toId filter) openSubFilters then
                span
                    [ style "cursor" "pointer"
                    , onClick (hideSubFilters c filter state) toMsg
                    ]
                    [ arrowUp ]

            else
                span
                    [ style "cursor" "pointer"
                    , onClick (showSubFilters c filter state) toMsg
                    ]
                    [ arrowDown ]


viewSubFilters : Config msg filter -> State -> List filter -> Html msg
viewSubFilters configView state subFilters =
    div [ style "margin-left" "20px" ] <| List.map (\subFilter -> viewFilter configView state subFilter) subFilters


viewFilter : Config msg filter -> State -> filter -> Html msg
viewFilter ((Config { toMsg, toId, toString, getSubFilters }) as configView) ((State _ selectedFilters openSubFilters) as state) filter =
    div []
        [ label [ style "cursor" "pointer" ]
            [ input
                [ type_ "checkbox"
                , checked <| Set.member (toId filter) selectedFilters
                , onClick (toggleFilter (toId filter) state) toMsg
                ]
                []
            , text <| toString filter
            ]
        , viewToggleSubFilters configView state filter openSubFilters
        , if isFilterOpen (toId filter) openSubFilters && not (List.isEmpty (getSubFilters filter)) then
            viewSubFilters configView state (getSubFilters filter)

          else
            text ""
        ]


{-| The view function which take the configuration the state and a list of filters
-}
view : Config msg filter -> State -> List filter -> Html msg
view ((Config { title, toMsg }) as configView) ((State open selectedFilters openSubFilters) as state) filters =
    div []
        [ button [ onClick (State (not open) selectedFilters openSubFilters) toMsg ] [ text title ]
        , div
            [ displayFilters open ]
            (List.map
                (viewFilter configView state)
                filters
            )
        ]



-- HELPERS


{-| The onClick function pass the new state to the message defined with `toMsg`
-}
onClick : State -> (State -> msg) -> Attribute msg
onClick state toMsg =
    E.on "click" <| Json.map toMsg <| Json.succeed state


{-| Update the set of selected filters
-}
toggleFilter : String -> State -> State
toggleFilter filter ((State open selectedFilters openSubFilters) as state) =
    if Set.member filter selectedFilters then
        State open (Set.remove filter selectedFilters) openSubFilters

    else
        State open (Set.insert filter selectedFilters) openSubFilters


{-| Return the set of the selected filters' id
-}
selectedIdFilters : State -> Set String
selectedIdFilters (State _ selectedFilters _) =
    selectedFilters


isFilterOpen : String -> Set String -> Bool
isFilterOpen filterId openSubFilters =
    Set.member filterId openSubFilters


showSubFilters : Config msg filter -> filter -> State -> State
showSubFilters (Config { toId }) filter (State open selectedFilters openSubFilters) =
    let
        openSubFiltersUpdated =
            Set.insert (toId filter) openSubFilters
    in
    State open selectedFilters openSubFiltersUpdated


hideSubFilters : Config msg filter -> filter -> State -> State
hideSubFilters (Config { toId }) filter (State open selectedFilters openSubFilters) =
    let
        openSubFiltersUpdated =
            Set.remove (toId filter) openSubFilters
    in
    State open selectedFilters openSubFiltersUpdated


displayFilters : Bool -> Html.Attribute msg
displayFilters open =
    case open of
        True ->
            style "display" "block"

        False ->
            style "display" "none"
