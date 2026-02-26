module Main where

import Assignments.Recursion
import BudgetFlow.Types
import BudgetFlow.Core

main :: IO ()
main = do
  putStrLn "Hello, Haskell!"
  putStrLn $ "gcd' 48 18 = " ++ show (gcd' 48 18)
  putStrLn $ "isPal lepel = " ++ show (isPal "lepel")
  putStrLn $ "somVanCijfer 1234 = " ++ show (somVanCijfer 1234)
  putStrLn $ "draai [1,2,3,4] = " ++ show (draai [1,2,3,4])
  putStr "printBinair 13 = "
  printBinair 13
  putStrLn ""
  putStrLn "-- Testing BudgetFlow --"
  testBudgetFlow

testBudgetFlow :: IO ()
testBudgetFlow = do
  let start = Cents 100000
      income = Income (Cents 20000)
      expense1 = Expense (Category "Rent") (Cents 40000)
      expense2 = Expense (Category "Groceries") (Cents 10000)
      events = [income, expense1, expense2]
      nMonths = 3
      result = simulate start events nMonths
  putStrLn $ "Simulate " ++ show nMonths ++ " months starting from €" ++ centsToDisplayString start
  mapM_ printMonth result
  where
    printMonth (MonthState month money) =
      putStrLn $ "Month " ++ show month ++ ": €" ++ centsToDisplayString money
