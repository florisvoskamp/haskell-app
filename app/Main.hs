module Main where

import Utils

main :: IO ()
main = do
  putStrLn "Hello, Haskell!"
  putStrLn $ "gcd' 48 18 = " ++ show (gcd' 48 18)
  putStrLn $ "isPal lepel = " ++ show (isPal "lepel")
  putStrLn $ "somVanCijfer 1234 = " ++ show (somVanCijfer 1234)
  putStrLn $ "draai [1,2,3,4] = " ++ show (draai [1,2,3,4])
  putStr "printBinair 13 = "
  printBinair 13
  putStrLn ""