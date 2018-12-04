import Browser
import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (..)
import Criteria


main =
  Browser.sandbox { init = init, update = update, view = view }


-- MODEL

type alias Model = String

init : Model
init = "Hello"


-- UPDATE

type Msg = None

update : Msg -> Model -> Model
update msg model =
  case msg of
    None  -> model

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h1 [] [text model]
    , Criteria.view
    ]
