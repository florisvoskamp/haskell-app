module BudgetFlow.Types where

-- Define types for BudgetFlow
data Money = Cents Int deriving (Eq, Show)
data Category = Category String
data Event = Income Money | Expense Category Money
data MonthState = MonthState Int Money
data Rule = MinBalance Money

-- Takes 100.00 euro and turns it into 100000 cents
euroToCents :: Double -> Money
euroToCents euro = Cents (round (euro * 100))

-- Turns cents f.e. 100 into 1.00 euro
centsToDisplayString :: Money -> String
centsToDisplayString (Cents c) = show (fromIntegral c / 100.0)