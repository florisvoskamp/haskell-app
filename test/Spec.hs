module Main where

import Test.Tasty
import Test.Tasty.HUnit (testCase, assertEqual, assertFailure)
import BudgetFlow.Types
    ( Event(Expense, Income),
      Money(Cents),
      euroToCents,
      centsToDisplayString, Category (..), MonthState (MonthState), Rule (..), Config (..) )
import BudgetFlow.Core ( applyEvent, simulateMonth, simulate, simulateWith ) 
import BudgetFlow.Rules (checkRule, evalRules)
import BudgetFlow.Config

main :: IO ()
main = defaultMain $ testGroup "BudgetFlow"
  [ testGroup "Types" [
    testCase "euroToCents" $ assertEqual "Test" (Cents 1250) (euroToCents 12.50),
    testCase "centsToDisplayString" $ assertEqual "" "12.5" (centsToDisplayString (Cents 1250))
  ]
  , testGroup "Core" [
    testCase "applyEvent" $ assertEqual "Income adds to balance" (Cents 1200) (applyEvent (Cents 1000) (Income (Cents 200))),
    testCase "applyEvent" $ assertEqual "Expense takes from balance" (Cents 800) (applyEvent (Cents 1000) (Expense (Category "") (Cents 200))),
    testCase "simulateMonth" $ assertEqual "" (Cents 2500) (simulateMonth (Cents 1000) [Income (Cents 2000), Expense (Category "Rent") (Cents 500)]),
    testCase "simulateWith" $ assertEqual "" ([((MonthState 1 (Cents 1500))), ((MonthState 2 (Cents 2000))), ((MonthState 3 (Cents 2500)))]) (simulateWith (Cents 1000) [Expense (Category "Rent") (Cents 500), Income (Cents 1000)] 3),
    testCase "simulate" $ assertEqual "" ([((MonthState 1 (Cents 700))), ((MonthState 2 (Cents 400))), ((MonthState 3 (Cents 100)))]) (simulate (Config (Cents 1000) [Income (Cents 200), Expense (Category "Rent") (Cents 500)] 3 [] [] 1000 1))
  ]
  , testGroup "Rules" [
    testCase "checkRule" $ assertEqual "" (Just "Saldo onder minimum (minimum: €10.0, huidig: €5.0)") (checkRule (MinBalance(Cents 1000)) ((MonthState 1 (Cents 500))) []),
    testCase "evalRules" $ assertEqual "" (["Saldo onder minimum (minimum: €15.0, huidig: €10.0)"]) (evalRules [(MinBalance(Cents 1000)), (MinBalance(Cents 1500))] ((MonthState 1 (Cents 1000))) [Expense (Category "Rent") (Cents 500), Income (Cents 1000)])
  ],
  testGroup "Config" [
  testCase "parseConfig startBalance" $
    assertEqual ""
      (Right (Cents 100000))
      (fmap startBalance (parseConfig "startBalance = 100000\nmonthsToSimulate = 3\n[events]\nIncome = 20000")),
  testCase "readConfigFile" $ do
    result <- readConfigFile "config.toml"
    case result of
      Left err  -> assertFailure ("Parse fout: " ++ err)
      Right cfg -> assertEqual "" (Cents 200000) (startBalance cfg)
  ]
  ]