module BudgetFlow.Rules where

import BudgetFlow.Types
import Data.Maybe (mapMaybe)

evalRules :: [Rule] -> MonthState -> [Event] -> [String]
evalRules rules monthState _events = mapMaybe (\r -> checkRule r monthState) rules

checkRule :: Rule -> MonthState -> Maybe String
checkRule (MinBalance (Cents minAmt)) (MonthState _ (Cents balance)) =
  if balance < minAmt then Just "Saldo onder minimum" else Nothing 