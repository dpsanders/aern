{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}
{-|
    Module      :  Numeric.AERN.RealArithmetic.NumericOrderRounding.InPlace.FieldOps
    Description :  rounded basic arithmetic operations  
    Copyright   :  (c) Michal Konecny, Jan Duracz
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    In-place versions of rounded basic arithmetic operations.
    
    Each operations takes mutable parameters instead of pure parameters
    and has one extra mutable parameter before the other parameters, 
    in which it stores the result.
    The mutable parameters can alias arbitrarily, making it possible
    to eg add to a number overwriting the original number.
    
    The operations have as their first paramter a non-mutable sample value
    to aid type-checking, ie to help work out which type the mutable parameters
    contain.
    
    This module is hidden and reexported via its parent NumericOrderRounding.InPlace. 
-}
module Numeric.AERN.RealArithmetic.NumericOrderRounding.InPlace.FieldOps 
where

import Prelude hiding (EQ, LT, GT)
import Numeric.AERN.Basics.PartialOrdering

import Numeric.AERN.RealArithmetic.NumericOrderRounding.FieldOps

import Numeric.AERN.RealArithmetic.Auxiliary
import Numeric.AERN.RealArithmetic.ExactOps
import Numeric.AERN.RealArithmetic.NumericOrderRounding.Conversion

import Numeric.AERN.Basics.Effort
import Numeric.AERN.Basics.Exception (HasLegalValues)
import Numeric.AERN.Basics.Mutable
import Numeric.AERN.RealArithmetic.Laws
import Numeric.AERN.RealArithmetic.Measures
import qualified Numeric.AERN.NumericOrder as NumOrd

import Test.QuickCheck
import Test.Framework (testGroup, Test)
import Test.Framework.Providers.QuickCheck2 (testProperty)

import Control.Monad.ST
import Data.Maybe

class (RoundedAddEffort t, CanBeMutable t) => RoundedAddInPlace t where
    addUpInPlaceEff :: OpMutable2Eff (AddEffortIndicator t) t s
    addDnInPlaceEff :: OpMutable2Eff (AddEffortIndicator t) t s

-- | Upward rounded in-place addition with default effort
addUpInPlace :: (RoundedAddInPlace t) => OpMutable2 t s
addUpInPlace = mutable2EffToMutable2 addUpInPlaceEff addDefaultEffort

-- | Upward rounded addition assignment with default effort
(+^=) :: (RoundedAddInPlace t) => OpMutable1 t s
(+^=) = mutable2ToMutable1 addUpInPlace

-- | Downward rounded in-place addition with default effort
addDnInPlace :: (RoundedAddInPlace t) => OpMutable2 t s
addDnInPlace = mutable2EffToMutable2 addDnInPlaceEff addDefaultEffort 

-- | Downward rounded addition assignment with default effort
(+.=) :: (RoundedAddInPlace t) => OpMutable1 t s
(+.=) = mutable2ToMutable1 addDnInPlace


addUpInPlaceEffFromPure,
 addDnInPlaceEffFromPure ::
    (CanBeMutable t, RoundedAdd t) =>
    OpMutable2Eff (AddEffortIndicator t) t s 
addUpInPlaceEffFromPure = pureToMutable2Eff addUpEff 
addDnInPlaceEffFromPure = pureToMutable2Eff addDnEff

addUpInPlaceEffFromInPlace,
 addDnInPlaceEffFromInPlace :: 
    (RoundedAddInPlace t) =>
    (AddEffortIndicator t) -> t -> t -> t 
addUpInPlaceEffFromInPlace = mutable2EffToPure addUpInPlaceEff 
addDnInPlaceEffFromInPlace = mutable2EffToPure addDnInPlaceEff 

propUpDnAddInPlace ::
    (NumOrd.PartialComparison t, Neg t, 
     RoundedAddInPlace t, RoundedAdd t, 
     Show t, HasLegalValues t) 
    =>
    t ->
    (NumOrd.PartialCompareEffortIndicator t, 
     AddEffortIndicator t) -> 
    (NumOrd.UniformlyOrderedPair t) -> 
    Bool
