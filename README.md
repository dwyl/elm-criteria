# elm-criteria
[![Build Status](https://travis-ci.org/dwyl/elm-criteria.svg?branch=master)](https://travis-ci.org/dwyl/elm-criteria)
[![HitCount](http://hits.dwyl.io/dwyl/elm-criteria.svg)](http://hits.dwyl.io/dwyl/elm-criteria)

This Elm package lets you create a dropdown/filters UI:

![filters](https://user-images.githubusercontent.com/6057298/49626564-5d62bb00-f9d2-11e8-8cc6-0238b85215f0.png)

## Use elm-criteria

- import `Criteria` and initialise the `Criteria.State` in your model

```elm
import Criteria

type alias Model =
    { criteria : Criteria.State }


init : Model
init =
    { criteria = Criteria.init }
```

- Define the configuration that will be passed to the view

```elm
criteriaConfig : Criteria.Config Msg Filter
criteriaConfig =
    Criteria.config
        { title = "My filters"
        , toMsg = UpdateCriteria
        , toId = getFilterId
        , toString = getFilterName
        , getSubFilters = getSubFilters
        }
```

`title`: The text displayed in the open/close button
`toMsg`: The message in your application responsible for updating the new `Criteria.State` in your `Model`
`toId`: A function which create a unique `String` representing a filter
`toString`: A function which create the text displayed for a filter
`getSubFilters`: A function which returns the list of sub filters for a specific filter

- Define the `Msg` which will update the state

```elm
type Msg = UpdateCriteria Criteria.State

update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateCriteria state ->
            { model | criteria = state }
```

- Finally display the `Criteria.view` in your view

```elm
view : Model -> Html Msg
view model =
    div []
        [
          Criteria.view criteriaConfig model.criteria filters
        ]
```
## Examples

See a [live example](https://dwyl.github.io/elm-criteria/example.html) and its [code]()

To run the exmple on your machine:
- clone this repository `git clone git@github.com:dwyl/elm-criteria.git && cd elm-criteria`
- move to the `examples` directory: `cd examples`
- run `elm reactor`
- visit `localhost:8000` and select the example Elm file you want to run

## Tests

To run the tests make sure to have installed the dependencies of the package with `elm install` then run `elm-test --verbose`:

![tests](https://user-images.githubusercontent.com/6057298/49627193-70c35580-f9d5-11e8-95d3-8313258ad58c.png)

## Releases
| Version | Notes |
| ------- | ----- |
|  [**1.0.0**](https://github.com/dwyl/elm-criteria/releases/tag/1.0.0) | elm-criteria initial release
