module BudgetFlow.Types where

-- Define types for BudgetFlow
data Money = Cents Int
data Category = Category String
data Events 

-- Takes 100.00 euro and turns it into 100000 cents
euroToCents :: Double -> Int
euroToCents euro = round (euro * 100)

-- Turns cents f.e. 100 into 1.00 euro
centsToDisplayString :: Int -> String
centsToDisplayString cents = show (fromIntegral cents / 100.0)