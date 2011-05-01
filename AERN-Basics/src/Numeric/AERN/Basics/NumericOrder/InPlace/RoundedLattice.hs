{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ImplicitParams #-}
{-|
    Module      :  Numeric.AERN.Basics.NumericOrder.InPlace.RoundedLattice
    Description :  lattices with directed-rounded in-place operations  
    Copyright   :  (c) Michal Konecny, Jan Duracz
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Lattices with directed-rounded in-place operations.
    
    This module is hidden and reexported via its grand-parent NumericOrder. 
-}
module Numeric.AERN.Basics.NumericOrder.InPlace.RoundedLattice 
where

import Prelude hiding ((<=))

import Numeric.AERN.Basics.Exception

import Numeric.AERN.Basics.Mutable
import Control.Monad.ST (ST)

import Numeric.AERN.Basics.Effort
import Numeric.AERN.Basics.PartialOrdering
import Numeric.AERN.Basics.NumericOrder.Arbitrary
import Numeric.AERN.Basics.NumericOrder.PartialComparison 
import Numeric.AERN.Basics.NumericOrder.Extrema
import Numeric.AERN.Basics.NumericOrder.RoundedLattice

import Numeric.AERN.Basics.Laws.RoundedOpInPlace

import Numeric.AERN.Misc.Maybe

import Test.QuickCheck
import Test.Framework (testGroup, Test)
import Test.Framework.Providers.QuickCheck2 (testProperty)

{-|
    A type with directed-rounding lattice operations.
-}
class 
    (RoundedLatticeEffort t, CanBeMutable t) => 
    RoundedLatticeInPlace t 
    where
    maxUpInPlaceEff :: OpMutable2Eff (MinmaxEffortIndicator t) t s
    maxDnInPlaceEff :: OpMutable2Eff (MinmaxEffortIndicator t) t s
    minUpInPlaceEff :: OpMutable2Eff (MinmaxEffortIndicator t) t s
    minDnInPlaceEff :: OpMutable2Eff (MinmaxEffortIndicator t) t s
    
maxUpInPlaceEffFromPure, 
 maxDnInPlaceEffFromPure, 
 minUpInPlaceEffFromPure,
 minDnInPlaceEffFromPure :: 
    (CanBeMutable t, RoundedLattice t) => 
    OpMutable2Eff (MinmaxEffortIndicator t) t s  
maxUpInPlaceEffFromPure = pureToMutable2Eff maxUpEff 
maxDnInPlaceEffFromPure = pureToMutable2Eff maxDnEff 
minUpInPlaceEffFromPure = pureToMutable2Eff minUpEff 
minDnInPlaceEffFromPure = pureToMutable2Eff minDnEff 

maxUpEffFromInPlace,
 maxDnEffFromInPlace,
 minUpEffFromInPlace,
 minDnEffFromInPlace ::
 (CanBeMutable t, RoundedLatticeInPlace t) =>
 (MinmaxEffortIndicator t) -> t -> t -> t
maxUpEffFromInPlace = mutable2EffToPure $ maxUpInPlaceEff 
maxDnEffFromInPlace = mutable2EffToPure $ maxDnInPlaceEff 
minUpEffFromInPlace = mutable2EffToPure $ minUpInPlaceEff 
minDnEffFromInPlace = mutable2EffToPure $ minDnInPlaceEff 

propRoundedLatticeJoinInPlaceConsistentWithPure ::
    (PartialComparison t, 
     RoundedLatticeInPlace t, RoundedLattice t, 
     CanBeMutable t) =>
    t -> 
    (MinmaxEffortIndicator t, PartialCompareEffortIndicator t) -> 
    UniformlyOrderedPair t -> Bool
propRoundedLatticeJoinInPlaceConsistentWithPure _ (minmaxEffort, effortComp)
        (UniformlyOrderedPair (e1,e2)) =
    inPlaceConsistentWithPure2 (pLeqEff effortComp) 
        (maxDnInPlaceEff minmaxEffort)  
        (maxUpInPlaceEff minmaxEffort)
        (maxDnEff minmaxEffort) 
        (maxUpEff minmaxEffort) 
        e1 e2  

propRoundedLatticeMeetInPlaceConsistentWithPure ::
    (PartialComparison t, 
     RoundedLatticeInPlace t, RoundedLattice t, 
     CanBeMutable t) => 
    t -> 
    (MinmaxEffortIndicator t, PartialCompareEffortIndicator t) -> 
    UniformlyOrderedPair t -> Bool
propRoundedLatticeMeetInPlaceConsistentWithPure _ (minmaxEffort, effortComp)
        (UniformlyOrderedPair (e1,e2)) =
    inPlaceConsistentWithPure2 (pLeqEff effortComp) 
        (minDnInPlaceEff minmaxEffort)  
        (minUpInPlaceEff minmaxEffort)
        (minDnEff minmaxEffort) 
        (minUpEff minmaxEffort) 
        e1 e2  

testsRoundedLatticeInPlace :: 
    (PartialComparison t,
     RoundedLatticeInPlace t, RoundedLattice t, 
     CanBeMutable t,
     Arbitrary t, Show t, 
     Arbitrary (MinmaxEffortIndicator t), Show (MinmaxEffortIndicator t), 
     Arbitrary (PartialCompareEffortIndicator t), Show (PartialCompareEffortIndicator t), 
     ArbitraryOrderedTuple t,
     Eq t
     ) => 
    (String, t) -> Test
testsRoundedLatticeInPlace (name, sample) =
    testGroup (name ++ " (min,max) rounded in-place") $
        [
         testProperty "join in-place=pure"
             (propRoundedLatticeJoinInPlaceConsistentWithPure sample)
        ,
         testProperty "meet in-place=pure"
             (propRoundedLatticeMeetInPlaceConsistentWithPure sample)
        ]

