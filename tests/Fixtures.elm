module Fixtures exposing (config, configWithTitle, filters)

import Criteria exposing (State, config)


type alias Filter =
    ( String, SubFilters )


type SubFilters
    = SubFilters (List Filter)


type Msg
    = UpdateCriteria Criteria.State


filters : List Filter
filters =
    [ ( "filter1", SubFilters [ ( "filter11", SubFilters [] ), ( "filter12", SubFilters [] ), ( "filter13", SubFilters [] ) ] )
    , ( "filter2", SubFilters [ ( "filter21", SubFilters [ ( "filter 211", SubFilters [] ) ] ), ( "filter22", SubFilters [] ) ] )
    ]


config : Criteria.Config Msg Filter
config =
    Criteria.config
        { title = "My filters"
        , toMsg = UpdateCriteria
        , toId = getFilterId
        , toString = getFilterName
        , getSubFilters = getSubFilters
        }


configWithTitle : String -> Criteria.Config Msg Filter
configWithTitle title =
    Criteria.config
        { title = title
        , toMsg = UpdateCriteria
        , toId = getFilterId
        , toString = getFilterName
        , getSubFilters = getSubFilters
        }


getFilterName : Filter -> String
getFilterName ( filter, _ ) =
    filter


getFilterId : Filter -> String
getFilterId ( filter, _ ) =
    "id:" ++ filter


getSubFilters : Filter -> List Filter
getSubFilters ( _, SubFilters subFilters ) =
    subFilters
