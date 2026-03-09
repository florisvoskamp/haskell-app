module BudgetFlow.TOML where

import Data.Char (isSpace)
import Data.List (dropWhileEnd)
import BudgetFlow.Types 
import Data.List (find)

trim :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace

parseLine :: String -> Maybe LineType
parseLine s =
  let t = trim s
  in case () of
       _ | null t                    -> Just CommentOrEmpty
       _ | head t == '#'              -> Just CommentOrEmpty
       _ | head t == '[' && last t == ']' -> Just (Section (init (drop 1 t)))
       _ | elem '=' t                 -> Just (KeyValue (trim (takeWhile (/= '=') t)) (trim (drop 1 (dropWhile (/= '=') t))))
       _                              -> Just CommentOrEmpty

processLines :: [String] -> String -> [(String, [(String, String)])] -> [(String, [(String, String)])]
processLines [] _ acc = acc
processLines (r:rs) section acc =
  case parseLine r of
    Just (Section name) -> processLines rs name acc
    Just (KeyValue k v) -> processLines rs section (addToSection acc section k v)
    _                   -> processLines rs section acc

addToSection :: [(String, [(String, String)])] -> String -> String -> String -> [(String, [(String, String)])]
addToSection [] section k v = [(section, [(k, v)])]
addToSection ((name, pairs):rest) section k v
  | name == section = (name, pairs ++ [(k, v)]) : rest
  | otherwise       = (name, pairs) : addToSection rest section k v

parseTOML :: String -> Either String TOMLDoc
parseTOML input = Right (processLines (lines input) "" [])