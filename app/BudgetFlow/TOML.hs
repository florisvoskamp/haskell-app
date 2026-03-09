module BudgetFlow.TOML where

import Data.Char (isSpace)
import Data.List (dropWhileEnd)
import BudgetFlow.Types (LineType)

trim :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace

