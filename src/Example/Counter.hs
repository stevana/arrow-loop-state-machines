{-# LANGUAGE PatternSynonyms #-}

module Example.Counter where

import Syntax.StateMachine.Typed
import Syntax.StateMachine.Untyped

------------------------------------------------------------------------

type InputV1  = Either () ()
type OutputV1 = Either Int ()

pattern ReadCountV1 :: InputV1
pattern ReadCountV1 = Left ()

pattern IncrCountV1 :: InputV1
pattern IncrCountV1 = Right ()

------------------------------------------------------------------------

counterV1 :: T Int String String
counterV1 = -- Loop (Second (Delay 0) >>>
  -- Distr >>> ((Snd >>> Copy) :+++ (Snd >>> (Consume :&&& Incr))) >>> Distr'
  Read >>> (Get :+++ (Get >>> Incr >>> Put)) >>> Show

counterV1U :: U
counterV1U = -- LoopU UTInt $ SecondU (DelayU UTInt (Opaque (unsafeCoerce 0))) .>>
  -- DistrU .>>
  -- ((SndU .>> CopyU) :.++ (SndU .>> (ConsumeU :.&& IncrU)))
  -- .>> DistrU'
  GetU :.++ (GetU .>> IncrU .>> PutU)

------------------------------------------------------------------------

type InputV2  = Either InputV1 ()
type OutputV2 = Either OutputV1 ()

counterV2 :: T Int String String
counterV2 = -- Loop $ Second (Delay 0) >>>
  -- distr2 >>>
  -- ((Snd >>> Copy) :+++ (Snd >>> (Consume :&&& (Incr >>> Incr)))) :+++ (Consume :&&& (Int 0))
  -- >>> distr2'
  (Read :: T Int String InputV2) >>> (Get :+++ (Get >>> Incr >>> Put) :+++ (Int 0 >>> Put)) >>> Show

pattern ReadCountV2 :: InputV2
pattern ReadCountV2  = Left (Left ())

pattern IncrCountV2 :: InputV2
pattern IncrCountV2  = Left (Right ())

pattern ResetCountV2 :: InputV2
pattern ResetCountV2 = Right ()

counterV2U :: U
counterV2U =
  GetU :.++ (GetU .>> IncrU .>> PutU) :.++ (IntU 0 .>> PutU)

  {-
distr2 :: T (Either (Either a b) c, d) (Either (Either (a, d) (b, d)) (c, d))
distr2 = Distr >>> (Distr :+++ Id)

distr2' :: T (Either (Either (a, d) (b, d)) (c, d)) (Either (Either a b) c, d)
distr2' = (Distr' :+++ Id) >>> Distr'
-}


  {-
data Input = ReadCount | IncrCount
  deriving Read
data Output = Count Int | Ok
  deriving Show

counter :: Input  -> Int -> (Int, Output)
counter ReadCount n = (n, Count n)
counter IncrCount n = (n + 1, Ok)

counter2 :: Input  -> (Int, Int) -> ((Int, Int), Output)
counter2 ReadCount (old, new) = ((old, new), Count new)
counter2 IncrCount (old, new) = ((old, new + 2), Ok)

-}

------------------------------------------------------------------------

-- XXX: V3 add bool to state, if bool is true then incr decrements, also add
-- command that allows for bool to be flipped.
