module BudgetFlow.Rules where

import BudgetFlow.Types
import Data.Maybe (mapMaybe)

evalRules :: [Rule] -> MonthState -> [Event] -> [String]
evalRules rules monthState events = mapMaybe (\r -> checkRule r monthState events) rules

checkRule :: Rule -> MonthState -> [Event] -> Maybe String
checkRule (MinBalance (Cents minAmt)) (MonthState _ (Cents balance)) _ =
  if balance < minAmt then Just ("Saldo onder minimum (minimum: €" ++ centsToDisplayString (Cents minAmt) ++ ", huidig: €" ++ centsToDisplayString (Cents balance) ++ ")") else Nothing
checkRule (CategoryLimit cat (Cents limit)) _ events =
  let total = sum [amt | Expense c (Cents amt) <- events, c == cat]
  in if total > limit then Just ("Categorielimiet overschreden voor: " ++ show cat) else Nothing