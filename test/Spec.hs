module Main where

import Test.Tasty
import Test.Tasty.HUnit (testCase, assertEqual)
import BudgetFlow.Types
    ( Event(Expense, Income),
      Money(Cents),
      euroToCents,
      centsToDisplayString, Category (..) )
import BudgetFlow.Core ( applyEvent ) 

main :: IO ()
main = defaultMain $ testGroup "BudgetFlow"
  [ testGroup "Types" [
    testCase "euroToCents" $ assertEqual "Test" (Cents 1250) (euroToCents 12.50),
    testCase "centsToDisplayString" $ assertEqual "" "12.5" (centsToDisplayString (Cents 1250))
  ]
  , testGroup "Core" [
    testCase "applyEvent" $ assertEqual "Income adds to balance" (Cents 1200) (applyEvent (Cents 1000) (Income (Cents 200))),
    testCase "applyEvent" $ assertEqual "Expense takes from balance" (Cents 800) (applyEvent (Cents 1000) (Expense (Category "") (Cents 200)))
  ]
  , testGroup "Rules" [

  ]
  ]
