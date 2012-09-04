{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ImplicitParams #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE UndecidableInstances #-}
{-|
    Module      :  Numeric.AERN.Poly.IntPoly.Minmax
    Description :  pointwise min/max
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Pointwise min/max of interval polynomials rounding up/down/in/out.
-}

module Numeric.AERN.Poly.IntPoly.Minmax
(
    minmaxUpDnDefaultEffortIntPolyWithBezierDegree,
    minmaxInOutDefaultEffortIntPolyWithBezierDegree
)
where
    
import Numeric.AERN.Poly.IntPoly.Config
import Numeric.AERN.Poly.IntPoly.IntPoly
import Numeric.AERN.Poly.IntPoly.New ()
import Numeric.AERN.Poly.IntPoly.Evaluation ()
import Numeric.AERN.Poly.IntPoly.NumericOrder ()
import Numeric.AERN.Poly.IntPoly.RefinementOrder ()
import Numeric.AERN.Poly.IntPoly.Addition ()
import Numeric.AERN.Poly.IntPoly.Multiplication () 
import Numeric.AERN.Poly.IntPoly.Composition ()

import Numeric.AERN.RmToRn.New
import Numeric.AERN.RmToRn.Domain
import Numeric.AERN.RmToRn.Evaluation

--import Numeric.AERN.RmToRn.NumericOrder.FromInOutRingOps.Comparison
--import Numeric.AERN.RmToRn.NumericOrder.FromInOutRingOps.Arbitrary
import Numeric.AERN.RmToRn.NumericOrder.FromInOutRingOps.Minmax

import qualified Numeric.AERN.RealArithmetic.NumericOrderRounding as ArithUpDn

import qualified Numeric.AERN.RealArithmetic.RefinementOrderRounding as ArithInOut
--import Numeric.AERN.RealArithmetic.RefinementOrderRounding.OpsImplicitEffort
import Numeric.AERN.RealArithmetic.RefinementOrderRounding (AbsEffortIndicator)

import Numeric.AERN.RealArithmetic.ExactOps
import Numeric.AERN.RealArithmetic.Measures

import qualified Numeric.AERN.NumericOrder as NumOrd
import Numeric.AERN.NumericOrder 
    (MinmaxEffortIndicator, MinmaxInOutEffortIndicator)
    -- ^^^ needed for ghc 6.12
import qualified Numeric.AERN.RefinementOrder as RefOrd
import Numeric.AERN.RefinementOrder
    (JoinMeetEffortIndicator)
    -- ^^^ needed for ghc 6.12
--import Numeric.AERN.RefinementOrder.OpsImplicitEffort

--import Numeric.AERN.Basics.PartialOrdering
import Numeric.AERN.Basics.Effort
import Numeric.AERN.Basics.Consistency

import Test.QuickCheck (Arbitrary)

import Numeric.AERN.Misc.Debug
_ = unsafePrint

instance
    (Ord var,
     GeneratableVariables var,
     HasAntiConsistency cf, 
     Arbitrary cf, 
     ArithInOut.RoundedReal cf,
     RefOrd.IntervalLike cf,
     ArithUpDn.Convertible cf cf,
     ArithInOut.RoundedMixedField cf cf,
     NumOrd.RefinementRoundedLatticeEffort cf,
     Show var,
     Show cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf))
    =>
    NumOrd.RoundedLatticeEffort (IntPoly var cf)
    where
    type MinmaxEffortIndicator (IntPoly var cf) =
        (MinmaxEffortIndicatorFromRingOps (IntPoly var cf) (IntPoly var cf),
         NumOrd.MinmaxInOutEffortIndicator cf,
         Int1To10, -- ^ (degree of Bernstein approximations) - 1   (the degree must be > 1)
         RefOrd.GetEndpointsEffortIndicator (IntPoly var cf))
    minmaxDefaultEffort f@(IntPoly cfg _) =
        (defaultMinmaxEffortIndicatorFromRingOps f f,
         NumOrd.minmaxInOutDefaultEffort sampleDom,
         Int1To10 (1 + (min 20 $ maxdeg `div` 3)),
         -- TODO: the minimum 20 makes sense only with Double coeffs;
         --       make it depend on the current coefficient precision
         RefOrd.getEndpointsDefaultEffort f)
        where
        maxdeg = ipolycfg_maxdeg cfg
        sampleDom = getSampleDomValue f