propUpDnAddInPlace sample initEffort (NumOrd.UniformlyOrderedPair (e1, e2)) =
    equalRoundingUpDn "in-place rounded addition"
        expr1Up expr1Dn expr2Up expr2Dn 
        NumOrd.pLeqEff initEffort
    where
    addUpEffViaInPlace = mutable2EffToPure addUpInPlaceEff
    addDnEffViaInPlace = mutable2EffToPure addDnInPlaceEff
    expr1Up eff =
        let (+^) = addUpEff eff in e1 +^ e2
    expr1Dn eff =
        let (+.) = addDnEff eff in e1 +. e2
    expr2Up eff =
        let (+^) = addUpEffViaInPlace eff in e1 +^ e2
    expr2Dn eff =
        let (+.) = addDnEffViaInPlace eff in e1 +. e2

class (RoundedAddInPlace t,  NegInPlace t) => RoundedSubtrInPlace t where
    subtrUpInPlaceEff :: OpMutable2Eff (AddEffortIndicator t) t s
    subtrDnInPlaceEff :: OpMutable2Eff (AddEffortIndicator t) t s
    subtrUpInPlaceEff effort rM aM bM =
        do
        bbM <- cloneMutable bM
        negInPlace bbM bM
        addUpInPlaceEff effort rM aM bbM
    subtrDnInPlaceEff effort rM aM bM = 
        do
        bbM <- cloneMutable bM
        negInPlace bbM bM
        addDnInPlaceEff effort rM aM bbM

-- | Upward rounded in-place subtraction with default effort
subtrUpInPlace :: (RoundedSubtrInPlace t) => OpMutable2 t s
subtrUpInPlace = mutable2EffToMutable2 subtrUpInPlaceEff addDefaultEffort

-- | Upward rounded subtraction assignment with default effort
(-^=) :: (RoundedSubtrInPlace t) => OpMutable1 t s
(-^=) = mutable2ToMutable1 subtrUpInPlace

-- | Downward rounded in-place subtraction with default effort
subtrDnInPlace :: (RoundedSubtrInPlace t) => OpMutable2 t s
subtrDnInPlace = mutable2EffToMutable2 subtrDnInPlaceEff addDefaultEffort

-- | Downward rounded subtraction assignment with default effort
(-.=) :: (RoundedSubtrInPlace t) => OpMutable1 t s
(-.=) = mutable2ToMutable1 subtrDnInPlace

propUpDnSubtrInPlace ::
    (NumOrd.PartialComparison t, 
     RoundedSubtrInPlace t, RoundedSubtr t, 
     Neg t,
     Show t, HasLegalValues t) 
    =>
    t ->
    (NumOrd.PartialCompareEffortIndicator t, 
     AddEffortIndicator t) -> 
    (NumOrd.UniformlyOrderedPair t) ->
    Bool
propUpDnSubtrInPlace sample initEffort (NumOrd.UniformlyOrderedPair (e1, e2)) =
    equalRoundingUpDn "in-place rounded subtraction"
        expr1Up expr1Dn expr2Up expr2Dn 
        NumOrd.pLeqEff initEffort
    where
    subtrUpEffViaInPlace = mutable2EffToPure subtrUpInPlaceEff
    subtrDnEffViaInPlace = mutable2EffToPure subtrDnInPlaceEff
    expr1Up eff =
        let (-^) = subtrUpEff eff in e1 -^ e2
    expr1Dn eff =
        let (-.) = subtrDnEff eff in e1 -. e2
    expr2Up eff =
        let (-^) = subtrUpEffViaInPlace eff in e1 -^ e2
    expr2Dn eff =
        let (-.) = subtrDnEffViaInPlace eff in e1 -. e2


class (RoundedAbsEffort t, CanBeMutable t) => RoundedAbsInPlace t where
    absUpInPlaceEff :: OpMutable1Eff (AbsEffortIndicator t) t s
    absDnInPlaceEff :: OpMutable1Eff (AbsEffortIndicator t) t s

-- | Upward rounded in-place absolute value with default effort
absUpInPlace :: (RoundedAbsInPlace t) => OpMutable1 t s
absUpInPlace = mutable1EffToMutable1 absUpInPlaceEff absDefaultEffort 

-- | Downward rounded in-place absolute value with default effort
absDnInPlace :: (RoundedAbsInPlace t) => OpMutable1 t s
absDnInPlace = mutable1EffToMutable1 absDnInPlaceEff absDefaultEffort 

absUpInPlaceEffFromPure,
 absDnInPlaceEffFromPure ::
    (CanBeMutable t, RoundedAbs t) =>
    OpMutable1Eff (AbsEffortIndicator t) t s
absUpInPlaceEffFromPure = pureToMutable1Eff absUpEff 
absDnInPlaceEffFromPure = pureToMutable1Eff absDnEff 

