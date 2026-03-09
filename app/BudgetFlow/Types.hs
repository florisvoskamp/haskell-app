module BudgetFlow.Types where

-- Define types for BudgetFlow
data Money = Cents Int deriving (Eq, Show)
data Category = Category String deriving (Eq, Show)
data Event = Income Money | Expense Category Money deriving (Eq, Show)
data MonthState = MonthState Int Money deriving (Eq, Show)
data Rule = MinBalance Money
data Config = Config {
    startBalance        :: Money,
    monthlyEvents       :: [Event],
    monthsToSimulate    :: Int
} deriving (Eq, Show)
-- Een document = lijst van secties. Elke sectie heeft een naam en key-value paren.
-- Sectienaam "" = top-level (geen [sectie] header)
type TOMLDoc = [(String, [(String, String)])]
data LineType
  = Section String
  | KeyValue String String
  | CommentOrEmpty

-- Takes 100.00 euro and turns it into 100000 cents
euroToCents :: Double -> Money
euroToCents euro = Cents (round (euro * 100))

-- Turns cents f.e. 100 into 1.00 euro
centsToDisplayString :: Money -> String
centsToDisplayString (Cents c) = show (fromIntegral c / 100.0)