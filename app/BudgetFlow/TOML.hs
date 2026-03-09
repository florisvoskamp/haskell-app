module BudgetFlow.TOML where

import Data.Char (isSpace)
import Data.List (dropWhileEnd)

parseTOML :: String -> Either String TOMLDoc

trim :: String -> String
trim string = 