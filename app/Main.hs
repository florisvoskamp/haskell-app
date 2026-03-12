module Main where

import Assignments.Recursion
import BudgetFlow.Core
import BudgetFlow.Types
import BudgetFlow.Config
import BudgetFlow.Rules (evalRules)
import BudgetFlow.Scenario (simulateWithScenario)

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
    Right config -> do
      runSimulation config
      runScenario config

-- runs the basic simulation and prints out results per month
runSimulation :: Config -> IO ()
runSimulation config = do
  let months = simulate config
      evts   = monthlyEvents config
  putStrLn $ "\nBaseline simulatie: " ++ show (monthsToSimulate config) ++ " maanden"
  putStrLn $ "Startsaldo: " ++ centsToDisplayString (startBalance config)
  mapM_ (printMonth config evts) months
  let MonthState _ finalBalance = last months
  putStrLn $ "Eindsaldo: " ++ centsToDisplayString finalBalance

-- prints details about a single month, including warnings
printMonth :: Config -> [Event] -> MonthState -> IO ()
printMonth config evts ms@(MonthState month money) = do
  putStrLn $ "Maand " ++ show month ++ ":"
  putStrLn $ "  Inkomsten:  " ++ centsToDisplayString (Cents (totalIncome evts))
  putStrLn $ "  Uitgaven:   " ++ centsToDisplayString (Cents (totalExpenses evts))
  putStrLn $ "  Eindsaldo:  " ++ centsToDisplayString money
  let warnings = evalRules (rules config) ms evts
  mapM_ (\w -> putStrLn ("  LET OP: " ++ w)) warnings

-- simulates a scenario (extra expense from month 2) and compares to baseline
runScenario :: Config -> IO ()
runScenario config = do
  let scenario = Scenario { scenarioFrom = 2, scenarioEvents = [Expense (Category "Extra") (Cents 15000)] }
      baseline = simulate config
      scenarioResult = simulateWithScenario config scenario
  putStrLn $ "\nScenario: extra uitgave van 150 vanaf maand " ++ show (scenarioFrom scenario)
  putStrLn "Maand  | Baseline    | Scenario    | Verschil"
  mapM_ (printComparison) (zip baseline scenarioResult)

-- prints the comparison between baseline and scenario for a month
printComparison :: (MonthState, MonthState) -> IO ()
printComparison (MonthState month (Cents base), MonthState _ (Cents scen)) =
  putStrLn $ "  " ++ show month ++ "    | " ++ pad (centsToDisplayString (Cents base))
          ++ " | " ++ pad (centsToDisplayString (Cents scen))
          ++ " | " ++ centsToDisplayString (Cents (scen - base))
  where
    pad s = s ++ replicate (9 - length s) ' '