{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ImplicitParams #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}
{-|
    Module      :  Numeric.AERN.RmToRn.NumericOrder.FromInOutRingOps.Minmax
    Description :  approximation of min and max using only ring operations
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable

    Approximation of min and max using only ring operations.
    .
    The motivating use case for this module is where we compute min or max for a 
    /function/ pointwise over its domain.
-}

module Numeric.AERN.RmToRn.NumericOrder.FromInOutRingOps.Minmax where

import Numeric.AERN.RmToRn.Domain
import Numeric.AERN.RmToRn.New
import Numeric.AERN.RmToRn.Evaluation
import Numeric.AERN.RmToRn.RefinementOrderRounding.BernsteinPoly

import Numeric.AERN.RealArithmetic.ExactOps

import qualified Numeric.AERN.RealArithmetic.RefinementOrderRounding as ArithInOut
import Numeric.AERN.RealArithmetic.RefinementOrderRounding.OpsImplicitEffort
--import Numeric.AERN.RealArithmetic.RefinementOrderRounding.InPlace.OpsImplicitEffort

import qualified Numeric.AERN.RealArithmetic.NumericOrderRounding as ArithUpDn

import qualified Numeric.AERN.RefinementOrder as RefOrd
import Numeric.AERN.RefinementOrder.OpsImplicitEffort
----import Numeric.AERN.RefinementOrder.InPlace.OpsImplicitEffort

import qualified Numeric.AERN.NumericOrder as NumOrd
import Numeric.AERN.NumericOrder.OpsImplicitEffort

import Numeric.AERN.Basics.Effort
import Numeric.AERN.Basics.Mutable
import Numeric.AERN.RealArithmetic.ExactOps

import Numeric.AERN.Misc.Debug

import Test.QuickCheck

--import qualified Data.List as List

import Control.Monad.ST (ST)


type MinmaxInOutEffortIndicatorFromRingOps f t =
        ((ArithUpDn.ConvertEffortIndicator t (Domain f), -- finding the range of a function of type t
          ArithInOut.RoundedRealEffortIndicator (Domain f),
          RefOrd.GetEndpointsEffortIndicator (Domain f)
          )
          ,
          (EvalOpsEffortIndicator f t,
           EvalOpsEffortIndicator f (Domain f))
          ,
         (ArithInOut.RingOpsEffortIndicator f,
          ArithInOut.MixedFieldOpsEffortIndicator f Int,
          SizeLimits f,
          Int1To10 -- ^ degree of Bernstein approximations - 1 (1 is added to avoid the illegal degree 1)
         ),
         (ArithInOut.RingOpsEffortIndicator t,
          ArithInOut.MixedFieldOpsEffortIndicator t (Domain f)
         )
        )

--deriving instance
--    (ArithUpDn.Convertible t (Domain f),
--     ArithInOut.RoundedReal (Domain f),
--     HasEvalOps f t, HasEvalOps f (Domain f),
--     ArithInOut.RoundedRing t,
--     ArithInOut.RoundedRing f,
--     ArithInOut.RoundedMixedField f Int,
--     ArithInOut.RoundedMixedField t (Domain f),
--     Show (SizeLimits f)) 
--    =>
--    Show (MinmaxInOutEffortIndicatorFromRingOps f t)

    
defaultMinmaxInOutEffortIndicatorFromRingOps :: 
    (ArithUpDn.Convertible t (Domain f), 
     ArithInOut.RoundedReal (Domain f),
     RefOrd.IntervalLike (Domain f),
     HasSizeLimits f,
     HasDomainBox f,
     HasEvalOps f t,
     HasEvalOps f (Domain f),
     ArithInOut.RoundedRingEffort f,
     ArithInOut.RoundedMixedFieldEffort f Int,
     ArithInOut.RoundedMixedField t (Domain f),
     ArithInOut.RoundedRingEffort t
    )
    =>
    f {-^ the identity function over interval [0,1] in the type used for approximating Bernstein polynomials -} -> 
    t {-^ an arbitrary sample value of the main type -} -> 
    MinmaxInOutEffortIndicatorFromRingOps f t
defaultMinmaxInOutEffortIndicatorFromRingOps =
    defaultMinmaxInOutEffortIndicatorFromRingOpsDegree 3

defaultMinmaxInOutEffortIndicatorFromRingOpsDegree :: 
    (ArithUpDn.Convertible t (Domain f), 
     ArithInOut.RoundedReal (Domain f),
     RefOrd.IntervalLike (Domain f),
     HasSizeLimits f,
     HasDomainBox f,
     HasEvalOps f t,
     HasEvalOps f (Domain f),
     ArithInOut.RoundedRingEffort f,
     ArithInOut.RoundedMixedFieldEffort f Int,
     ArithInOut.RoundedMixedField t (Domain f),
     ArithInOut.RoundedRingEffort t
    )
    =>
    Int ->
    f {-^ an arbitrary sample value of a function type used to model internal Bernstein approximations -} -> 
    t {-^ an arbitrary sample value of the main type -} -> 
    MinmaxInOutEffortIndicatorFromRingOps f t
defaultMinmaxInOutEffortIndicatorFromRingOpsDegree degree sampleF sampleT =
      -- ^ variable @x@ over @[0,1]@ of the function type @f@ to use for computing Bernstein approximation of @max(0,x-c)@
    ((ArithUpDn.convertDefaultEffort sampleT sampleDF, -- finding the range of a function of type t
      ArithInOut.roundedRealDefaultEffort sampleDF,
      RefOrd.getEndpointsDefaultEffort sampleDF
     )
     ,
     (evalOpsDefaultEffort sampleF sampleT,
      evalOpsDefaultEffort sampleF sampleDF
     )
     ,
     (ArithInOut.ringOpsDefaultEffort sampleF,
      ArithInOut.mixedFieldOpsDefaultEffort sampleF (1::Int),
      getSizeLimits sampleF,
      Int1To10 (degree - 1) -- ^ degree of Bernstein approximations - 1
     )
     ,
     (ArithInOut.ringOpsDefaultEffort sampleT,
      ArithInOut.mixedFieldOpsDefaultEffort sampleT sampleDF
     )
    )
    where
    sampleDF = getSampleDomValue sampleF

maxUpEffFromRingOps :: 
    (
     Show t, Show f,
     HasZero t, 
     ArithInOut.RoundedRing t,
     ArithUpDn.Convertible t (Domain f), 
     ArithInOut.RoundedReal (Domain f),
     RefOrd.IntervalLike (Domain f),
     Show (Domain f),
     ArithInOut.RoundedMixedField t (Domain f),
     HasEvalOps f t, 
     HasVarValue (VarBox f t) (Var f) t,
     HasEvalOps f (Domain f),
     HasVarValue (VarBox f (Domain f)) (Var f) (Domain f),
     HasProjections f, HasConstFns f, HasOne f, -- HasZero f,
     ArithInOut.RoundedRing f,
     ArithInOut.RoundedMixedField f Int) 
    =>
    f ->
    (SizeLimits f -> f) ->
    MinmaxInOutEffortIndicatorFromRingOps f t -> 
    t -> t -> t
maxUpEffFromRingOps _ getX eff@(_, _, _, (effRing, _)) a b =
    let ?addInOutEffort = effAdd in
    a <+> (snd $ maxZeroDnUp getX eff $ b <-> a)
    where
    effAdd = ArithInOut.ringEffortAdd sampleT $ effRing
    sampleT = a

maxDnEffFromRingOps :: 
    (
     Show t, Show f,
     HasZero t, 
     ArithInOut.RoundedRing t,
     ArithUpDn.Convertible t (Domain f), 
     ArithInOut.RoundedReal (Domain f),
     RefOrd.IntervalLike (Domain f),
     Show (Domain f),
     ArithInOut.RoundedMixedField t (Domain f),
     HasEvalOps f t, 
     HasVarValue (VarBox f t) (Var f) t,
     HasEvalOps f (Domain f),
     HasVarValue (VarBox f (Domain f)) (Var f) (Domain f),
     HasProjections f, HasConstFns f, HasOne f, -- HasZero f,
     ArithInOut.RoundedRing f,
     ArithInOut.RoundedMixedField f Int) 
    =>
    f ->
    (SizeLimits f -> f) ->
    MinmaxInOutEffortIndicatorFromRingOps f t -> 
    t -> t -> t
maxDnEffFromRingOps _ getX eff@(_, _, _, (effRing, _)) a b =
    let ?addInOutEffort = effAdd in
    a <+> (fst $ maxZeroDnUp getX eff $ b <-> a)
    where
    effAdd = ArithInOut.ringEffortAdd sampleT $ effRing
    sampleT = a

--maxOutEffFromRingOps :: 
--    (ArithInOut.RoundedAdd t, 
--     ArithInOut.RoundedSubtr t, 
--     ArithInOut.RoundedMultiply t, 
--     ArithInOut.RoundedPowerToNonnegInt t) =>
--    MinmaxInOutEffortIndicatorFromRingOps f t -> t -> t -> t
--maxOutEffFromRingOps eff@(_, _, effAdd, _) a b =
--    let ?addInOutEffort = effAdd in
--    a <+> (maxZeroOut eff $ b <-> a)
--
--maxZeroOut ::    
--    (ArithInOut.RoundedAdd t, 
--     ArithInOut.RoundedSubtr t, 
--     ArithInOut.RoundedMultiply t, 
--     ArithInOut.RoundedPowerToNonnegInt t) =>
--    MinmaxInOutEffortIndicatorFromRingOps f t -> t -> t
--maxZeroOut (degree, x, effAdd, effMult) a =
--    error $ "maxZero not implemented yet"
    
maxZeroDnUp ::    
    (
     Show t, Show f,
     HasZero t, 
     ArithInOut.RoundedRing t,
     ArithUpDn.Convertible t (Domain f), 
     ArithInOut.RoundedReal (Domain f),
     RefOrd.IntervalLike (Domain f),
     Show (Domain f),
     ArithInOut.RoundedMixedField t (Domain f),
     HasEvalOps f t, 
     HasVarValue (VarBox f t) (Var f) t,
     HasEvalOps f (Domain f),
     HasVarValue (VarBox f (Domain f)) (Var f) (Domain f),
     HasProjections f, HasConstFns f, HasOne f, -- HasZero f,
     ArithInOut.RoundedRing f,
     ArithInOut.RoundedMixedField f Int) 
    =>
    (SizeLimits f -> f) ->
    MinmaxInOutEffortIndicatorFromRingOps f t -> 
    t -> 
    (t,t)
{-
    overview of the algorithm:
    
    * find bounds of type (Domain f) for a (a is of type t)
    * if a can be shown to be positive or negative, finish
    * affinely transform a to a' so that it fits inside [0,1] 
      and note the point 0 < c < 1 where the original crossed zero
    * compute a Bernstein approximation of the given degree to the function \y -> \max(0,y-c)
    * compute a reliable estimate e of the approximation error
    * r' = evaluate this polynomial with a' for y and add [-e,0] 
    * transform r' back to the range of a to get the result r 
-}
maxZeroDnUp
        getX
        ((effTToDom, effRealDF, effGetEDF), 
         (effEvalOpsT, effEvalOpsDF), 
         (effRingF, effIntFldF, sizeLimits, Int1To10 degreeMinusOne), 
         (effRingT, effFldTDF))
        a =
    let ?pCompareEffort = effCompDF in
    case (bounded, maybeaDn, c0 <=? aDn, maybeaUp, aUp <=? c0) of
        (_,Nothing, _,_,_) -> error "maxZeroDnUp called for an unbounded value"
        (_,_,_,Nothing,_) -> error "maxZeroDnUp called for an unbounded value"
        (False,_,_,_,_) -> error "maxZeroDnUp called for an unbounded value"
        (_,_, Just True, _, _) ->
--            unsafePrint ("maxZeroDnUp: positive") $ 
            (a, a)
        (_,_,_,_, Just True) -> 
--            unsafePrint ("maxZeroDnUp: negative") $ 
            (zero a, zero a)
        _ -> 
--            unsafePrint ("maxZeroDnUp: mixed"
--                ++ "\n maxCUp = " ++ show maxCUp
--                ++ "\n translateToUnit a = " ++ show (translateToUnit a)
--                ++ "\n evalOtherType (evalOpsOut effEvalOpsT sampleF sampleT) (fromAscList [(var, translateToUnit a)]) maxZeroUp = " 
--                ++ show (evalOtherType (evalOpsOut effEvalOpsT sampleF sampleT) (fromAscList [(var, translateToUnit a)]) maxZeroUp)
--                ++ "\n maxCDn = " ++ show maxCDn
--            ) $ 
            (viaBernsteinDn, viaBernsteinUp)
    where
    degree = degreeMinusOne + 1
    sampleT = a
    sampleF = x
    x = getX sizeLimits
    sampleDF = getSampleDomValue x
    maybeaUp = ArithUpDn.convertUpEff effTToDom a
    maybeaDn = ArithUpDn.convertDnEff effTToDom a
    Just aUp = maybeaUp
    Just aDn = maybeaDn
    bounded = excludesInfinity aWidth
    
    viaBernsteinUp = 
        doSubst $ maxCUp
    viaBernsteinDn = 
        doSubst $ maxCDn
    doSubst p =  
        translateFromUnit $
        evalOtherType (evalOpsOut effEvalOpsT sampleF sampleT) varA p
        where
        varA = fromAscList [(var, translateToUnit a)]
    (var:_) = getVars $ getDomainBox $ x
    maxCUp = hillbaseApproxUp effCompDF effRingF effIntFldF effRealDF x c degree
    maxCDn =
        hillbaseApproxDn effGetEDF effCompDF effRingF effIntFldF effRealDF effEvalOpsDF x c dInit degree
        where
        dInit = 
            let (<->) = ArithInOut.subtrOutEff effAddDF in
            let (<*>|) = ArithInOut.mixedMultOutEff effMultDFI in
            (maxCUpAtC <-> c) <*>| (2 :: Int)
        maxCUpAtC =
            evalOtherType (evalOpsOut effEvalOpsDF sampleF sampleDF) varC maxCUp
        varC = fromAscList [(var, c)]
    c = 
        let (</>) = ArithInOut.divOutEff effDivDF in
        (neg aDn) </> aWidth
    aWidth = 
        let (<->) = ArithInOut.subtrOutEff effAddDF in
        aUp <-> aDn
    translateToUnit b =
        let (<+>|) = ArithInOut.mixedAddOutEff effAddTDF in
        let (</>|) = ArithInOut.mixedDivOutEff effDivTDF in
        (b <+>| (neg aDn)) </>| aWidth
    translateFromUnit b =
        let (<+>|) = ArithInOut.mixedAddOutEff effAddTDF in
        let (<*>|) = ArithInOut.mixedMultOutEff effMultTDF in
        (b <*>| aWidth) <+>| aDn
    c0 = zero sampleDF
    _ = [c,c0]
    
    effCompDF = ArithInOut.rrEffortNumComp c0 effRealDF
    effAddDF = ArithInOut.fldEffortAdd c0 $ ArithInOut.rrEffortField c0 effRealDF
    effDivDF = ArithInOut.fldEffortDiv c0 $ ArithInOut.rrEffortField c0 effRealDF
    
    effAddTDF = ArithInOut.mxfldEffortAdd a c0 effFldTDF
    effMultTDF = ArithInOut.mxfldEffortMult a c0 effFldTDF
    effDivTDF = ArithInOut.mxfldEffortDiv a c0 effFldTDF
    
    effMultDFI = ArithInOut.mxfldEffortMult sampleDF (1::Int) $ ArithInOut.rrEffortIntMixedField sampleDF effRealDF

{-| compute an upper Bernstein approximation of the function max(x,c) over [0,1] -}
hillbaseApproxUp :: 
    (HasConstFns f, HasProjections f, HasOne f, ArithInOut.RoundedRing f, 
     ArithInOut.RoundedMixedField f Int,
     ArithInOut.RoundedReal (Domain f),
     Show (Domain f), Show f)
    =>
    NumOrd.PartialCompareEffortIndicator (Domain f) -> 
    ArithInOut.RingOpsEffortIndicator f -> 
    ArithInOut.MixedFieldOpsEffortIndicator f Int -> 
    ArithInOut.RoundedRealEffortIndicator (Domain f) -> 
    f {-^ the variable @x@ to use in the result uni-variate polynomial -} ->
    Domain f {-^ @c@ the only non-smooth point of the approximated piece-wise linear function -} ->
    Int {-^ @n@ Bernstein approximation degree -} ->
    f
hillbaseApproxUp effComp effRingF effIntFldF effRealDF x c n =
    let ?pCompareEffort = effComp in
    let ?addInOutEffort = effAddDF in
    let ?multInOutEffort = effMultF in
    let ?mixedMultInOutEffort = effMultDFI in
    let ?mixedDivInOutEffort = effDivDFI in
--    unsafePrintReturn ( "hillbaseApproxUp:"
--        ++ "\n c = " ++ show c
--        ++ "\n result = "
--    ) $
    foldl1 (ArithInOut.addOutEff effAddF) $
        map mkBT [0..n]
    where
    mkBT p =
        (newConstFnFromSample x fOfpOverN)
        <*> 
        (bernsteinOut (effRingF, effIntFldF) x n p)
        where
        fOfpOverN -- = maxOutEff effMinmax c0 $ pOverN <-> c
            | (pOverN <? c) == Just True = c
            | otherwise = pOverN
        pOverN = (c1 <*>| p) </>| n
    c1 = one sampleDF
    sampleDF = getSampleDomValue x
    
    effAddF = ArithInOut.ringEffortAdd x effRingF
    effMultF = ArithInOut.ringEffortMult x effRingF
    
    effMultDFI = ArithInOut.mxfldEffortMult sampleDF (1::Int) $ ArithInOut.rrEffortIntMixedField sampleDF effRealDF
    effDivDFI = ArithInOut.mxfldEffortDiv sampleDF (1::Int) $ ArithInOut.rrEffortIntMixedField sampleDF effRealDF

    effMultDF = ArithInOut.fldEffortMult sampleDF $ ArithInOut.rrEffortField sampleDF effRealDF
    effAddDF = ArithInOut.fldEffortAdd sampleDF $ ArithInOut.rrEffortField sampleDF effRealDF

{-| compute a lower Bernstein approximation of the function max(c,x) over [0,1] -}
hillbaseApproxDn :: 
    (HasConstFns f, HasProjections f, HasOne f, ArithInOut.RoundedRing f, 
     ArithInOut.RoundedMixedField f Int,
     ArithInOut.RoundedReal (Domain f),
     RefOrd.IntervalLike (Domain f),
     HasEvalOps f (Domain f),
     Show (Domain f), Show f)
    =>
    RefOrd.GetEndpointsEffortIndicator (Domain f) -> 
    NumOrd.PartialCompareEffortIndicator (Domain f) -> 
    ArithInOut.RingOpsEffortIndicator f -> 
    ArithInOut.MixedFieldOpsEffortIndicator f Int -> 
    ArithInOut.RoundedRealEffortIndicator (Domain f) ->
    EvalOpsEffortIndicator f (Domain f) -> 
    f {-^ the variable @x@ to use in the result uni-variate polynomial -} ->
    Domain f {-^ @c@ the only non-smooth point of the approximated piece-wise linear function -} ->
    Domain f {-^ @d@ initial value for the offset @d@ by which to translate the approximated fn down at point c -} ->
    Int {-^ @n@ Bernstein approximation degree -} ->
    f
hillbaseApproxDn effGetE effComp effRingF effIntFldF effRealDF effEvalOps x c dInit n =
    findBelowCAtC approximations
    where
    approximations =
        let ?addInOutEffort = effAddDF in
        getApproxFrom dInit
        where
        getApproxFrom d =
            (fnAtC, fn) : getApproxFrom newD
            where
            fnAtC = evalOtherType (evalOpsOut effEvalOps sampleF sampleDF) varC fn
            fn = hillDnD d
            varC = fromAscList [(var, c)]
            (_, newD) = 
                 RefOrd.getEndpointsOutEff effGetE $
                    d <+> fnAtCMinusC <+> fnAtCMinusC 
            fnAtCMinusC = fnAtC <-> c
    findBelowCAtC ((fnAtC, fn) : rest) =
        let ?pCompareEffort = effComp in
        case (fnAtCLE <=? c) of
            Just True -> fn
            _ -> findBelowCAtC rest
        where
        (fnAtCLE,_) =
            RefOrd.getEndpointsOutEff effGetE fnAtC
    hillDnD = 
        hillbaseApproxDnD effComp effRingF effIntFldF effRealDF x c n
    
    (var:_) = getVars $ getDomainBox $ x
    sampleF = x
    sampleDF = getSampleDomValue x
    effAddDF = ArithInOut.fldEffortAdd sampleDF $ ArithInOut.rrEffortField sampleDF effRealDF

{-| 
  Compute an upper Bernstein approximation of the function @max(c-xd/c,x-(1-x)d/(1-c))@ over @[0,1]@,
  which is a valid lower approximation of @max(c,x)@ when @d@ is large enough.
-}
hillbaseApproxDnD :: 
    (HasConstFns f, HasProjections f, HasOne f, ArithInOut.RoundedRing f, 
     ArithInOut.RoundedMixedField f Int,
     ArithInOut.RoundedReal (Domain f),
     Show (Domain f), Show f)
    =>
    NumOrd.PartialCompareEffortIndicator (Domain f) -> 
    ArithInOut.RingOpsEffortIndicator f -> 
    ArithInOut.MixedFieldOpsEffortIndicator f Int -> 
    ArithInOut.RoundedRealEffortIndicator (Domain f) -> 
    f {-^ the variable @x@ to use in the result uni-variate polynomial -} ->
    Domain f {-^ @c@ the only non-smooth point of the approximated piece-wise linear function -} ->
    Int {-^ @n@ Bernstein approximation degree -} ->
    Domain f {-^ @d@ the distance of the approximated piece-wise linear function from 0 at point c -} ->
    f
hillbaseApproxDnD effComp effRingF effIntFldF effRealDF x c n d =
    let ?pCompareEffort = effComp in
    let ?addInOutEffort = effAddDF in
    let ?multInOutEffort = effMultDF in
    let ?mixedMultInOutEffort = effMultDFI in
    let ?mixedDivInOutEffort = effDivDFI in
    unsafePrint ( "hillbaseApproxDnD:"
        ++ " n = " ++ show n
        ++ " c = " ++ show c
        ++ " d = " ++ show d
    ) $
    foldl1 (ArithInOut.addOutEff effAddF) $
        map mkBT [0..n]
    where
    mkBT p =
        let ?multInOutEffort = effMultF in
        (newConstFnFromSample x fOfpOverN)
        <*> 
        (bernsteinOut (effRingF, effIntFldF) x n p)
        where
        fOfpOverN
            | (pOverN <? c) == Just True = 
                c <+> pOverN <*> minusDOverC
            | otherwise =
                (pOverN <*> onePlusDOverOneMinusC) <-> dOverOneMinusC
                -- (p/n)(1 + d/(1-c)) - d/(1-c)
        pOverN = (c1 <*>| p) </>| n
    minusDOverC = 
        let ?divInOutEffort = effDivDF in  
        neg $ d </> c
    onePlusDOverOneMinusC = 
        let ?addInOutEffort = effAddDF in  
        c1 <+> dOverOneMinusC
    dOverOneMinusC = 
        let ?addInOutEffort = effAddDF in  
        let ?divInOutEffort = effDivDF in  
        d </> (c1 <-> c)
    c1 = one sampleDF
    sampleDF = getSampleDomValue x
    
    effAddF = ArithInOut.ringEffortAdd x effRingF
    effMultF = ArithInOut.ringEffortMult x effRingF
    
    effMultDFI = ArithInOut.mxfldEffortMult sampleDF (1::Int) $ ArithInOut.rrEffortIntMixedField sampleDF effRealDF
    effDivDFI = ArithInOut.mxfldEffortDiv sampleDF (1::Int) $ ArithInOut.rrEffortIntMixedField sampleDF effRealDF

    effMultDF = ArithInOut.fldEffortMult sampleDF $ ArithInOut.rrEffortField sampleDF effRealDF
    effAddDF = ArithInOut.fldEffortAdd sampleDF $ ArithInOut.rrEffortField sampleDF effRealDF
    
    effDivDF = ArithInOut.fldEffortDiv sampleDF $ ArithInOut.rrEffortField sampleDF effRealDF


    
    

    