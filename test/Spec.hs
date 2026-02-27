module Main where

import Test.Tasty
import Test.Tasty.HUnit (testCase, assertEqual)
import BudgetFlow.Types 

main :: IO ()
main = defaultMain $ testGroup "BudgetFlow"
  [ testGroup "Types" [
    testCase "euroToCents" $ assertEqual "" (Cents 1250) (euroToCents 12.50)
  ]
  , testGroup "Core" [

  ]
  , testGroup "Rules" [

  ]
  ]