absUpInPlaceEffFromInPlace,
 absDnInPlaceEffFromInPlace ::
    (RoundedAbsInPlace t) =>
    (AbsEffortIndicator t) -> t -> t
absUpInPlaceEffFromInPlace = mutable1EffToPure absUpInPlaceEff 
absDnInPlaceEffFromInPlace = mutable1EffToPure absDnInPlaceEff 

propUpDnAbsInPlace ::
    (NumOrd.PartialComparison t, 
     RoundedAbsInPlace t, RoundedAbs t,
     Neg t,
     Show t, HasLegalValues t) 
    =>
    t ->
    (NumOrd.PartialCompareEffortIndicator t, 
     AbsEffortIndicator t) -> 
    (NumOrd.UniformlyOrderedSingleton t) -> 
    Bool
propUpDnAbsInPlace sample initEffort (NumOrd.UniformlyOrderedSingleton e1) =
    equalRoundingUpDn "in-place rounded abs"
        expr1Up expr1Dn expr2Up expr2Dn 
        NumOrd.pLeqEff initEffort
    where
    absUpEffViaInPlace = mutable1EffToPure absUpInPlaceEff
    absDnEffViaInPlace = mutable1EffToPure absDnInPlaceEff
    expr1Up eff = absUpEff eff e1
    expr1Dn eff = absDnEff eff e1
    expr2Up eff = absUpEffViaInPlace eff e1
    expr2Dn eff = absDnEffViaInPlace eff e1

class (RoundedMultiplyEffort t, CanBeMutable t) => RoundedMultiplyInPlace t where
    multUpInPlaceEff :: OpMutable2Eff (MultEffortIndicator t) t s
    multDnInPlaceEff :: OpMutable2Eff (MultEffortIndicator t) t s

-- | Upward rounded in-place multiplication with default effort
multUpInPlace :: (RoundedMultiplyInPlace t) => OpMutable2 t s
multUpInPlace = mutable2EffToMutable2 multUpInPlaceEff multDefaultEffort

-- | Upward rounded multiplication assignment with default effort
(*^=) :: (RoundedMultiplyInPlace t) => OpMutable1 t s
(*^=) = mutable2ToMutable1 multUpInPlace

-- | Downward rounded in-place multiplication with default effort
multDnInPlace :: (RoundedMultiplyInPlace t) => OpMutable2 t s
multDnInPlace = mutable2EffToMutable2 multDnInPlaceEff multDefaultEffort

-- | Downward rounded multiplication assignment with default effort
(*.=) :: (RoundedMultiplyInPlace t) => OpMutable1 t s
(*.=) = mutable2ToMutable1 multDnInPlace

multUpInPlaceEffFromPure,
 multDnInPlaceEffFromPure ::
    (CanBeMutable t, RoundedMultiply t) =>
    OpMutable2Eff (MultEffortIndicator t) t s
multUpInPlaceEffFromPure = pureToMutable2Eff multUpEff 
multDnInPlaceEffFromPure = pureToMutable2Eff multDnEff 

multUpInPlaceEffFromInPlace,
 multDnInPlaceEffFromInPlace ::
    (RoundedMultiplyInPlace t) =>
    (MultEffortIndicator t) -> t -> t -> t
multUpInPlaceEffFromInPlace = mutable2EffToPure multUpInPlaceEff 
multDnInPlaceEffFromInPlace = mutable2EffToPure multDnInPlaceEff 

propUpDnMultInPlace ::
    (NumOrd.PartialComparison t, 
     RoundedMultiplyInPlace t, RoundedMultiply t,
     Neg t,
     Show t, HasLegalValues t) 
    =>
    t ->
    (NumOrd.PartialCompareEffortIndicator t, 
     MultEffortIndicator t) -> 
    (NumOrd.UniformlyOrderedPair t) ->
    Bool
propUpDnMultInPlace sample initEffort (NumOrd.UniformlyOrderedPair (e1, e2)) =
    equalRoundingUpDn "in-place rounded multiplication"
        expr1Up expr1Dn expr2Up expr2Dn 
        NumOrd.pLeqEff initEffort
    where
    multUpEffViaInPlace = mutable2EffToPure multUpInPlaceEff
    multDnEffViaInPlace = mutable2EffToPure multDnInPlaceEff
    expr1Up eff =
        let (*^) = multUpEff eff in e1 *^ e2
    expr1Dn eff =
        let (*.) = multDnEff eff in e1 *. e2
    expr2Up eff =
        let (*^) = multUpEffViaInPlace eff in e1 *^ e2
    expr2Dn eff =
        let (*.) = multDnEffViaInPlace eff in e1 *. e2

