import Browser
import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (..)
import Criteria


main =
  Browser.sandbox { init = init, update = update, view = view }


-- MODEL

type alias Model = {criteria : Criteria.State}

init : Model
init = {criteria = Criteria.init}

criteriaConfig : Criteria.Config Msg
criteriaConfig =
    Criteria.config { toMsg = UpdateCriteria }
-- UPDATE

type Msg = UpdateCriteria Criteria.State

update : Msg -> Model -> Model
update msg model =
  case msg of
    UpdateCriteria state  -> {model | criteria = state}

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h1 [] [text "Criteria Package"]
    , Criteria.view criteriaConfig model.criteria
    ]
