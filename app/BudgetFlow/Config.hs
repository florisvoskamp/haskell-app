module BudgetFlow.Config where

import BudgetFlow.Types
import BudgetFlow.TOML
import Control.Exception (catch, fromException, throwIO)
import System.IO.Error (isDoesNotExistError, ioeGetErrorString)
import Text.Read (readMaybe)

readConfigFile :: FilePath -> IO (Either String Config)
readConfigFile path =
  (readFile path >>= return . parseConfig)
    `catch` \e ->
      case fromException e of
        Just ioe
          | isDoesNotExistError ioe -> return (Left ("Bestand niet gevonden: " ++ path))
          | otherwise -> return (Left ("Fout bij lezen van " ++ path ++ ": " ++ ioeGetErrorString ioe))
        Nothing -> throwIO e

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
  rulesList  <- parseRules (maybe [] id (lookupSection doc "rules"))
  varExps    <- parseVariableExpenses (maybe [] id (lookupSection doc "variable_expenses"))
  let (runs, seed) = parseMonteCarlo (maybe [] id (lookupSection doc "monte_carlo"))
  return (Config (Cents startInt) events monthsInt rulesList varExps runs seed)

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
parseRules ((_, _):rest) = parseRules rest  -- onbekende regels negeren

parseMonteCarlo :: [(String, String)] -> (Int, Int)
parseMonteCarlo pairs =
  let runs = maybe 1000 id (lookup "runs" pairs >>= readMaybe)
      seed = maybe 1 id (lookup "seed" pairs >>= readMaybe)
  in (runs, seed)

-- Parse [variable_expenses] section: "Category = lo hi" e.g. "Food = 3000 8000"
parseVariableExpenses :: [(String, String)] -> Either String [VariableExpense]
parseVariableExpenses [] = Right []
parseVariableExpenses ((key, val):rest) =
  case words val of
    [loStr, hiStr] ->
      case (readMaybe loStr, readMaybe hiStr) of
        (Just lo, Just hi) ->
          fmap (VariableExpense (Category key) (Uniform lo hi) :) (parseVariableExpenses rest)
        _ -> Left ("Ongeldige distributie voor: " ++ key)
    _ -> Left ("Verwacht 'lo hi' voor variabele uitgave: " ++ key)

buildScenario :: TOMLDoc -> Either String Scenario
buildScenario doc = do
  fromStr <- maybeToEither "scenarioFrom ontbreekt" (lookupInDoc doc "" "scenarioFrom")
  fromInt <- maybeToEither "scenarioFrom is geen getal" (readMaybe fromStr)
  eventPairs <- maybeToEither "[events] ontbreekt" (lookupSection doc "events")
  events <- parseEvents eventPairs
  return (Scenario fromInt events)

parseScenario :: String -> Either String Scenario
parseScenario content =
  case parseTOML content of
    Left err -> Left err
    Right doc -> buildScenario doc

readScenarioFile :: FilePath -> IO (Either String Scenario)
readScenarioFile path =
  (readFile path >>= return . parseScenario)
    `catch` \e ->
      case fromException e of
        Just ioe
          | isDoesNotExistError ioe -> return (Left ("Bestand niet gevonden: " ++ path))
          | otherwise -> return (Left ("Fout bij lezen van " ++ path ++ ": " ++ ioeGetErrorString ioe))
        Nothing -> throwIO e