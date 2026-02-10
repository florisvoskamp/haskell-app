module BudgetFlow.Core where

import BudgetFlow.Types

applyEvent :: Money -> Event -> Money
applyEvent (Cents balance) (Income (Cents amount)) = Cents (balance + amount)
applyEvent (Cents balance) (Expense cat (Cents amount)) = Cents (balance - amount)

simulateMonth :: Money -> [Event] -> Money
simulateMonth start events = foldl applyEvent start events

simulate :: Money -> [Event] -> Int -> [MonthState]
simulate startBalance events n = 