minmaxUpDnDefaultEffortIntPolyWithBezierDegree ::
    (ArithInOut.RoundedReal (Domain f), 
     RefOrd.IntervalLike (Domain f), 
     ArithUpDn.Convertible f (Domain f), 
     ArithInOut.RoundedMixedFieldEffort f Int, 
     ArithInOut.RoundedMixedField f (Domain f), 
     ArithInOut.RoundedRingEffort f, 
     HasSizeLimits f, 
     RefOrd.IntervalLike f,
     HasEvalOps f (Domain f),
     HasEvalOps f f)
    =>
    Int -> 
    f -> 
    (MinmaxEffortIndicatorFromRingOps f f,
     NumOrd.MinmaxInOutEffortIndicator (Domain f),
     Int1To10, -- ^ (degree of Bernstein approximations) - 1   (the degree must be > 1)
     RefOrd.GetEndpointsEffortIndicator f)
minmaxUpDnDefaultEffortIntPolyWithBezierDegree degree f =
    (defaultMinmaxEffortIndicatorFromRingOps f f,
     NumOrd.minmaxInOutDefaultEffort sampleDom,
     Int1To10 (degree - 1),
     RefOrd.getEndpointsDefaultEffort f)
    where
    sampleDom = getSampleDomValue f

instance
    (Ord var,
     GeneratableVariables var,
     HasAntiConsistency cf, 
     Arbitrary cf, 
     ArithInOut.RoundedReal cf,
     RefOrd.IntervalLike cf,
     ArithUpDn.Convertible cf cf,
     ArithInOut.RoundedMixedField cf cf,
     NumOrd.RefinementRoundedLattice cf,
     Show var,
     Show cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf))
    =>
    NumOrd.RoundedLattice (IntPoly var cf)
    where
    maxUpEff (effMinmax, effMinmaxDom, Int1To10 degreeMinusOne, effGetE) a b =
--        unsafePrint 
--            ( "IntPoly maxUpEff:"
--                ++ "\n degreeMinusOne = " ++ show degreeMinusOne
--                ++ "\n cfg a = " ++ show (intpoly_cfg a)
--                ++ "\n cfg b = " ++ show (intpoly_cfg b)
--                ++ "\n a = " ++ showPoly show show a
--                ++ "\n b = " ++ showPoly show show b
--                ++ "\n a `maxUp` b = " ++ showPoly show show result 
--            ) $
        result
        where
        result =
            case (getConstantIfPolyConstant a, getConstantIfPolyConstant b) of
                (Just aC, Just bC) ->
                    newConstFnFromSample a $ NumOrd.maxOutEff effMinmaxDom aC bC 
                _ ->
                    fst $ maxUpEffFromRingOps a getX effMinmax (getDegree degreeMinusOne a) aR bR
        (_aL,aR) = RefOrd.getEndpointsOutEff effGetE a
        (_bL,bR) = RefOrd.getEndpointsOutEff effGetE b
    maxDnEff (effMinmax, effMinmaxDom, Int1To10 degreeMinusOne, effGetE) a b =
        result
        where
        result =
            case (getConstantIfPolyConstant a, getConstantIfPolyConstant b) of
                (Just aC, Just bC) ->
                    newConstFnFromSample a $ NumOrd.maxOutEff effMinmaxDom aC bC 
                _ ->
                    maxDnEffFromRingOps a getX effMinmax (getDegree degreeMinusOne a) aL bL
        (aL,_aR) = RefOrd.getEndpointsOutEff effGetE a
        (bL,_bR) = RefOrd.getEndpointsOutEff effGetE b
    minUpEff (effMinmax, effMinmaxDom, Int1To10 degreeMinusOne,effGetE) a b = 
        result
        where
        result =
            case (getConstantIfPolyConstant a, getConstantIfPolyConstant b) of
                (Just aC, Just bC) ->
                    newConstFnFromSample a $ NumOrd.minOutEff effMinmaxDom aC bC 
                _ ->
                    minUpEffFromRingOps a getX effMinmax (getDegree degreeMinusOne a) aR bR
        (_aL,aR) = RefOrd.getEndpointsOutEff effGetE a
        (_bL,bR) = RefOrd.getEndpointsOutEff effGetE b
    minDnEff (effMinmax, effMinmaxDom, Int1To10 degreeMinusOne,effGetE) a b = 
        result
        where
        result =
            case (getConstantIfPolyConstant a, getConstantIfPolyConstant b) of
                (Just aC, Just bC) ->
                    newConstFnFromSample a $ NumOrd.minOutEff effMinmaxDom aC bC 
                _ ->
                    fst $ minDnEffFromRingOps a getX effMinmax (getDegree degreeMinusOne a) aL bL
        (aL,_aR) = RefOrd.getEndpointsOutEff effGetE a
        (bL,_bR) = RefOrd.getEndpointsOutEff effGetE b

