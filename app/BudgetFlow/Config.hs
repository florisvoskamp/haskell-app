module BudgetFlow.Config where

import BudgetFlow.Types  
import Text.Read (readMaybe)
import BudgetFlow.TOML

readConfigFile :: FilePath -> IO (Either String Config)
readConfigFile path = do
  content <- readFile path
  return (parseConfig content)

parseConfig :: String -> Either String Config
parseConfig input =
  case parseTOML input of
    Left err  -> Left err
    Right doc -> buildConfig doc

buildConfig :: TOMLDoc -> Either String Config
buildConfig = _

maybeToEither :: String -> Maybe a -> Either String a
maybeToEither msg Nothing  = Left msg
maybeToEither _   (Just x) = Right x