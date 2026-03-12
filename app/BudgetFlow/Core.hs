module BudgetFlow.Core where

import BudgetFlow.Types

-- This function handles applying one event to our balance
applyEvent :: Money -> Event -> Money
applyEvent (Cents balance) (Income (Cents amount)) = 
    -- If it's income, just add the amount
    Cents (balance + amount)
applyEvent (Cents balance) (Expense _ (Cents amount)) = 
    -- If it's expense, subtract the amount, category is not used in this function
    Cents (balance - amount)

-- This function does the budget for multiple months
-- It gives a list with the balance at the end of each month
simulateWith :: Money -> [Event] -> Int -> [MonthState]
simulateWith startBalance events n = 
    -- We make a list of the balance after each month
    -- scanl keeps track of how the balance changes every month
    -- (1, startBalance) means we start with month 1 and our starting money
    -- [1..n] just means we do it for 'n' months
    -- step updates the month number and balance
    -- drop 1 removes the first one (that is just the start), so we get only real months
    -- map snd gets only the money amount out of the pair
    -- zip [1..n] sticksd the month number together with the balance
    map (uncurry MonthState) (zip [1..n] balancesPerMonth)
    where
        step (month, balance) _ = (month + 1, simulateMonth balance events)
        balancesPerMonth = map snd (drop 1 (scanl step (1, startBalance) [1..n]))

-- Run simulation with a config
simulate :: Config -> [MonthState]
simulate config = take (monthsToSimulate config) (timeline (startBalance config) (monthlyEvents config))

-- Oneindige lijst of MonthStates
timeline :: Money -> [Event] -> [MonthState]
timeline start events = map (uncurry MonthState) (zip [1..] balances)
  where
    balances = drop 1 (map snd (iterate step ((1 :: Integer), start)))
    step (month, balance) = (month + 1, simulateMonth balance events)

-- Calculate total income from a list of events
totalIncome :: [Event] -> Int
totalIncome events = sum [amt | Income (Cents amt) <- events]

-- Calculate total expenses from a list of events
totalExpenses :: [Event] -> Int
totalExpenses events = sum [amt | Expense _ (Cents amt) <- events]