instance
    (Ord var,
     GeneratableVariables var,
     HasAntiConsistency cf, 
     Arbitrary cf, 
     ArithInOut.RoundedReal cf,
     RefOrd.IntervalLike cf,
     ArithUpDn.Convertible cf cf,
     ArithInOut.RoundedMixedField cf cf,
     Show var,
     Show cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf))
    =>
    ArithUpDn.RoundedAbsEffort (IntPoly var cf)
    where
#if (__GLASGOW_HASKELL__ >= 704)
    type AbsEffortIndicator (IntPoly var cf) =
        (NumOrd.MinmaxEffortIndicator (IntPoly var cf),
         ArithInOut.AbsEffortIndicator cf)
#else
    type ArithUpDn.AbsEffortIndicator (IntPoly var cf) =
        (NumOrd.MinmaxEffortIndicator (IntPoly var cf),
         ArithInOut.AbsEffortIndicator cf)
#endif
    absDefaultEffort p =
        (NumOrd.minmaxDefaultEffort p,
         ArithInOut.absDefaultEffort $ getSampleDomValue p)

instance
    (Ord var,
     GeneratableVariables var,
     HasAntiConsistency cf, 
     Arbitrary cf, 
     ArithInOut.RoundedReal cf,
     RefOrd.IntervalLike cf,
     ArithUpDn.Convertible cf cf,
     ArithInOut.RoundedMixedField cf cf,
     Show var,
     Show cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf))
    =>
    ArithUpDn.RoundedAbs (IntPoly var cf)
    where
    absUpEff (effMinmax, effAbsDom) p =
        case getConstantIfPolyConstant p of
            Just c -> 
                newConstFnFromSample p $ 
                    snd $ RefOrd.getEndpointsOutWithDefaultEffort $ 
                        ArithInOut.absOutEff effAbsDom c
            _ -> NumOrd.maxUpEff effMinmax p (neg p)
    absDnEff (effMinmax, effAbsDom) p =
        case getConstantIfPolyConstant p of
            Just c -> 
                newConstFnFromSample p $ 
                    fst $ RefOrd.getEndpointsOutWithDefaultEffort $ 
                        ArithInOut.absOutEff effAbsDom c
            _ -> NumOrd.maxDnEff effMinmax p (neg p)


instance
    (Ord var,
     GeneratableVariables var,
     HasAntiConsistency cf, 
     Arbitrary cf, 
     ArithInOut.RoundedReal cf,
     RefOrd.IntervalLike cf,
     ArithUpDn.Convertible cf cf,
     ArithInOut.RoundedMixedField cf cf,
     Show var,
     Show cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf))
    =>
    NumOrd.RefinementRoundedLatticeEffort (IntPoly var cf)
    where
    type MinmaxInOutEffortIndicator (IntPoly var cf) =
        (MinmaxEffortIndicatorFromRingOps (IntPoly var cf) (IntPoly var cf),
         Int1To10, -- ^ (degree of Bernstein approximations) - 1   (the degree must be > 1)
         RefOrd.GetEndpointsEffortIndicator (IntPoly var cf),
         RefOrd.FromEndpointsEffortIndicator (IntPoly var cf))

    minmaxInOutDefaultEffort f@(IntPoly cfg _) =
        (defaultMinmaxEffortIndicatorFromRingOps f f, 
         Int1To10 (1 + (min 20 $ maxdeg `div` 3)),
         -- TODO: the minimum 20 makes sense only with Double coeffs;
         --       make it depend on the current coefficient precision
         RefOrd.getEndpointsDefaultEffort f,
         RefOrd.fromEndpointsDefaultEffort f)
        where
        maxdeg = ipolycfg_maxdeg cfg

