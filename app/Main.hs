module Main where

import Assignments.Recursion
import BudgetFlow.Core
import BudgetFlow.Types
import BudgetFlow.Config (readConfigFile, readScenarioFile)
import BudgetFlow.Rules (evalRules)
import BudgetFlow.Scenario (simulateWithScenario)
import BudgetFlow.MonteCarlo (runMonteCarlo, overdraftProbability, percentile)
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] ->
      defaultMain
    "run":path:_ ->
      readConfigFile path >>= either putStrLn runSimulation
    "scenario":configPath:scenarioPath:_ -> do
      cfg <- readConfigFile configPath
      case cfg of
        Left err -> putStrLn ("Fout: " ++ err)
        Right config -> do
          scen <- readScenarioFile scenarioPath
          case scen of
            Left err -> putStrLn ("Scenario fout: " ++ err)
            Right scenario -> do
              runSimulation config
              runScenarioWith config scenario
    "stress":path:_ ->
      readConfigFile path >>= either putStrLn runMonteCarloReport
    _ ->
      defaultMain

defaultMain :: IO ()
defaultMain = do
  putStrLn "-- Testing Recursion Class Assignments --"
  putStrLn $ "gcd' 48 18 = " ++ show (gcd' 48 18)
  putStrLn $ "isPal lepel = " ++ show (isPal "lepel")
  putStrLn $ "somVanCijfer 1234 = " ++ show (somVanCijfer 1234)
  putStrLn $ "draai [1,2,3,4] = " ++ show (draai [1,2,3,4])
  putStr "printBinair 13 = "
  printBinair 13
  putStrLn ""
  putStrLn "-- Testing BudgetFlow --"
  result <- readConfigFile "test.toml"
  case result of
    Left err     -> putStrLn ("Fout: " ++ err)
    Right config -> do
      runSimulation config
      runScenario config
      runMonteCarloReport config

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
runScenario config =
  runScenarioWith config (Scenario { scenarioFrom = 2, scenarioEvents = [Expense (Category "Extra") (Cents 15000)] })

runScenarioWith :: Config -> Scenario -> IO ()
runScenarioWith config scenario = do
  let baseline = simulate config
      scenarioResult = simulateWithScenario config scenario
  putStrLn $ "\nScenario: extra events vanaf maand " ++ show (scenarioFrom scenario)
  putStrLn "Maand  | Baseline    | Scenario    | Verschil"
  mapM_ (printComparison) (zip baseline scenarioResult)

-- runs Monte Carlo simulations and reports risk statistics
runMonteCarloReport :: Config -> IO ()
runMonteCarloReport config = do
  let runs        = runMonteCarlo config
      finalSaldi  = [b | run <- runs, MonthState _ (Cents b) <- [last run]]
      overdraft   = overdraftProbability runs * 100
      p10         = percentile 0.10 finalSaldi
      p50         = percentile 0.50 finalSaldi
      p90         = percentile 0.90 finalSaldi
  putStrLn ""
  putStrLn $ "Monte Carlo stress test (" ++ show (monteCarloRuns config) ++ " runs)"
  putStrLn $ "Variabele uitgaven: " ++ show (length (variableExpenses config)) ++ " categorie(en)"
  putStrLn $ "Kans op negatief eindsaldo: " ++ show (round overdraft :: Int) ++ "%"
  putStrLn $ "Eindsaldo p10 (pessimistisch): " ++ centsToDisplayString (Cents p10)
  putStrLn $ "Eindsaldo p50 (mediaan):       " ++ centsToDisplayString (Cents p50)
  putStrLn $ "Eindsaldo p90 (optimistisch):  " ++ centsToDisplayString (Cents p90)

-- prints the comparison between baseline and scenario for a month
printComparison :: (MonthState, MonthState) -> IO ()
printComparison (MonthState month (Cents base), MonthState _ (Cents scen)) =
  putStrLn $ "  " ++ show month ++ "    | " ++ pad (centsToDisplayString (Cents base))
          ++ " | " ++ pad (centsToDisplayString (Cents scen))
          ++ " | " ++ centsToDisplayString (Cents (scen - base))
  where
    pad s = s ++ replicate (9 - length s) ' '