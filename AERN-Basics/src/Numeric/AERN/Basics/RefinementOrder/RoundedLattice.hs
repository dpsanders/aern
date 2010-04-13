{-|
    Module      :  Numeric.AERN.Basics.RefinementOrder.RoundedLattice
    Description :  lattices with outwards and inwards rounded operations  
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Lattices with outwards and inwards rounded operations.
    
    This module is hidden and reexported via its parent RefinementOrder. 
-}
module Numeric.AERN.Basics.RefinementOrder.RoundedLattice 
where

import Numeric.AERN.Basics.Exception

import Numeric.AERN.Basics.Mutable
import Control.Monad.ST (ST)

import Numeric.AERN.Basics.Effort
import Numeric.AERN.Misc.Maybe
import Numeric.AERN.Basics.PartialOrdering
import Numeric.AERN.Basics.RefinementOrder.Arbitrary
import Numeric.AERN.Basics.RefinementOrder.SemidecidableComparison

import Numeric.AERN.Basics.Laws.RoundedOperation
import Numeric.AERN.Basics.Laws.OperationRelation

import Test.QuickCheck
import Test.Framework (testGroup, Test)
import Test.Framework.Providers.QuickCheck2 (testProperty)

{-|
    A type with outward-rounding lattice operations.
-}
class OuterRoundedLattice t where
    joinOut :: [EffortIndicator] -> t -> t -> t
    meetOut :: [EffortIndicator] -> t -> t -> t
    joinmeetOutDefaultEffort :: t -> [EffortIndicator]

    (<|\/>) :: t -> t -> t
    (<|/\>) :: t -> t -> t
    
    a <|\/> b = joinOut (joinmeetOutDefaultEffort a) a b 
    a <|/\> b = meetOut (joinmeetOutDefaultEffort a) a b 

{-| convenience Unicode notation for '<|\/>' -}
(<⊔>) :: (OuterRoundedLattice t) => t -> t -> t
(<⊔>) = (<|\/>)
{-| convenience Unicode notation for '<|/\>' -}
(<⊓>) :: (OuterRoundedLattice t) => t -> t -> t
(<⊓>) = (<|/\>)


{-|
    A type with outward-rounding lattice operations.
-}
class InnerRoundedLattice t where
    joinIn :: [EffortIndicator] -> t -> t -> t
    meetIn :: [EffortIndicator] -> t -> t -> t
    joinmeetInDefaultEffort :: t -> [EffortIndicator]

    (>|\/<) :: t -> t -> t
    (>|/\<) :: t -> t -> t
    
    a >|\/< b = joinIn (joinmeetInDefaultEffort a) a b 
    a >|/\< b = meetIn (joinmeetInDefaultEffort a) a b 

{-| convenience Unicode notation for '>|\/<' -}
(>⊔<) :: (InnerRoundedLattice t) => t -> t -> t
(>⊔<) = (>|\/<)
{-| convenience Unicode notation for '>|/\<' -}
(>⊓<) :: (InnerRoundedLattice t) => t -> t -> t
(>⊓<) = (>|/\<)

class (InnerRoundedLattice t, OuterRoundedLattice t) => RoundedLattice t

-- properties of RoundedLattice

propRoundedLatticeComparisonCompatible :: 
    (SemidecidableComparison t, RoundedLattice t) => 
    t -> UniformlyOrderedPair t -> Bool
propRoundedLatticeComparisonCompatible _ (UniformlyOrderedPair (e1,e2)) = 
    (downRoundedJoinOfOrderedPair (|<=?) (<⊓>) e1 e2)
    && 
    (upRoundedMeetOfOrderedPair (|<=?) (>⊔<) e1 e2)

propRoundedLatticeJoinAboveBoth :: 
    (SemidecidableComparison t, RoundedLattice t) => 
    t -> UniformlyOrderedPair t -> Bool
propRoundedLatticeJoinAboveBoth _ (UniformlyOrderedPair (e1,e2)) = 
    joinAboveOperands (|<=?) (>⊔<) e1 e2

propRoundedLatticeMeetBelowBoth :: 
    (SemidecidableComparison t, RoundedLattice t) => 
    t -> UniformlyOrderedPair t -> Bool
propRoundedLatticeMeetBelowBoth _ (UniformlyOrderedPair (e1,e2)) = 
    meetBelowOperands (|<=?) (<⊓>) e1 e2

