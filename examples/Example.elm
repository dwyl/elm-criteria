import Browser
import Html exposing (Html, button, div, h1, text, p)
import Html.Attributes exposing (..)
import Criteria


main =
  Browser.sandbox { init = init, update = update, view = view }


-- MODEL

type alias Model = {criteria : Criteria.State}

init : Model
init = {criteria = Criteria.init}

criteriaConfig : Criteria.Config Msg Filter
criteriaConfig =
    Criteria.config { toMsg = UpdateCriteria, getFilterName = getFilterName, getSubFilters = getSubFilters }
-- UPDATE

type Msg = UpdateCriteria Criteria.State

type alias Filter = (String, List String)

update : Msg -> Model -> Model
update msg model =
  case msg of
    UpdateCriteria state  -> {model | criteria = state}

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h1 [] [text "Criteria Package"]
    , Criteria.view criteriaConfig model.criteria filters
    , p [] [text "this is the rest of the application content"]
    ]


filters : List Filter
filters = [("filter1", ["filter11", "filter12", "filter13"]), ("filter2", ["filter21", "filter22"]), ("filter3", []), ("filter4", ["filter41"])]

getFilterName : (String, List String) -> String
getFilterName (filter, _) =
    filter

getSubFilters : Filter -> List String
getSubFilters (_, subFilters) = subFilters
