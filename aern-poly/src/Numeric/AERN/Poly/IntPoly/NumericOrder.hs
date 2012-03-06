{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ImplicitParams #-}
{-# LANGUAGE MultiParamTypeClasses, UndecidableInstances #-}
{-|
    Module      :  Numeric.AERN.Poly.IntPoly.NumericOrder
    Description :  pointwise up/down comparison
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Pointwise up/down comparison of interval polynomials.
-}

module Numeric.AERN.Poly.IntPoly.NumericOrder
where
    
--import Numeric.AERN.Poly.IntPoly.Config
import Numeric.AERN.Poly.IntPoly.IntPoly
import Numeric.AERN.Poly.IntPoly.Evaluation ()
--import Numeric.AERN.Poly.IntPoly.Addition 
import Numeric.AERN.Poly.IntPoly.Multiplication ()

--import Numeric.AERN.RmToRn.New
--import Numeric.AERN.RmToRn.Domain
--import Numeric.AERN.RmToRn.Evaluation

import Numeric.AERN.RmToRn.NumericOrder.FromInOutRingOps.Comparison
import Numeric.AERN.RmToRn.NumericOrder.FromInOutRingOps.Arbitrary
import Numeric.AERN.RmToRn.NumericOrder.FromInOutRingOps.Minmax

import qualified Numeric.AERN.RealArithmetic.NumericOrderRounding as ArithUpDn

import qualified Numeric.AERN.RealArithmetic.RefinementOrderRounding as ArithInOut
import Numeric.AERN.RealArithmetic.RefinementOrderRounding.OpsImplicitEffort

--import Numeric.AERN.RealArithmetic.ExactOps
import Numeric.AERN.RealArithmetic.Measures

import qualified Numeric.AERN.NumericOrder as NumOrd
import qualified Numeric.AERN.RefinementOrder as RefOrd
--import Numeric.AERN.RefinementOrder.OpsImplicitEffort

import Numeric.AERN.Basics.PartialOrdering
import Numeric.AERN.Basics.Effort
import Numeric.AERN.Basics.Consistency
import Numeric.AERN.Basics.Arbitrary

--import Numeric.AERN.Misc.Debug

import Test.QuickCheck

        
instance
    (Show var, Ord var,
     Show cf, RefOrd.ArbitraryOrderedTuple cf, RefOrd.IntervalLike cf,
     ArithInOut.RoundedReal cf,
     HasAntiConsistency cf,
     ArithInOut.RoundedMixedMultiply cf cf,
     ArithInOut.RoundedMixedAdd cf cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf),
     Arbitrary (RefOrd.GetEndpointsEffortIndicator cf),
     Arbitrary (ArithInOut.MixedMultEffortIndicator cf cf),
     Arbitrary (ArithInOut.MixedAddEffortIndicator cf cf),
     Arbitrary (ArithInOut.RoundedRealEffortIndicator cf),
     Arbitrary (ArithInOut.AddEffortIndicator cf)
    )
    =>
    ArbitraryWithArea (IntPoly var cf)
    where
    type Area (IntPoly var cf) = Area4FunFromRingOps (IntPoly var cf)
    areaWhole sampleF = areaWhole4FunFromRingOps sampleF
    arbitraryInArea area@(sampleFn,_) =
        do
        eff <- arbitrary
        withEff eff
        where
        withEff eff =
            arbitraryInArea4FunFromRingOps eff
                (fnSequence fixedRandSeqQuantityOfSize sampleFn) 
                fixedRandSeqQuantityOfSize 
                area
        fixedRandSeqQuantityOfSize :: Int -> Int
        fixedRandSeqQuantityOfSize size
            = 10 + ((size*(size+100)) `div` 10)  
--            = 10 + (3*size)

instance
    (Show var, Ord var,
     Show cf, RefOrd.ArbitraryOrderedTuple cf, RefOrd.IntervalLike cf,
     ArithInOut.RoundedReal cf,
     HasAntiConsistency cf,
     ArithInOut.RoundedMixedMultiply cf cf,
     ArithInOut.RoundedMixedAdd cf cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf),
     Arbitrary (RefOrd.GetEndpointsEffortIndicator cf),
     Arbitrary (ArithInOut.MixedMultEffortIndicator cf cf),
     Arbitrary (ArithInOut.MixedAddEffortIndicator cf cf),
     Arbitrary (ArithInOut.RoundedRealEffortIndicator cf),
     Arbitrary (ArithInOut.AddEffortIndicator cf)
    )
    =>
    NumOrd.ArbitraryOrderedTuple (IntPoly var cf)
    where
    arbitraryTupleRelatedBy = 
        error "AERN internal error: NumOrd.arbitraryTupleRelatedBy not defined for IntPoly"
    arbitraryTupleInAreaRelatedBy area@(sampleFn,_) indices rels =
        case 
            arbitraryTupleInAreaRelatedBy4FunFromRingOps 
                dummyEff 
                (fnSequence fixedRandSeqQuantityOfSize sampleFn) 
                fixedRandSeqQuantityOfSize 
                area indices rels of
            Nothing -> Nothing
            Just _ -> Just $
                do
                eff <- arbitrary
                case
                    arbitraryTupleInAreaRelatedBy4FunFromRingOps 
                        eff 
                        (fnSequence fixedRandSeqQuantityOfSize sampleFn) 
                        fixedRandSeqQuantityOfSize 
                        area indices rels of
                    Just gen -> gen
        where
        fixedRandSeqQuantityOfSize :: Int -> Int
        fixedRandSeqQuantityOfSize size
            = 10 + ((size*(size+100)) `div` 10)  
--            = 10 + (3*size)
        dummyEff = 
            ((e,e,e),
             (e,e),
             (e,e)
            )
        e :: t
        e = error "AERN internal error: arbitraryTupleInAreaRelatedBy4FunFromRingOps: dummyEff should not be used"
        