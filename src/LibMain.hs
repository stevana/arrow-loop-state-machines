module LibMain where

import Deployment
import Example.Counter
import Syntax.Pipeline.Typed
import Syntax.StateMachine.Untyped
import Syntax.Types
import Message
import Codec

------------------------------------------------------------------------

test :: IO ()
test = do
  print xs
  run (FromTCP 3000) readShowCodec (SM "counter" 0 counterV1) ToTCP -- Stdout'
  where
    xs :: [Msg String]
    xs =
      [ Item Nothing (show ReadCountV1)
      , Item Nothing (show IncrCountV1)
      , Item Nothing (show IncrCountV1)
      , Item Nothing (show ReadCountV1)
      -- , Upgrade Nothing "counter" counterV2 (Nothing :: Maybe (Int -> Int))
      , Upgrade_ Nothing "counter" UTInt UTInt UTString UTString counterV2U IdU
      , Item Nothing (show ReadCountV2)
      , Item Nothing (show ResetCountV2)
      , Item Nothing (show ReadCountV2)
      ]
-- >>> test
-- Item "Left 0"
-- Item "Right ()"
-- Item "Right ()"
-- Item "Left 2"
-- UpgradeSucceeded counter
-- Item "Left (Left 2)"
-- Item "Right ()"
-- Item "Left (Left 0)"
