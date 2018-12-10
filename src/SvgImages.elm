module SvgImages exposing (arrowDown, arrowUp)

import Svg exposing (..)
import Svg.Attributes exposing (..)


arrowUp =
    svg
        [ version "1.1"
        , width "24"
        , height "24"
        , viewBox "0 0 24 24"
        ]
        [ Svg.path [ d "M7.406 15.422l-1.406-1.406 6-6 6 6-1.406 1.406-4.594-4.594z" ] [] ]


arrowDown =
    svg
        [ version "1.1"
        , width "24"
        , height "24"
        , viewBox "0 0 24 24"
        ]
        [ Svg.path [ d "M7.406 7.828l4.594 4.594 4.594-4.594 1.406 1.406-6 6-6-6z" ] [] ]
