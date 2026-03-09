module BudgetFlow.Config where

import BudgetFlow.Types  
import Text.Read (readMaybe)

readConfigFile :: FilePath -> IO (Either String Config)
readConfigFile path = do
  content <- readFile path
  return (parseConfig content)

parseConfig :: String -> Either String Config
parseConfig = _

maybeToEither :: String -> Maybe a -> Either String a
maybeToEither msg Nothing  = Left msg
maybeToEither _   (Just x) = Right x