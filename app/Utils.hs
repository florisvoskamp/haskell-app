module Utils where

gcd' :: Integer -> Integer -> Integer 
-- type signature: gcd' takes two Integers and returns an Integer
gcd' a 0 = a 
-- base case: if the second argument is 0, return the first argument
gcd' a b = gcd' b (a `mod` b) 
-- recursive case: call gcd' with b and the remainder of a divided by b

isPal :: String -> Bool
-- type signature
isPal "" = True
-- if empty then true
isPal [_] = True
-- if 1 char then true
isPal s = (head s == last s) && isPal(init (tail s))
-- check if first letter matches last letter, and check recursively if middle is also a palindrome

somVanCijfer :: Integer -> Integer
-- type signature
somVanCijfer n
    | n < 10 = n
    -- if n smaller than 10 then stop and return
    | otherwise = (n `mod` 10) + somVanCijfer(n `div` 10)
    -- 

draai :: [Int] -> [Int]
-- type signature
draai [] = []
-- 
draai (x:xs) = draai(xs) ++ [x]
-- 

printBinair :: Int -> IO ()
printBinair n
    | n < 2 = 
    | otherwise = 
