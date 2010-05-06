{-|
    Module      :  Numeric.AERN.RealArithmetic.Interval.ExactOperations
    Description :  exact zero, one and neg for intervals 
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Exact zero, one and neg for intervals.
    
    This module is hidden and reexported via its parent Interval. 
-}

module Numeric.AERN.RealArithmetic.Interval.ExactOperations where

import Numeric.AERN.Basics.Interval
import qualified Numeric.AERN.Basics.NumericOrder as NumOrd 
import Numeric.AERN.RealArithmetic.ExactOperations

instance  (HasZero e, NumOrd.PartialComparison e) => HasZero (Interval e) where
    zero = Interval zero zero

instance  (HasOne e) => HasOne (Interval e) where
    one = Interval one one

instance (HasInfinities e) => HasInfinities (Interval e) where
    plusInfinity = Interval plusInfinity plusInfinity
    minusInfinity = Interval minusInfinity minusInfinity
    excludesPlusInfinity (Interval l h) = excludesPlusInfinity h
    excludesMinusInfinity (Interval l h) = excludesMinusInfinity l

instance  (Neg e) => Neg (Interval e) where
    neg (Interval l h) = Interval (neg h) (neg l)

