module CriteriaTest exposing (suite)

import Criteria exposing (..)
import Expect exposing (Expectation)
import Fixtures exposing (config, filters)
import Fuzz exposing (Fuzzer, int, list, string)
import Set
import Test exposing (..)
import Test.Html.Event as Event exposing (..)
import Test.Html.Query as Query exposing (..)
import Test.Html.Selector as Selector exposing (..)


suite : Test
suite =
    describe "Criteria module"
        [ test "Set of filters is empty on init" <|
            \_ ->
                let
                    state =
                        Criteria.init []
                in
                Expect.equal (Criteria.selectedIdFilters state) Set.empty
        , test "The open/close button display the title passed in the config" <|
            \_ ->
                let
                    state =
                        Criteria.init []

                    view =
                        Criteria.view Fixtures.config state Fixtures.filters
                in
                view
                    |> Query.fromHtml
                    |> Query.find [ tag "button" ]
                    |> Query.has [ text "My filters" ]
        , test "All the first level filters are displayed as checkboxes" <|
            \_ ->
                let
                    state =
                        Criteria.init []

                    view =
                        Criteria.view Fixtures.config state Fixtures.filters
                in
                view
                    |> Query.fromHtml
                    |> Query.findAll [ tag "input" ]
                    |> Query.count (Expect.equal 2)
        , fuzz string "fuzz test the title of the filters" <|
            \randomlyGeneratedString ->
                let
                    state =
                        Criteria.init []

                    config =
                        Fixtures.configWithTitle randomlyGeneratedString

                    view =
                        Criteria.view config state Fixtures.filters
                in
                view
                    |> Query.fromHtml
                    |> Query.find [ tag "button" ]
                    |> Query.has [ text randomlyGeneratedString ]
        , test "button display attributes passed via the customised config" <|
            \_ ->
                let
                    state =
                        Criteria.init []

                    view =
                        Criteria.view Fixtures.customConfig state Fixtures.filters
                in
                view
                    |> Query.fromHtml
                    |> Query.find [ tag "button" ]
                    |> Query.has [ style "color" "red", class "elm-criteria-button" ]
        , test "initialise with pre-selectd filters" <|
            \_ ->
                let
                    state =
                        Criteria.init [ "id:filter1", "id:filter2" ]
                in
                Expect.equal (Criteria.selectedIdFilters state) (Set.fromList [ "id:filter1", "id:filter2" ])
        ]
