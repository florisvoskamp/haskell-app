module BudgetFlow.Rules where

evalRules :: [Rule] -> MonthState -> [Event] -> [String]
evalRules 

checkRule :: Rule -> MonthState -> Maybe String
checkRule MonthState month (Cents balance) MinBalance (Cents minimum) = balance < minimum