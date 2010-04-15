{-# LANGUAGE FlexibleContexts #-}
{-|
    Module      :  Numeric.AERN.Basics.Interval.Basics
    Description :  consistency instances for intervals 
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Consistency instances for intervals.
    
    This is a hidden module reexported via its parent.
-}

module Numeric.AERN.Basics.Interval.Consistency 
(
    testsIntervalConsistencyFlip
)
where

import Prelude hiding (LT)
import Numeric.AERN.Basics.PartialOrdering

import Numeric.AERN.Basics.Interval.Basics
import Numeric.AERN.Basics.CInterval

import Numeric.AERN.Basics.Consistency

import qualified Numeric.AERN.Basics.NumericOrder as NumOrd
import Numeric.AERN.Basics.NumericOrder ((<=?))


import Test.QuickCheck
import Numeric.AERN.Misc.QuickCheck

import Test.Framework (testGroup, Test)
import Test.Framework.Providers.QuickCheck2 (testProperty)


instance (NumOrd.PartialComparison e) => HasConsistency (Interval e)
    where
    isConsistent (Interval l h) = l <=? h

instance (NumOrd.PartialComparison e) => HasAntiConsistency (Interval e)
    where
    isAntiConsistent (Interval l h) = h <=? l
    flipConsistency (Interval l h) = Interval h l

testsIntervalConsistencyFlip ::
    (Eq e, Show e, NumOrd.ArbitraryOrderedTuple e, NumOrd.PartialComparison e) =>
    (String, Interval e) -> Test
testsIntervalConsistencyFlip (typeName, sample) =
    testGroup (typeName ++ " consistency flip")
    [
        testProperty "really flips" (propFlipConsistency sample),
        testProperty "self inverse" (propConsistencyFlipSelfInverse sample)
    ]

-- random generation of intervals with no guarantee of consistency: 
instance (NumOrd.ArbitraryOrderedTuple e) => Arbitrary (Interval e)
    where
    arbitrary = 
        do
        (NumOrd.UniformlyOrderedPair (l,h)) <- arbitrary 
        return $ fromEndpoints (l,h)

{-| type for random generation of consistent intervals -}       
data ConsistentInterval e = ConsistentInterval (Interval e) deriving (Show)
        
instance (NumOrd.ArbitraryOrderedTuple e) => (Arbitrary (ConsistentInterval e))
    where
    arbitrary =
      case NumOrd.arbitraryPairRelatedBy LT of
          Just gen ->
              do
              (l,h) <- gen
              shouldBeSingleton <- arbitraryBoolRatio 1 10
              case shouldBeSingleton of
                  True -> return $ ConsistentInterval (Interval l l) 
                  False -> return $ ConsistentInterval (Interval l h)


{-| type for random generation of anti-consistent intervals -}        
data AntiConsistentInterval e = AntiConsistentInterval (Interval e) deriving (Show)
        
instance (NumOrd.ArbitraryOrderedTuple e) => (Arbitrary (AntiConsistentInterval e))
    where
    arbitrary =
      case NumOrd.arbitraryPairRelatedBy LT of
          Just gen ->
              do
              (l,h) <- gen 
              shouldBeSingleton <- arbitraryBoolRatio 1 10
              case shouldBeSingleton of
                  True -> return $ AntiConsistentInterval (Interval l l) 
                  False -> return $ AntiConsistentInterval (Interval h l)

{-| type for random generation of consistent and anti-consistent intervals 
    with the same probability -}        
data ConsistentOrACInterval e = ConsistentOrACInterval (Interval e) deriving (Show)
        
instance (NumOrd.ArbitraryOrderedTuple e) => (Arbitrary (ConsistentOrACInterval e))
    where
    arbitrary =
      do
      consistent <- arbitrary
      case consistent of
          True ->
              do
              (ConsistentInterval i) <- arbitrary
              return $ ConsistentOrACInterval i
          False ->
              do
              (AntiConsistentInterval i) <- arbitrary
              return $ ConsistentOrACInterval i
