{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ImplicitParams #-}
{-# LANGUAGE FlexibleContexts #-}
{-|
    Module      :  Numeric.AERN.RealArithmetic.RefinementOrderRounding.Conversion
    Description :  conversion between approximations and other types  
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Conversion between approximations and other types.
    
    This module is hidden and reexported via its parent RefinementOrderRounding. 
-}
module Numeric.AERN.RealArithmetic.RefinementOrderRounding.Conversion where

import Prelude hiding (EQ, LT, GT)

import Numeric.AERN.RealArithmetic.ExactOps

import Numeric.AERN.Basics.Effort
import Numeric.AERN.Basics.PartialOrdering
import qualified Numeric.AERN.RefinementOrder as RefOrd
import qualified Numeric.AERN.NumericOrder as NumOrd
import Numeric.AERN.NumericOrder.OpsImplicitEffort

import qualified Numeric.AERN.RealArithmetic.NumericOrderRounding.Conversion as UpDnConversion

import Numeric.AERN.Misc.Bool
import Numeric.AERN.Misc.Maybe

import Data.Ratio
import Data.Maybe

import Test.QuickCheck
import Test.Framework (testGroup, Test)
import Test.Framework.Providers.QuickCheck2 (testProperty)

class
    (EffortIndicator (ConvertEffortIndicator t1 t2))
    => 
    Convertible t1 t2 
    where
    type ConvertEffortIndicator t1 t2
    convertDefaultEffort :: t1 -> t2 -> ConvertEffortIndicator t1 t2 
    convertInEff :: ConvertEffortIndicator t1 t2 -> t1 -> t2
    convertOutEff :: ConvertEffortIndicator t1 t2 -> t1 -> t2

propConvertMonotoneFromNumOrd ::
    (Convertible t1 t2, 
     NumOrd.ArbitraryOrderedTuple t1, 
     NumOrd.PartialComparison t2) 
    =>
    t1 -> t2 ->
    (ConvertEffortIndicator t1 t2, NumOrd.PartialCompareEffortIndicator t2) ->  
    NumOrd.LEPair t1 -> Bool
propConvertMonotoneFromNumOrd sample1 sample2 (effortFrom, effortComp) (NumOrd.LEPair (a, b)) = 
    (trueOrNothing $ let ?pCompareEffort = effortComp in aOut <=? bOut)
    &&
    (trueOrNothing $ let ?pCompareEffort = effortComp in aIn <=? bIn)
    where
    aOut = convertOutEff effortFrom a 
    aIn = convertInEff effortFrom a 
    bOut = convertOutEff effortFrom b 
    bIn = convertInEff effortFrom b
    _ = [sample2, aOut, aIn]

propConvertRoundTripNumOrd ::
    (UpDnConversion.Convertible t1 t2, Convertible t2 t1, 
     NumOrd.PartialComparison t1, Show t1, Show t2) 
    =>
    t1 -> t2 -> 
    (NumOrd.PartialCompareEffortIndicator t1, 
     ConvertEffortIndicator t2 t1, 
     UpDnConversion.ConvertEffortIndicator t1 t2) ->
    t1 -> Bool
propConvertRoundTripNumOrd sample1 sample2 (effortComp, effortFrom, effortTo) a =
    (defined maDn && defined maUp) ===>
    let ?pCompareEffort = effortComp in
    case (aDnOut <=? a, a <=? aUpOut) of
       (Just False, _) -> printErrorDetail
       (_, Just False) -> printErrorDetail
       _ -> True
    where
    aDnOut = convertOutEff effortFrom aDn 
    maDn = UpDnConversion.convertDnEff effortTo a
    aDn = fromJust maDn 
    aUpOut = convertOutEff effortFrom aUp
    maUp = UpDnConversion.convertUpEff effortTo a
    aUp = fromJust maUp 
    _ = [sample2, aDn, aUp]
    printErrorDetail =
        error $
           "propToFromInteger failed:"
           ++ "\n  a = " ++ show a
           ++ "\n  aDnOut = " ++ show aDnOut
           ++ "\n  aUpOut = " ++ show aUpOut


testsConvertNumOrd (name1, sample1, name2, sample2) =
    testGroup (name1 ++ " -> " ++ name2 ++  " conversions") $
        [
            testProperty "monotone" (propConvertMonotoneFromNumOrd sample1 sample2)
        ,
            testProperty "round trip" (propConvertRoundTripNumOrd sample2 sample1)
        ]

