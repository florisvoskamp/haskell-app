module BudgetFlow.Types where

data Money = Cents Int
data Category = Category String

euroToCents :: Double -> Int
euroToCents euro = round (euros * 100)

centsToDisplayString :: Int -> String
centsToDisplayString cents = show (fromIntegral cents / 100.0)