module BudgetFlow.Core where

import BudgetFlow.Types

-- This function handles applying one event to our balance
applyEvent :: Money -> Event -> Money
applyEvent (Cents balance) (Income (Cents amount)) = 
    -- If it's income, just add the amount
    Cents (balance + amount)
applyEvent (Cents balance) (Expense cat (Cents amount)) = 
    -- If it's expense, subtract the amount, category is not used in this function
    Cents (balance - amount)

-- This function goes through all the events for one month and updates the money
-- adding/subtracting all incomes and expenses for a month
simulateMonth :: Money -> [Event] -> Money
simulateMonth start events = foldl applyEvent start events

-- This function does the budget for multiple months
-- It gives a list with the balance at the end of each month
simulate :: Money -> [Event] -> Int -> [MonthState]
simulate startBalance events n = 
    -- We make a list of the balance after each month
    -- scanl keeps track of how the balance changes every month
    -- (1, startBalance) means we start with month 1 and our starting money
    -- [1..n] just means we do it for 'n' months
    -- step updates the month number and balance
    -- tail removes the first one (that is just the start), so we get only real months
    -- map snd gets only the money amount out of the pair
    -- zip [1..n] sticks the month number together with the balance
    map (uncurry MonthState) (zip [1..n] balancesPerMonth)
    where
        step (month, balance) _ = (month + 1, simulateMonth balance events)
        balancesPerMonth = map snd (tail (scanl step (1, startBalance) [1..n]))