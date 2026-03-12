module BudgetFlow.MonteCarlo where

import BudgetFlow.Types
import BudgetFlow.Core (timeline)
import System.Random (mkStdGen, randomR)
import Data.List (sort)

sampleAmount :: Int -> Distribution -> Int
-- using an explicit seed lets sampling stay reproducible,
-- which is useful for comparisons
sampleAmount seed (Uniform lo hi) = fst (randomR (lo, hi) (mkStdGen seed))

sampleEvents :: Int -> [VariableExpense] -> [Event]
-- `zipWith` assigns each variable expense its own different seed, so one sampled
-- value doesn’t accidently get reused for all categories in the same simulation
sampleEvents seed varExpenses = zipWith sampleOne [seed..] varExpenses
  where
    sampleOne s (VariableExpense cat dist) = Expense cat (Cents (sampleAmount s dist))

oneRun :: Config -> Int -> [MonthState]
oneRun config seed =
  let varEvents = sampleEvents seed (variableExpenses config)
      allEvents = monthlyEvents config ++ varEvents
  in take (monthsToSimulate config) (timeline (startBalance config) allEvents)

runMonteCarlo :: Config -> Int -> [[MonthState]]
runMonteCarlo config n = map (oneRun config) [1..n]

overdraftProbability :: [[MonthState]] -> Double
-- only the final month’s result from every run is needed
-- Take the ending balance from each run, count how many are negative
overdraftProbability runs =
  let lastBalances = [b | run <- runs, MonthState _ (Cents b) <- [last run]]
      negatives = length (filter (< 0) lastBalances)
  in fromIntegral negatives / fromIntegral (length runs)

percentile :: Double -> [Int] -> Int
-- after sorting, getting a percentile is just indexing into the list
percentile p xs =
  let sorted = sort xs
      idx = round (p * fromIntegral (length sorted - 1))
  in sorted !! idx