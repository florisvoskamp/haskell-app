module BudgetFlow.Scenario where

import BudgetFlow.Types
import BudgetFlow.Core (applyEvent)

-- Geeft de events voor een bepaalde maand (basis + scenario delta)
eventsForMonth :: Int -> [Event] -> Scenario -> [Event]
eventsForMonth month baseEvents scenario
  | month >= scenarioFrom scenario = baseEvents ++ scenarioEvents scenario
  | otherwise                      = baseEvents

-- This function goes through all the events for one month and updates the money
-- adding/subtracting all incomes and expenses for a month
simulateMonth :: Money -> [Event] -> Money
simulateMonth start events = foldl applyEvent start events

-- Simulates N months where scenario events are added from scenarioFrom onwards
simulateWithScenario :: Config -> Scenario -> [MonthState]
simulateWithScenario config scenario =
  let n           = monthsToSimulate config
      base        = monthlyEvents config
      -- For each month, set the events for that month
      eventsPerMonth = map (\m -> eventsForMonth m base scenario) [1..n]
      -- scanl applies simulateMonth for each month, adding the balance continuously :)
      -- this could be done recursively, but scanl is more efficient, fold left is not enough because we need to keep track of individual months
      saldi       = scanl simulateMonth (startBalance config) eventsPerMonth
  in zipWith MonthState [1..n] (drop 1 saldi)