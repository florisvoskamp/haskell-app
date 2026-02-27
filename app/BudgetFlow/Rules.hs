module BudgetFlow.Rules where

evalRules :: [Rule] -> MonthState -> [Event] -> [String]
evalRules rules monthState _events = mapMaybe

checkRule :: Rule -> MonthState -> Maybe String
checkRule (MinBalance (Cents minAmt)) (MonthState _ (Cents balance)) =
  if balance < minAmt then Just "Saldo onder minimum" else Nothing 