minmaxInOutDefaultEffortIntPolyWithBezierDegree ::
    (ArithUpDn.Convertible f (Domain f), 
     ArithInOut.RoundedMixedFieldEffort f Int, 
     ArithInOut.RoundedMixedField f (Domain f), 
     ArithInOut.RoundedRingEffort f, 
     HasSizeLimits f,
     RefOrd.IntervalLike f, 
     HasEvalOps f (Domain f), 
     HasEvalOps f f,
     GeneratableVariables (Var f),
     HasAntiConsistency (Domain f),
     Arbitrary (Domain f), 
     ArithInOut.RoundedReal (Domain f),
     RefOrd.IntervalLike (Domain f),
     ArithUpDn.Convertible (Domain f) (Domain f),
     ArithInOut.RoundedMixedField (Domain f) (Domain f),
     Show (Var f),
     Show (Domain f),
     Show (Imprecision (Domain f)),
     NumOrd.PartialComparison (Imprecision (Domain f)))
    =>
    Int -> (f) -> 
    (MinmaxEffortIndicatorFromRingOps (f) (f),
     Int1To10, -- ^ (degree of Bernstein approximations) - 1   (the degree must be > 1)
     RefOrd.GetEndpointsEffortIndicator (f),
     RefOrd.FromEndpointsEffortIndicator (f))    
minmaxInOutDefaultEffortIntPolyWithBezierDegree degree f =
    (defaultMinmaxEffortIndicatorFromRingOps f f,
     Int1To10 (degree - 1),
     RefOrd.getEndpointsDefaultEffort f,
     RefOrd.fromEndpointsDefaultEffort f)

instance
    (Ord var,
     GeneratableVariables var,
     HasAntiConsistency cf, 
     Arbitrary cf, 
     ArithInOut.RoundedReal cf,
     RefOrd.IntervalLike cf,
     ArithUpDn.Convertible cf cf,
     ArithInOut.RoundedMixedField cf cf,
     Show var,
     Show cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf))
    =>
    NumOrd.RefinementRoundedLattice (IntPoly var cf)
    where
    maxOutEff (effMinmax,Int1To10 degreeMinusOne,effGetE,effFromE) a b =
        result
        where
        result =
            makeCoeffsConsistentOut $ 
            RefOrd.fromEndpointsOutEff effFromE (resL,resR)
        resL = maxDnEffFromRingOps a getX effMinmax (getDegree degreeMinusOne a) aL bL
        (resR, _) = maxUpEffFromRingOps a getX effMinmax (getDegree degreeMinusOne a) aR bR
        (aL,aR) = RefOrd.getEndpointsOutEff effGetE a
        (bL,bR) = RefOrd.getEndpointsOutEff effGetE b
    maxInEff =
        error "aern-poly: inner-rounded max not available for IntPoly"
    minOutEff (effMinmax,Int1To10 degreeMinusOne,effGetE,effFromE) a b =
        result
        where
        result = 
            makeCoeffsConsistentOut $ 
            RefOrd.fromEndpointsOutEff effFromE (resL,resR)
        (resL, _) = minDnEffFromRingOps a getX effMinmax (getDegree degreeMinusOne a) aL bL
        resR = minUpEffFromRingOps a getX effMinmax (getDegree degreeMinusOne a) aR bR
        (aL,aR) = RefOrd.getEndpointsOutEff effGetE a
        (bL,bR) = RefOrd.getEndpointsOutEff effGetE b
    minInEff =
        error "aern-poly: inner-rounded min not available for IntPoly"
    
    
instance
    (Ord var,
     GeneratableVariables var,
     HasAntiConsistency cf, 
     Arbitrary cf, 
     ArithInOut.RoundedReal cf,
     RefOrd.IntervalLike cf,
     ArithUpDn.Convertible cf cf,
     ArithInOut.RoundedMixedField cf cf,
     Show var,
     Show cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf))
    =>
    ArithInOut.RoundedAbsEffort (IntPoly var cf)
    where
#if (__GLASGOW_HASKELL__ >= 704)
    type AbsEffortIndicator (IntPoly var cf) =
        (NumOrd.MinmaxInOutEffortIndicator (IntPoly var cf),
         ArithInOut.AbsEffortIndicator cf)
