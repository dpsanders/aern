{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
{-|
    Module      :  Numeric.AERN.RealArithmetic.NumericOrderRounding
    Description :  common arithmetical operations rounded up/down  
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Common arithmetical operations rounded up/down.
    
    This module is meant to be imported qualified.
    It is recommended to use the prefix ArithUpDn.
-}
module Numeric.AERN.RealArithmetic.NumericOrderRounding 
(
    module Numeric.AERN.RealArithmetic.NumericOrderRounding.Conversion,
    module Numeric.AERN.RealArithmetic.NumericOrderRounding.FieldOps,
    module Numeric.AERN.RealArithmetic.NumericOrderRounding.MixedFieldOps,
    module Numeric.AERN.RealArithmetic.NumericOrderRounding.SpecialConst,
    module Numeric.AERN.RealArithmetic.NumericOrderRounding.Elementary,
    module Numeric.AERN.RealArithmetic.NumericOrderRounding.InPlace,
    RoundedReal(..), RoundedRealInPlace
)
where

import Numeric.AERN.RealArithmetic.NumericOrderRounding.Conversion
import Numeric.AERN.RealArithmetic.NumericOrderRounding.FieldOps
import Numeric.AERN.RealArithmetic.NumericOrderRounding.MixedFieldOps
import Numeric.AERN.RealArithmetic.NumericOrderRounding.SpecialConst
import Numeric.AERN.RealArithmetic.NumericOrderRounding.Elementary
import Numeric.AERN.RealArithmetic.NumericOrderRounding.InPlace

import Numeric.AERN.RealArithmetic.ExactOps
import Numeric.AERN.RealArithmetic.Measures

import Numeric.AERN.Basics.NumericOrder

import qualified Numeric.AERN.Basics.NumericOrder as NumOrd

{-|
   An aggregate class collecting together all functionality
   normally expected from up/down rounded approximations to
   real numbers such as the floating point numbers.
   
   It also provides a single aggregate effort indicator type
   from which effort indicators for all the rounded operations can
   be extracted.
-}
class 
    (HasZero t, HasOne t, HasInfinities t, Neg t,
     NumOrd.PartialComparison t, NumOrd.RoundedLattice t,
     HasDistance t,
     Convertible Int t, Convertible t Int,  
     Convertible Integer t, Convertible t Integer,  
     Convertible Double t, Convertible t Double,  
     Convertible Rational t, Convertible t Rational,  
     RoundedAbs t, 
     RoundedField t,
     RoundedMixedField t Int, 
     RoundedMixedField t Integer, 
     RoundedMixedField t Double, 
     RoundedMixedField t Rational) => 
    RoundedReal t
    where
    type RoundedRealEffortIndicator t
    roundedRealDefaultEffort :: t -> RoundedRealEffortIndicator t
    rrEffortComp :: t -> (RoundedRealEffortIndicator t) -> (NumOrd.PartialCompareEffortIndicator t)
    rrEffortMinmax :: t -> (RoundedRealEffortIndicator t) -> (NumOrd.MinmaxEffortIndicator t)
    rrEffortDistance :: t -> (RoundedRealEffortIndicator t) -> (DistanceEffortIndicator t)
    rrEffortToInt :: t -> (RoundedRealEffortIndicator t) -> (ConvertEffortIndicator t Int)
    rrEffortFromInt :: t -> (RoundedRealEffortIndicator t) -> (ConvertEffortIndicator Int t)
    rrEffortToInteger :: t -> (RoundedRealEffortIndicator t) -> (ConvertEffortIndicator t Integer)
    rrEffortFromInteger :: t -> (RoundedRealEffortIndicator t) -> (ConvertEffortIndicator Integer t)
    rrEffortToDouble :: t -> (RoundedRealEffortIndicator t) -> (ConvertEffortIndicator t Double)
    rrEffortFromDouble :: t -> (RoundedRealEffortIndicator t) -> (ConvertEffortIndicator Double t)
    rrEffortToRational :: t -> (RoundedRealEffortIndicator t) -> (ConvertEffortIndicator t Rational)
    rrEffortFromRational :: t -> (RoundedRealEffortIndicator t) -> (ConvertEffortIndicator Rational t)
    rrEffortAbs :: t -> (RoundedRealEffortIndicator t) -> (AbsEffortIndicator t)
    rrEffortField :: t -> (RoundedRealEffortIndicator t) -> (FieldOpsEffortIndicator t)
    rrEffortIntMixedField :: t -> (RoundedRealEffortIndicator t) -> (MixedFieldOpsEffortIndicator t Int)
    rrEffortIntegerMixedField :: t -> (RoundedRealEffortIndicator t) -> (MixedFieldOpsEffortIndicator t Integer)
    rrEffortDoubleMixedField :: t -> (RoundedRealEffortIndicator t) -> (MixedFieldOpsEffortIndicator t Double)
    rrEffortRationalMixedField :: t -> (RoundedRealEffortIndicator t) -> (MixedFieldOpsEffortIndicator t Rational)
     
{-|
   A mutable version of 'RoundedReal' with additional support for mutable ops.
-}
class
    (RoundedReal t,
     NegInPlace t,
     RoundedLatticeInPlace t,
     RoundedAbsInPlace t, 
     RoundedFieldInPlace t,
     RoundedMixedFieldInPlace t Int, 
     RoundedMixedFieldInPlace t Integer, 
     RoundedMixedFieldInPlace t Double, 
     RoundedMixedFieldInPlace t Rational) => 
    RoundedRealInPlace t
 
    