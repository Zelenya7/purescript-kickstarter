module Foreign.ReactPlayer where

import React.Basic.Hooks (ReactComponent)

foreign import reactPlayer
  :: ReactComponent
    { className :: String
    , controls :: Boolean
    , light :: Boolean
    , url :: String
    }
