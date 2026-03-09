module BudgetFlow.Config where

import BudgetFlow.Types  

readConfigFile :: FilePath -> IO (Either String Config)
readConfigFile path = do
  content <- readFile path
  return (parseConfig content)

