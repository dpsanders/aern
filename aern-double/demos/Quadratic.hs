
module Main where

import Numeric.AERN.DoubleBasis.RealApprox
import Numeric.AERN.DoubleBasis.MRealApprox

import Control.Monad.ST (runST)

type R = RealApprox

main = do
  putStrLn $ "quadratic 1 1 1 = " ++ show (quadratic 1 1 1)
  putStrLn $ "quadratic 1 2 1 = " ++ show (quadratic 1 2 1)
  putStrLn $ "quadratic 1 5 6 = " ++ show (quadratic 1 5 6)
  putStrLn $ "quadraticInPlace 1 1 1 = " ++ show (quadraticInPlace 1 1 1)
  putStrLn $ "quadraticInPlace 1 2 1 = " ++ show (quadraticInPlace 1 2 1)
  putStrLn $ "quadraticInPlace 1 5 6 = " ++ show (quadraticInPlace 1 5 6)

-- | 
-- Returns list such that the union of its members contains all
-- real roots of each real polynomial u*x^2+v*x+w obtained by
-- choosing coefficients u in a, v in b and w in c. 
quadratic :: R -> R -> R -> [R]
quadratic a b c 
  | certainlyZero discriminant =
    [doubleRoot]
  | certainlyNonnegative discriminant =
    [leftRoot,rightRoot]
  | certainlyNegative discriminant =
    []
  | otherwise =
    [bottom]
  where
  discriminant = b^2-4*a*c
  doubleRoot = -b/(2*a)
  leftRoot = doubleRoot-sqrtDiscriminant/(2*a)  -- (-b-sqrt(b^2-4*a*c))/(2*a)
  rightRoot = doubleRoot+sqrtDiscriminant/(2*a) -- (-b+sqrt(b^2-4*a*c))/(2*a)
  sqrtDiscriminant = sqrt discriminant

-- |
-- In-place quadratic. 
quadraticInPlace :: R -> R -> R -> [R]
quadraticInPlace a b c
  | certainlyZero discriminant =
    [doubleRoot]
  | certainlyNonnegative discriminant =
    [leftRoot,rightRoot]
  | certainlyNegative discriminant =
    []
  | otherwise =
    [bottom]
  where
  discriminant = 
    runST $
      do
      [aM,bM,cM] <- mapM makeMutable [a,b,c]
      bM <^>= 2              -- b^2
      aM <*>|= (4 :: Double) -- 4*a
      aM <*>= cM             -- 4*a*c
      bM <->= aM             -- b^2-4*a*c
      result <- unsafeReadMutable bM
        -- using unsafeReadMutable is safe becasue bM is no longer reachable 
      return result
  doubleRoot =
    runST $
      do
      [aM,bM] <- mapM makeMutable [a,b] 
      bM </>|= (-2 :: Double) -- -b/2 
      bM </>= aM              -- -b/(2*a)
      result <- unsafeReadMutable bM
        -- using unsafeReadMutable is safe becasue bM is no longer reachable 
      return result
  [leftRoot,rightRoot] =
    runST $
      do
      [aM,drM,diM] <- mapM makeMutable [a,doubleRoot,discriminant]
      sqrtOutInPlace diM diM  -- sqrt(b^2-4*a*c)
      diM </>|= (2 :: Double) -- (sqrt(b^2-4*a*c))/2 
      diM </>= aM             -- (sqrt(b^2-4*a*c))/(2*a)
      assignMutable aM drM
      aM <->= diM             -- (-b-sqrt(b^2-4*a*c))/(2*a)
      drM <+>= diM            -- (-b+sqrt(b^2-4*a*c))/(2*a)
      result <- mapM unsafeReadMutable [aM,drM]
        -- using unsafeReadMutable is safe becasue aM and drM  are no longer reachable 
      return result

certainlyZero x =
  case x ==? 0 of
    Just True -> True
    _ -> False 

certainlyNonnegative x =
  case x >=? 0 of
    Just True -> True
    _ -> False 

certainlyNegative x =
  case x <? 0 of
    Just True -> True
    _ -> False 
