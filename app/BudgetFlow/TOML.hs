module BudgetFlow.TOML where

import Data.Char (isSpace)
import Data.List (dropWhileEnd)
import BudgetFlow.Types 

trim :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace

parseLine :: String -> LineType
parseLine s =
  let t = trim s
  in case () of
       _ | null t                    -> CommentOrEmpty
       _ | head t == '#'              -> CommentOrEmpty
       _ | head t == '[' && last t == ']' -> Section (init (drop 1 t))
       _ | elem '=' t                 -> KeyValue (trim (takeWhile (/= '=') t)) (trim (drop 1 (dropWhile (/= '=') t)))
       _                              -> CommentOrEmpty

processLines :: [String] -> String -> [(String, [(String, String)])] -> [(String, [(String, String)])]
processLines [] _ acc = acc
processLines (r:rs) section acc =
  case parseLine r of
    Section name -> processLines rs name acc
    KeyValue k v -> processLines rs section (addToSection acc section k v)
    CommentOrEmpty -> processLines rs section acc

addToSection :: [(String, [(String, String)])] -> String -> String -> String -> [(String, [(String, String)])]
addToSection [] section k v = [(section, [(k, v)])]
addToSection ((name, pairs):rest) section k v
-- fix O(n^2) complexity by avoiding copying the list
  | name == section = (name, (k, v) : pairs) : rest
  | otherwise       = (name, pairs) : addToSection rest section k v

parseTOML :: String -> Either String TOMLDoc
parseTOML input = Right (processLines (lines input) "" [])

lookupSection :: TOMLDoc -> String -> Maybe [(String, String)]
lookupSection doc name = lookup name doc

lookupInDoc :: TOMLDoc -> String -> String -> Maybe String
lookupInDoc doc section key =
  case lookupSection doc section of
    Nothing    -> Nothing
    Just pairs -> lookup key pairs