module Main where

import Assignments.Recursion
import BudgetFlow.Core
import BudgetFlow.Types
import BudgetFlow.Config

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
  result <- readConfigFile "config.toml"
  case result of
    Left err     -> putStrLn ("Fout: " ++ err)
    Right config -> runSimulation config

runSimulation :: Config -> IO ()
runSimulation config = do
  let result = simulate config
  putStrLn $ "Simulate " ++ show (monthsToSimulate config) ++ " months starting from €" ++ centsToDisplayString (startBalance config)
  mapM_ printMonth result
  where
    printMonth (MonthState month money) =
      putStrLn $ "Month " ++ show month ++ ": €" ++ centsToDisplayString money