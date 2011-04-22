{-|
    Module      :  Numeric.AERN.Basics.NumericOrder.InPlace.OpsDefaultEffort
    Description :  convenience directed-rounded in-place lattice operations with default effort parameters  
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Convenience directed-rounded in-place lattice operations with default effort parameters.
-}

module Numeric.AERN.Basics.NumericOrder.InPlace.OpsDefaultEffort where

import Numeric.AERN.Basics.Mutable
import Numeric.AERN.Basics.NumericOrder


minDnInPlace :: (CanBeMutable t, RoundedLattice t) => OpMutable2 t s
minDnInPlace = pureEffToMutable2 minDnEff minmaxDefaultEffort

minUpInPlace :: (CanBeMutable t, RoundedLattice t) => OpMutable2 t s
minUpInPlace = pureEffToMutable2 minUpEff minmaxDefaultEffort

maxDnInPlace :: (CanBeMutable t, RoundedLattice t) => OpMutable2 t s
maxDnInPlace = pureEffToMutable2 maxDnEff minmaxDefaultEffort

maxUpInPlace :: (CanBeMutable t, RoundedLattice t) => OpMutable2 t s
maxUpInPlace = pureEffToMutable2 maxUpEff minmaxDefaultEffort

-- | Outward rounded in-place minimum
minOutInPlace :: (CanBeMutable t, OuterRoundedLattice t) => OpMutable2 t s
minOutInPlace = pureEffToMutable2 minOuterEff minmaxOuterDefaultEffort

-- | Outward rounded in-place maximum
maxOutInPlace :: (CanBeMutable t, OuterRoundedLattice t) => OpMutable2 t s
maxOutInPlace = pureEffToMutable2 maxOuterEff minmaxOuterDefaultEffort

-- | Inward rounded in-place minimum
minInInPlace :: (CanBeMutable t, InnerRoundedLattice t) => OpMutable2 t s
minInInPlace = pureEffToMutable2 minInnerEff minmaxInnerDefaultEffort

-- | Outward rounded in-place maximum
maxInInPlace :: (CanBeMutable t, InnerRoundedLattice t) => OpMutable2 t s
maxInInPlace = pureEffToMutable2 maxInnerEff minmaxInnerDefaultEffort