class (RoundedPowerNonnegToNonnegIntEffort t, CanBeMutable t) => 
        RoundedPowerNonnegToNonnegIntInPlace t
    where
    powerNonnegToNonnegIntUpInPlaceEff ::
        OpMutableNonmutEff (PowerNonnegToNonnegIntEffortIndicator t) t Int s
    powerNonnegToNonnegIntDnInPlaceEff ::
        OpMutableNonmutEff (PowerNonnegToNonnegIntEffortIndicator t) t Int s
    -- default implementations, do not use these if the RoundedPowerNonnegToNonnegInt
    -- instance uses the ...fromMult implementation; 
    -- in such cases override this implementation with the ...fromMult implementation below
    -- for improved efficiency


powerNonnegToNonnegIntUpInPlaceEffFromPure,
 powerNonnegToNonnegIntDnInPlaceEffFromPure ::
    (CanBeMutable t, RoundedPowerNonnegToNonnegInt t) =>
    OpMutableNonmutEff (PowerNonnegToNonnegIntEffortIndicator t) t Int s
powerNonnegToNonnegIntUpInPlaceEffFromPure =
    pureToMutableNonmutEff powerNonnegToNonnegIntUpEff 
powerNonnegToNonnegIntDnInPlaceEffFromPure =
    pureToMutableNonmutEff powerNonnegToNonnegIntDnEff 

powerNonnegToNonnegIntUpInPlaceEffFromInPlace,
 powerNonnegToNonnegIntDnInPlaceEffFromInPlace ::
    (RoundedPowerNonnegToNonnegIntInPlace t) =>
    (PowerNonnegToNonnegIntEffortIndicator t) -> t -> Int -> t
powerNonnegToNonnegIntUpInPlaceEffFromInPlace = 
    mutableNonmutEffToPure powerNonnegToNonnegIntUpInPlaceEff 
powerNonnegToNonnegIntDnInPlaceEffFromInPlace = 
    mutableNonmutEffToPure powerNonnegToNonnegIntDnInPlaceEff

powerNonnegToNonnegIntUpInPlaceEffFromMult ::
    (RoundedMultiplyInPlace t, HasOne t) =>
    OpMutableNonmutEff (PowerNonnegToNonnegIntEffortIndicatorFromMult t) t Int s 
powerNonnegToNonnegIntUpInPlaceEffFromMult effMult rM eM n =
    powerFromMultInPlace (multUpInPlaceEff effMult) rM eM n

powerNonnegToNonnegIntDnInPlaceEffFromMult ::
    (RoundedMultiplyInPlace t, HasOne t) =>
    OpMutableNonmutEff (PowerNonnegToNonnegIntEffortIndicatorFromMult t) t Int s 
powerNonnegToNonnegIntDnInPlaceEffFromMult effMult rM eM n =
    powerFromMultInPlace (multDnInPlaceEff effMult) rM eM n


class (RoundedPowerToNonnegIntEffort t, CanBeMutable t) => 
    RoundedPowerToNonnegIntInPlace t 
    where
    powerToNonnegIntUpInPlaceEff ::
        OpMutableNonmutEff (PowerToNonnegIntEffortIndicator t) t Int s
    powerToNonnegIntDnInPlaceEff ::
        OpMutableNonmutEff (PowerToNonnegIntEffortIndicator t) t Int s

-- | Upward rounded in-place power with default effort
powerToNonnegIntUpInPlace :: (RoundedPowerToNonnegIntInPlace t) => 
    OpMutableNonmut t Int s
powerToNonnegIntUpInPlace = 
    mutableNonmutEffToMutableNonmut powerToNonnegIntUpInPlaceEff powerToNonnegIntDefaultEffort

-- | Upward rounded in-place power assignment with default effort
(^^=) :: (RoundedPowerToNonnegIntInPlace t) => OpNonmut t Int s
(^^=) = mutableNonmutToNonmut powerToNonnegIntUpInPlace

-- | Downward rounded in-place power with default effort
powerToNonnegIntDnInPlace :: (RoundedPowerToNonnegIntInPlace t) => 
    OpMutableNonmut t Int s
powerToNonnegIntDnInPlace = 
    mutableNonmutEffToMutableNonmut powerToNonnegIntDnInPlaceEff powerToNonnegIntDefaultEffort

