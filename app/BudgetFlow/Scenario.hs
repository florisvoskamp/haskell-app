module BudgetFlow.Scenario where

import BudgetFlow.Types

-- Geeft de events voor een bepaalde maand (basis + scenario delta)
eventsForMonth :: Int -> [Event] -> Scenario -> [Event]
eventsForMonth month baseEvents scenario
  | month >= scenarioFrom scenario = baseEvents ++ scenarioEvents scenario
  | otherwise                      = baseEvents