module Main exposing (main)

import Browser
import Criteria
import Html exposing (Attribute, Html, button, div, h1, p, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseDown)
import Set exposing (..)


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { criteria : Criteria.State }


init : Model
init =
    { criteria = Criteria.init }


criteriaConfig : Criteria.Config Msg Filter
criteriaConfig =
    let
        defaultCustomisations =
            Criteria.defaultCustomisations
    in
    Criteria.customConfig
        { title = "My Customed filters"
        , toMsg = UpdateCriteria
        , toId = getFilterId
        , toString = getFilterName
        , getSubFilters = getSubFilters
        , customisations =
            { defaultCustomisations
                | buttonAttrs = customButton
                , filterLabelAttrs = customFilter
            }
        }


customButton : List (Html.Attribute Msg)
customButton =
    [ style "color" "red", onMouseDown (Log "hello") ]


customFilter : Filter -> Criteria.State -> List (Html.Attribute Msg)
customFilter filter state =
    if Set.member (getFilterId filter) (Criteria.selectedIdFilters state) then
        [ style "background-color" "red" ]

    else
        []



-- UPDATE


type Msg
    = UpdateCriteria Criteria.State
    | Log String



-- see "recursive types!" section of https://elm-lang.org/0.19.0/recursive-alias


type alias Filter =
    ( String, SubFilters )


type SubFilters
    = SubFilters (List Filter)


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateCriteria state ->
            { model | criteria = state }

        Log text ->
            let
                _ =
                    Debug.log "log from button" text
            in
            model



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Criteria Package" ]
        , Criteria.view criteriaConfig model.criteria filters
        , p [] [ text "this is the rest of the application content" ]
        , p [] [ text "Filter selected:" ]
        , p [] [ text <| showSelectedFilters model.criteria ]
        ]


showSelectedFilters : Criteria.State -> String
showSelectedFilters state =
    let
        f =
            Criteria.selectedIdFilters state
    in
    Set.toList f |> String.join " "


filters : List Filter
filters =
    [ ( "filter1", SubFilters [ ( "filter11", SubFilters [] ), ( "filter12", SubFilters [] ), ( "filter13", SubFilters [] ) ] )
    , ( "filter2", SubFilters [ ( "filter21", SubFilters [ ( "filter 212", SubFilters [] ) ] ), ( "filter22", SubFilters [] ) ] )
    , ( "filter3", SubFilters [] )
    , ( "filter4", SubFilters [ ( "filter41", SubFilters [] ) ] )
    , ( "filter2", SubFilters [] )
    ]


getFilterName : Filter -> String
getFilterName ( filter, _ ) =
    filter


getFilterId : Filter -> String
getFilterId ( filter, _ ) =
    "id:" ++ filter


getSubFilters : Filter -> List Filter
getSubFilters ( _, SubFilters subFilters ) =
    subFilters