-- | Upward rounded in-place power assignment with default effort
(^.=) :: (RoundedPowerToNonnegIntInPlace t) => OpNonmut t Int s
(^.=) = mutableNonmutToNonmut powerToNonnegIntDnInPlace


powerToNonnegIntUpInPlaceEffFromPure,
 powerToNonnegIntDnInPlaceEffFromPure ::
    (CanBeMutable t, RoundedPowerToNonnegInt t) =>
    OpMutableNonmutEff (PowerToNonnegIntEffortIndicator t) t Int s
powerToNonnegIntUpInPlaceEffFromPure =
    pureToMutableNonmutEff powerToNonnegIntUpEff 
powerToNonnegIntDnInPlaceEffFromPure =
    pureToMutableNonmutEff powerToNonnegIntDnEff 

powerToNonnegIntUpInPlaceEffFromInPlace,
 powerToNonnegIntDnInPlaceEffFromInPlace ::
    (RoundedPowerToNonnegIntInPlace t) =>
    (PowerToNonnegIntEffortIndicator t) -> t -> Int -> t
powerToNonnegIntUpInPlaceEffFromInPlace = 
    mutableNonmutEffToPure powerToNonnegIntUpInPlaceEff 
powerToNonnegIntDnInPlaceEffFromInPlace = 
    mutableNonmutEffToPure powerToNonnegIntDnInPlaceEff

propUpDnPowerToNonnegInPlace ::
    (NumOrd.PartialComparison t, 
     RoundedPowerToNonnegIntInPlace t, 
     RoundedPowerToNonnegInt t, 
     Neg t,
     Show t, HasLegalValues t) 
    =>
    t ->
    (NumOrd.PartialCompareEffortIndicator t, 
     PowerToNonnegIntEffortIndicator t) -> 
    (NumOrd.UniformlyOrderedSingleton t) -> 
    Int -> Bool
propUpDnPowerToNonnegInPlace sample initEffort 
        (NumOrd.UniformlyOrderedSingleton e1) n =
    equalRoundingUpDn "in-place rounded non-neg integer power"
        expr1Up expr1Dn expr2Up expr2Dn 
        NumOrd.pLeqEff initEffort
    where
    powerToNonnegIntUpEffViaInPlace = 
        mutableNonmutEffToPure powerToNonnegIntUpInPlaceEff
    powerToNonnegIntDnEffViaInPlace = 
        mutableNonmutEffToPure powerToNonnegIntDnInPlaceEff
    expr1Up eff =
        let (^^) = powerToNonnegIntUpEff eff in e1 ^^ n
    expr1Dn eff =
        let (^.) = powerToNonnegIntDnEff eff in e1 ^. n
    expr2Up eff =
        let (^^) = powerToNonnegIntUpEffViaInPlace eff in e1 ^^ n
    expr2Dn eff =
        let (^.) = powerToNonnegIntDnEffViaInPlace eff in e1 ^. n

class (HasOne t, RoundedDivideEffort t, CanBeMutable t) => 
    RoundedDivideInPlace t
    where
    divUpInPlaceEff :: OpMutable2Eff (DivEffortIndicator t) t s
    divDnInPlaceEff :: OpMutable2Eff (DivEffortIndicator t) t s
    recipUpInPlaceEff :: OpMutable1Eff (DivEffortIndicator t) t s
    recipDnInPlaceEff :: OpMutable1Eff (DivEffortIndicator t) t s

    recipUpInPlaceEff effort resM aM =
        do
        a <- unsafeReadMutable aM
        oneM <- unsafeMakeMutable (one a)
        divUpInPlaceEff effort resM oneM aM
    recipDnInPlaceEff effort resM aM =
        do
        a <- unsafeReadMutable aM
        oneM <- unsafeMakeMutable (one a)
        divDnInPlaceEff effort resM oneM aM

-- | Upward rounded in-place division with default effort
divUpInPlace :: (RoundedDivideInPlace t) => OpMutable2 t s
divUpInPlace = mutable2EffToMutable2 divUpInPlaceEff divDefaultEffort

-- | Upward rounded division assignment with default effort
(/^=) :: (RoundedDivideInPlace t) => OpMutable1 t s
(/^=) = mutable2ToMutable1 divUpInPlace

-- | Downward rounded in-place division with default effort
divDnInPlace :: (RoundedDivideInPlace t) => OpMutable2 t s
divDnInPlace = mutable2EffToMutable2 divDnInPlaceEff divDefaultEffort