#else
    type ArithInOut.AbsEffortIndicator (IntPoly var cf) =
        (NumOrd.MinmaxInOutEffortIndicator (IntPoly var cf),
         ArithInOut.AbsEffortIndicator cf)
#endif
    absDefaultEffort p =
        (NumOrd.minmaxInOutDefaultEffort p,
         ArithInOut.absDefaultEffort $ getSampleDomValue p)

instance
    (Ord var,
     GeneratableVariables var,
     HasAntiConsistency cf, 
     Arbitrary cf, 
     ArithInOut.RoundedReal cf,
     RefOrd.IntervalLike cf,
     ArithUpDn.Convertible cf cf,
     ArithInOut.RoundedMixedField cf cf,
     Show var,
     Show cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf))
    =>
    ArithInOut.RoundedAbs (IntPoly var cf)
    where
    absOutEff (effMinmax, effAbsDom) p =
        case getConstantIfPolyConstant p of
            Just c -> newConstFnFromSample p $ ArithInOut.absOutEff effAbsDom c
            _ -> NumOrd.maxOutEff effMinmax p (neg p)
    absInEff =
        error "aern-poly: inner-rounded abs not available for IntPoly"
    
instance
    (Ord var,
     GeneratableVariables var,
     HasAntiConsistency cf, 
     Arbitrary cf, 
     ArithInOut.RoundedReal cf,
     RefOrd.IntervalLike cf,
     ArithInOut.RoundedMixedField cf cf,
     Show var,
     Show cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf))
    =>
    RefOrd.RoundedLatticeEffort (IntPoly var cf)
    where
    type JoinMeetEffortIndicator (IntPoly var cf) =
        RefOrd.JoinMeetEffortIndicator cf

    joinmeetDefaultEffort (IntPoly cfg _) =
        RefOrd.joinmeetDefaultEffort $ ipolycfg_sample_cf cfg

--joinmeetDefaultEffortIntPolyWithBezierDegree degree f =
--    (defaultMinmaxEffortIndicatorFromRingOps f f,
--     Int1To10 (degree - 1),
--     RefOrd.getEndpointsDefaultEffort f,
--     RefOrd.fromEndpointsDefaultEffort f)

instance
    (Ord var,
     GeneratableVariables var,
     HasAntiConsistency cf, 
     Arbitrary cf, 
     ArithInOut.RoundedReal cf,
     RefOrd.IntervalLike cf,
     ArithInOut.RoundedMixedField cf cf,
     Show var,
     Show cf,
     Show (Imprecision cf),
     NumOrd.PartialComparison (Imprecision cf))
    =>
    RefOrd.RoundedLattice (IntPoly var cf)
    where
    joinOutEff =
        error "aern-poly: join not defined for IntPoly"
    joinInEff =
        error "aern-poly: join not defined for IntPoly"
    meetOutEff eff a b@(IntPoly cfg _) =
        polyJoinWith (zero sampleCf) (uncurry $ RefOrd.meetOutEff eff) (a, b)
        where
        sampleCf = ipolycfg_sample_cf cfg
    meetInEff =
        error "aern-poly: inner-rounded meet not defined for IntPoly"

getX ::
    (ArithInOut.RoundedReal (Domain f),
     RefOrd.IntervalLike (Domain f),
     HasProjections f,
     SizeLimits f ~ IntPolyCfg (Var f) (Domain f)) 
    =>
    IntPolyCfg (Var f) (Domain f) -> f
getX sizeLimits@(IntPolyCfg vars _ _ sample md ms) =
    newProjection cfg dombox var
    where
    _ = [sizeLimits, cfg] -- , getSizeLimits sampleT]
    var = head vars
    cfg =
        IntPolyCfg [var] [unit] [zero sample] sample md ms
    dombox = fromList $ cfg2vardomains cfg
    unit =
        RefOrd.fromEndpointsOutWithDefaultEffort (zero sample, one sample)
    
getDegree :: Int -> IntPoly var cf -> Int
getDegree degreeMinusOne (IntPoly cfg _) =
    max 2 $ min (degreeMinusOne + 1) maxDeg
    where
    maxDeg = ipolycfg_maxdeg cfg