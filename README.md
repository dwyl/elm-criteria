# elm-criteria
[![Build Status](https://travis-ci.org/dwyl/elm-criteria.svg?branch=master)](https://travis-ci.org/dwyl/elm-criteria)
[![HitCount](http://hits.dwyl.io/dwyl/elm-criteria.svg)](http://hits.dwyl.io/dwyl/elm-criteria)

This Elm package lets you create a dropdown/filters UI:

![filters](https://user-images.githubusercontent.com/6057298/49747519-7ce03900-fc9b-11e8-86f2-1c7a95e2602c.png)

## Use elm-criteria

- import `Criteria` and initialise the `Criteria.State` in your model

```elm
import Criteria

type alias Model =
    { criteria : Criteria.State }


init : Model
init =
    { criteria = Criteria.init [] }
```

To initiliase the state with some pre-selected filters, pass an array of the filters' id
as a parameter to `Criteria.init`, for example:

```elm
init : Model
init =
    { criteria = Criteria.init ["filterId1", "filterId2"] }
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

### Customise and set attributes

`elm-criteria` expose a specific config function to define some html attributes
to the main html element of the package.

```
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
```

The `Criteria.defaultCustomisations` function return a `Criteria.Customisations filter msg`
type which is a type alias of a record defined as the following:

```type alias Customisations filter msg =
    { mainDivAttrs : List (Attribute msg)
    , buttonAttrs : List (Attribute msg)
    , filtersDivAttrs : List (Attribute msg)
    , filterDivAttrs : filter -> State -> List (Attribute msg)
    , filterLabelAttrs : filter -> State -> List (Attribute msg)
    , subFilterDivAttrs : List (Attribute msg)
    , filterImgToggleAttrs : List (Attribute msg)
    }
```

This type alias is directly accessible and the default values can be redefined
as shown above, ie:
```
, customisations =
    { defaultCustomisations
        | buttonAttrs = customButton
        , filterLabelAttrs = customFilter
        ,...
    }
```

## Examples

See the default [live example](https://dwyl.github.io/elm-criteria/example.html) and its [code](https://github.com/dwyl/elm-criteria/blob/master/examples/Example.elm)

See the [customised example](https://dwyl.github.io/elm-criteria/customised-example.html) and its
[code](https://github.com/dwyl/elm-criteria/blob/master/examples/CustomExample.elm)

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
|  [**2.2.0**](https://github.com/dwyl/elm-criteria/releases/tag/2.1.0) | Expose `openFilters` `closeFilters` `isOpen` functions
|  [**2.1.0**](https://github.com/dwyl/elm-criteria/releases/tag/2.1.0) | Expose `unselectFilter` function
|  [**2.0.0**](https://github.com/dwyl/elm-criteria/releases/tag/2.0.0) | Update `init`: first parameter is list of selected filters
|  [**1.1.0**](https://github.com/dwyl/elm-criteria/releases/tag/1.1.0) | add API functions to define attributes to the main elements (ie button, label, divs)
|  [**1.0.1**](https://github.com/dwyl/elm-criteria/releases/tag/1.0.1) | add toggle for sub-filters
|  [**1.0.0**](https://github.com/dwyl/elm-criteria/releases/tag/1.0.0) | elm-criteria initial release
