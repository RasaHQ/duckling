-- Copyright (c) 2016-present, Facebook, Inc.
-- All rights reserved.
--
-- This source code is licensed under the BSD-style license found in the
-- LICENSE file in the root directory of this source tree.


{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS -fno-full-laziness #-}

module DucklingRequestSample (main) where

import Control.Monad
import Data.Text (Text)
import System.Environment
import qualified Data.Text.IO as Text

import Duckling.Debug
import Duckling.Dimensions.Types
import Duckling.Locale
import Duckling.Types (Entity)

prun :: Locale -> Text -> [Seal Dimension] -> IO [Entity]
prun locale text dims = do
  Text.putStrLn text
  entities <- debug locale text dims
  Text.putStrLn ""
  return entities

main :: IO ()
main = do
  (repeatCount :: Int) <- read . head <$> getArgs
  replicateM_ repeatCount $ do
    _ <- prun en "My number is 123" [Seal PhoneNumber,Seal Distance,Seal Numeral,Seal Email]
    _ <- prun en "Wednesday 5:00PM 3/29/2017" [Seal Numeral,Seal Time]
    _ <- prun zh "12:30pm" [Seal Time]
    _ <- prun en "tomorrow at 4pm" [Seal Time]
    _ <- prun en "Tomorrow at 12.30?" [Seal Time]
    _ <- prun en "Wednesday 9am" [Seal Time]
    _ <- prun en "Sure do! Will 11:30 work?" [Seal Time,Seal AmountOfMoney]
    prun en "8:00am" [Seal Time]
    where
      en = makeLocale EN Nothing
      zh = makeLocale ZH Nothing
