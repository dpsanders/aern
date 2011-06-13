{-|
    Module      :  Numeric.AERN.RealArithmetic.Interval.MPFR
    Description :  Interval MPFR utilities and tests  
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Interval MPFR utilities and tests.
-}
module Numeric.AERN.RealArithmetic.Interval.MPFR 
where

import Numeric.AERN.Basics.Interval

import Numeric.AERN.RealArithmetic.Interval

import Data.Number.MPFR (MPFR)
import Data.Number.MPFR.Instances.Up

import Numeric.AERN.RealArithmetic.Basis.MPFR.ShowInternals
import Numeric.AERN.RealArithmetic.Basis.MPFR.NumericOrder
import Numeric.AERN.RealArithmetic.Basis.MPFR.FieldOps
import Numeric.AERN.RealArithmetic.Basis.MPFR.ExactOps

import qualified Numeric.AERN.Basics.NumericOrder as NumOrd
import Numeric.AERN.RealArithmetic.RefinementOrderRounding.OpsDefaultEffort

import Test.QuickCheck

type MI = Interval MPFR

sampleMI :: MI
sampleMI = Interval 0 0

newtype PositiveMI = PositiveMI { unPositiveMI :: MI }

instance Show PositiveMI where
    show (PositiveMI i) = show i

instance Arbitrary PositiveMI
    where
    arbitrary =
        do
        NumOrd.UniformlyOrderedPair (l,h) <- arbitrary
        return $ PositiveMI (Interval (pos l) (pos h))
        where
        pos e 
            | e > 0 =  e
            | e == 0 =  1
            | otherwise = (-e) 

{-|
    Calculate the width of an interval.
    The result may not be thin since the width calculation uses outwards rounding.
-}
width :: MI -> MI
width i = 
  irI <-> ilI
  where
  irI = Interval ir ir  
  ilI = Interval il il
  Interval il ir = i  

{-|
    Split an interval into two subintervals that share only one point 
    and whose union is the original interval.
-}
bisect ::
    Maybe MPFR {-^ optional parameter, indicating where to split the interval -} -> 
    MI {-^ the interval to split -} -> 
    (MI, MI)
bisect maybeMidpoint i =
  (l,r)
  where
  r = Interval midpoint ir
  l = Interval il midpoint
  midpoint 
    = case maybeMidpoint of
        Nothing -> 0.5*(il + ir)
        Just m -> m
  Interval il ir = i
            