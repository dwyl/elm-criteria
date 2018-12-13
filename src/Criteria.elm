module Criteria exposing
    ( view
    , Config, config
    , State, init
    , customConfig, defaultCustomisations
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


# Customise

@docs customConfig, defaultCustomisations


# Helpers

@docs selectedIdFilters

-}

import Html exposing (Attribute, Html, button, div, input, label, span, text)
import Html.Attributes exposing (checked, class, style, type_)
import Html.Events as E
import Json.Decode as Json
import Set exposing (Set, empty, insert, member, remove)
import SvgImages exposing (arrowDown, arrowUp)



-- STATE


type alias FilterId =
    String


{-| Define if the hierarchy of filters is open
the set of the selected filters
the set of filters where the sub-filters are displayed
State False Set.empty
-}
type State
    = State Bool (Set FilterId) (Set FilterId)


{-| Initialise the state, ie filters are hidden and filters are selected based
on the list of ids passed as first argument to the `init` function

    import Criteria

    Criteria.init ["idFilter1", "idFilter5"]

-}
init : List FilterId -> State
init selectedFilterIds =
    State False (Set.fromList selectedFilterIds) Set.empty



-- CONFIG


{-| Configuration for displaying the hierarchy of filters
-}
type Config msg filter
    = Config
        { title : String
        , toMsg : State -> msg
        , toId : filter -> FilterId
        , toString : filter -> String
        , getSubFilters : filter -> List filter
        , customisations : Customisations filter msg
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
    , toId : filter -> FilterId
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
        , customisations = defaultCustomisations
        }


{-| Create a customised configuation.
This function is similat to `config`.
It takes one more value `customisations` which defined
how to customise the element of the module
-}
customConfig :
    { title : String
    , toMsg : State -> msg
    , toId : filter -> FilterId
    , toString : filter -> String
    , getSubFilters : filter -> List filter
    , customisations : Customisations filter msg
    }
    -> Config msg filter
customConfig { title, toMsg, toId, toString, getSubFilters, customisations } =
    Config
        { title = title
        , toMsg = toMsg
        , toId = toId
        , toString = toString
        , getSubFilters = getSubFilters
        , customisations = customisations
        }



-- CUSTOMISATIONS


{-| The Customisations type alias define how the element can be customised.
The functions are returning an `List (Attribute msg)` value, so a class, id,
event... can be added to the html elements of the module
-}
type alias Customisations filter msg =
    { mainDivAttrs : List (Attribute msg)
    , buttonAttrs : List (Attribute msg)
    , filtersDivAttrs : List (Attribute msg)
    , filterDivAttrs : filter -> State -> List (Attribute msg)
    , filterLabelAttrs : filter -> State -> List (Attribute msg)
    , filterNameAttrs : filter -> State -> List (Attribute msg)
    , subFilterDivAttrs : List (Attribute msg)
    , filterImgToggleAttrs : List (Attribute msg)
    }


{-| the `defaultCustomisations` function provide the default attribute values
for elm-criteria. These values can be resetted with the function
`customConfig`
-}
defaultCustomisations : Customisations filter msg
defaultCustomisations =
    { mainDivAttrs = []
    , buttonAttrs = []
    , filtersDivAttrs = []
    , filterDivAttrs = \_ _ -> []
    , filterLabelAttrs = \_ _ -> [ style "cursor" "pointer" ]
    , filterNameAttrs = \_ _ -> []
    , subFilterDivAttrs = [ style "margin-left" "20px" ]
    , filterImgToggleAttrs =
        [ style "cursor" "pointer"
        , style "display" "inline-block"
        , style "vertical-align" "middle"
        ]
    }



-- VIEW


viewToggleSubFilters : Config msg filter -> State -> filter -> Set String -> Html msg
viewToggleSubFilters ((Config { toId, toMsg, getSubFilters, customisations }) as c) state filter openSubFilters =
    case getSubFilters filter of
        [] ->
            text ""

        _ ->
            if isFilterOpen (toId filter) openSubFilters then
                span
                    ([ onClick (hideSubFilters c filter state) toMsg
                     ]
                        ++ customisations.filterImgToggleAttrs
                    )
                    [ arrowUp ]

            else
                span
                    ([ onClick (showSubFilters c filter state) toMsg
                     ]
                        ++ customisations.filterImgToggleAttrs
                    )
                    [ arrowDown ]


viewSubFilters : Config msg filter -> State -> List filter -> Html msg
viewSubFilters ((Config { customisations }) as configView) state subFilters =
    div ([] ++ customisations.subFilterDivAttrs) <|
        List.map (\subFilter -> viewFilter configView state subFilter) subFilters


viewFilter : Config msg filter -> State -> filter -> Html msg
viewFilter ((Config { toMsg, toId, toString, getSubFilters, customisations }) as configView) ((State _ selectedFilters openSubFilters) as state) filter =
    div ([] ++ customisations.filterDivAttrs filter state)
        [ label ([] ++ customisations.filterLabelAttrs filter state)
            [ input
                [ type_ "checkbox"
                , checked <| Set.member (toId filter) selectedFilters
                , onClick (toggleFilter (toId filter) state) toMsg
                ]
                []
            , span ([] ++ customisations.filterNameAttrs filter state) [ text <| toString filter ]
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
view ((Config { title, toMsg, customisations }) as configView) ((State open selectedFilters openSubFilters) as state) filters =
    div ([] ++ customisations.mainDivAttrs)
        [ button
            ([ onClick (State (not open) selectedFilters openSubFilters) toMsg ]
                ++ customisations.buttonAttrs
            )
            [ text title ]
        , div
            ([ displayFilters open ] ++ customisations.filtersDivAttrs)
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
selectedIdFilters : State -> Set FilterId
selectedIdFilters (State _ selectedFilters _) =
    selectedFilters


isFilterOpen : String -> Set FilterId -> Bool
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
