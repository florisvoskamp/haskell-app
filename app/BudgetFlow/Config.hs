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
buildConfig doc = do
  startStr   <- maybeToEither "startBalance ontbreekt" (lookupInDoc doc "" "startBalance")
  monthsStr  <- maybeToEither "monthsToSimulate ontbreekt" (lookupInDoc doc "" "monthsToSimulate")
  startInt   <- maybeToEither "startBalance is geen geldig getal" (readMaybe startStr)
  monthsInt  <- maybeToEither "monthsToSimulate is geen geldig getal" (readMaybe monthsStr)
  eventPairs <- maybeToEither "[events] sectie ontbreekt" (lookupSection doc "events")
  events     <- parseEvents eventPairs
  rulePairs  <- maybeToEither "[rules] sectie ontbreekt" (lookupSection doc "rules")
  rules      <- parseRules rulePairs
  return (Config (Cents startInt) events monthsInt rules)

maybeToEither :: String -> Maybe a -> Either String a
maybeToEither msg Nothing  = Left msg
maybeToEither _   (Just x) = Right x

parseEvents :: [(String, String)] -> Either String [Event]
parseEvents [] = Right []
parseEvents ((key, val):rest) =
  case readMaybe val of
    Nothing     -> Left ("Ongeldig bedrag voor: " ++ key)
    Just amount ->
      let event = if key == "Income"
                  then Income (Cents amount)
                  else Expense (Category key) (Cents amount)
      in case parseEvents rest of
           Left err     -> Left err
           Right events -> Right (event : events)

parseRules :: [(String, String)] -> Either String [Rule]
parseRules [] = Right []
parseRules (("MinBalance", val):rest) =
  case readMaybe val of
    Nothing -> Left "MinBalance is geen geldig getal"
    Just amount -> fmap (MinBalance (Cents amount) :) (parseRules rest)
parseRules ((key, _):rest) = parseRules rest  -- onbekende regels negeren