propRoundedLatticeJoinIdempotent :: 
    (SemidecidableComparison t, RoundedLattice t) => 
    t -> t -> Bool
propRoundedLatticeJoinIdempotent _ = 
    roundedIdempotent (|<=?) (>⊔<) (<⊔>)

propRoundedLatticeJoinCommutative :: 
    (SemidecidableComparison t, RoundedLattice t) => 
    t -> UniformlyOrderedPair t -> Bool
propRoundedLatticeJoinCommutative _ (UniformlyOrderedPair (e1,e2)) = 
    roundedCommutative (|<=?) (>⊔<) (<⊔>) e1 e2

propRoundedLatticeJoinAssocative :: 
    (SemidecidableComparison t, RoundedLattice t) => 
    t -> UniformlyOrderedTriple t -> Bool
propRoundedLatticeJoinAssocative _ (UniformlyOrderedTriple (e1,e2,e3)) = 
    roundedAssociative (|<=?) (>⊔<) (<⊔>) e1 e2 e3

propRoundedLatticeMeetIdempotent :: 
    (SemidecidableComparison t, RoundedLattice t) => 
    t -> t -> Bool
propRoundedLatticeMeetIdempotent _ = 
    roundedIdempotent (|<=?) (>⊓<) (<⊓>)

propRoundedLatticeMeetCommutative :: 
    (SemidecidableComparison t, RoundedLattice t) => 
    t -> UniformlyOrderedPair t -> Bool
propRoundedLatticeMeetCommutative _ (UniformlyOrderedPair (e1,e2)) = 
    roundedCommutative (|<=?) (>⊓<) (<⊓>) e1 e2

propRoundedLatticeMeetAssocative :: 
    (SemidecidableComparison t, RoundedLattice t) => 
    t -> UniformlyOrderedTriple t -> Bool
propRoundedLatticeMeetAssocative _ (UniformlyOrderedTriple (e1,e2,e3)) = 
    roundedAssociative (|<=?) (>⊓<) (<⊓>) e1 e2 e3

{- optional properties: -}
propRoundedLatticeModular :: 
    (SemidecidableComparison t, RoundedLattice t) => 
    t -> UniformlyOrderedTriple t -> Bool
propRoundedLatticeModular _ (UniformlyOrderedTriple (e1,e2,e3)) = 
    roundedModular (|<=?) (>⊔<) (>⊓<) (<⊔>) (<⊓>) e1 e2 e3

propRoundedLatticeDistributive :: 
    (SemidecidableComparison t, RoundedLattice t) => 
    t -> UniformlyOrderedTriple t -> Bool
propRoundedLatticeDistributive _ (UniformlyOrderedTriple (e1,e2,e3)) = 
    (roundedLeftDistributive  (|<=?) (>⊔<) (>⊓<) (<⊔>) (<⊓>) e1 e2 e3)
    && 
    (roundedLeftDistributive  (|<=?) (>⊔<) (>⊓<) (<⊔>) (<⊓>) e1 e2 e3)


testsRoundedLatticeDistributive :: 
    (SemidecidableComparison t,
     RoundedLattice t,
     Arbitrary t, 
     ArbitraryOrderedTuple t,
     Eq t, 
     Show t) => 
    (String, t) -> Test
testsRoundedLatticeDistributive (name, sample) =
    testGroup (name ++ " (min,max) rounded") $
        [
         testProperty "Comparison compatible" (propRoundedLatticeComparisonCompatible sample)
        ,
         testProperty "join above" (propRoundedLatticeJoinAboveBoth sample)
        ,
         testProperty "meet below" (propRoundedLatticeMeetBelowBoth sample)
        ,
         testProperty "join idempotent" (propRoundedLatticeJoinIdempotent sample)
        ,
         testProperty "join commutative" (propRoundedLatticeJoinCommutative sample)
        ,
         testProperty "join associative" (propRoundedLatticeJoinAssocative sample)
        ,
         testProperty "meet idempotent" (propRoundedLatticeMeetIdempotent sample)
        ,
         testProperty "meet commutative" (propRoundedLatticeMeetCommutative sample)
        ,
         testProperty "meet associative" (propRoundedLatticeMeetAssocative sample)
        ,
         testProperty "distributive" (propRoundedLatticeDistributive sample)
        ]
    
-- mutable versions (TODO)    