-- | Downward rounded division assignment with default effort
(/.=) :: (RoundedDivideInPlace t) => OpMutable1 t s
(/.=) = mutable2ToMutable1 divDnInPlace

-- | Upward rounded in-place reciprocal with default effort
recipUpInPlace :: (RoundedDivideInPlace t) => OpMutable1 t s
recipUpInPlace = mutable1EffToMutable1 recipUpInPlaceEff divDefaultEffort

-- | Downward rounded in-place reciprocal with default effort
recipDnInPlace :: (RoundedDivideInPlace t) => OpMutable1 t s
recipDnInPlace = mutable1EffToMutable1 recipDnInPlaceEff divDefaultEffort



divUpInPlaceEffFromPure,
 divDnInPlaceEffFromPure ::
    (CanBeMutable t, RoundedDivide t) =>
    OpMutable2Eff (DivEffortIndicator t) t s
divUpInPlaceEffFromPure = pureToMutable2Eff divUpEff 
divDnInPlaceEffFromPure = pureToMutable2Eff divDnEff 

divUpInPlaceEffFromInPlace,
 divDnInPlaceEffFromInPlace ::
    (RoundedDivideInPlace t) =>
    (DivEffortIndicator t) -> t -> t -> t
divUpInPlaceEffFromInPlace = mutable2EffToPure divUpInPlaceEff 
divDnInPlaceEffFromInPlace = mutable2EffToPure divDnInPlaceEff 

recipUpInPlaceEffFromPure,
 recipDnInPlaceEffFromPure ::
    (CanBeMutable t, RoundedDivide t) =>
    OpMutable1Eff (DivEffortIndicator t) t s
recipUpInPlaceEffFromPure = pureToMutable1Eff recipUpEff 
recipDnInPlaceEffFromPure = pureToMutable1Eff recipDnEff 

recipUpInPlaceEffFromInPlace,
 recipDnInPlaceEffFromInPlace ::
    (RoundedDivideInPlace t) =>
    (DivEffortIndicator t) -> t -> t
recipUpInPlaceEffFromInPlace = mutable1EffToPure recipUpInPlaceEff 
recipDnInPlaceEffFromInPlace = mutable1EffToPure recipDnInPlaceEff 

propUpDnDivInPlace ::
    (NumOrd.PartialComparison t, 
     RoundedDivideInPlace t, RoundedDivide t,
     Neg t,
     Show t, HasZero t, HasLegalValues t) 
    =>
    t ->
    (NumOrd.PartialCompareEffortIndicator t, 
     DivEffortIndicator t) -> 
    (NumOrd.UniformlyOrderedPair t) ->
    Bool
propUpDnDivInPlace sample initEffort@(effComp, _) (NumOrd.UniformlyOrderedPair (e1, e2)) =
    equalRoundingUpDn "in-place rounded division"
        expr1Up expr1Dn expr2Up expr2Dn 
        NumOrd.pLeqEff initEffort
    where
    divUpEffViaInPlace = mutable2EffToPure divUpInPlaceEff
    divDnEffViaInPlace = mutable2EffToPure divDnInPlaceEff
    expr1Up eff =
        let (/^) = divUpEff eff in e1 /^ e2
    expr1Dn eff =
        let (/.) = divDnEff eff in e1 /. e2
    expr2Up eff =
        let (/^) = divUpEffViaInPlace eff in e1 /^ e2
    expr2Dn eff =
        let (/.) = divDnEffViaInPlace eff in e1 /. e2

testsUpDnFieldOpsInPlace (name, sample) =
    testGroup (name ++ " in-place up/down rounded ops match pure ops") $
        [
            testProperty "addition" (propUpDnAddInPlace sample)
        ,
            testProperty "subtraction" (propUpDnSubtrInPlace sample)
        ,
            testProperty "absolute value" (propUpDnAbsInPlace sample)
        ,
            testProperty "multiplication" (propUpDnMultInPlace sample)
        ,
            testProperty "integer power" (propUpDnMultInPlace sample)
        ,
            testProperty "division" (propUpDnDivInPlace sample)
        ]
        

class 
    (RoundedSubtrInPlace t, 
     RoundedMultiplyInPlace t,
     RoundedPowerNonnegToNonnegIntInPlace t,
     RoundedRingEffort t) 
    => 
    RoundedRingInPlace t
    
class
    (RoundedRingInPlace t, 
     RoundedDivideInPlace t,
     RoundedFieldEffort t) 
    => 
    RoundedFieldInPlace t

    