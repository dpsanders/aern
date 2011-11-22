{-|
    Module      :  Numeric.AERN.NumericOrder.OpsDefaultEffort
    Description :  convenience binary infix operators with default effort parameters  
    Copyright   :  (c) Michal Konecny, Jan Duracz
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Convenience binary infix operators with default effort parameters.
-}

module Numeric.AERN.NumericOrder.OpsDefaultEffort where

import Numeric.AERN.NumericOrder

-- | Partial equality
infix 4 ==?, <==>?, </=>?, <?, <=?, >=?, >?

(==?) :: (PartialComparison t) => t -> t -> Maybe Bool
(==?) a = pEqualEff (pCompareDefaultEffort a) a

-- | Partial `is comparable to`
(<==>?) :: (PartialComparison t) => t -> t -> Maybe Bool
(<==>?) a = pComparableEff (pCompareDefaultEffort a) a

-- | Partial `is not comparable to`
(</=>?) :: (PartialComparison t) => t -> t -> Maybe Bool
(</=>?) a = pIncomparableEff (pCompareDefaultEffort a) a

-- | Partial `strictly less than`
(<?) :: (PartialComparison t) => t -> t -> Maybe Bool
(<?) a = pLessEff (pCompareDefaultEffort a) a

-- | Partial `less than or equal to`
(<=?) :: (PartialComparison t) => t -> t -> Maybe Bool
(<=?) a = pLeqEff (pCompareDefaultEffort a) a

-- | Partial `greater than or equal to`
(>=?) :: (PartialComparison t) => t -> t -> Maybe Bool
(>=?) a = pGeqEff (pCompareDefaultEffort a) a

-- | Partial `strictly greater than`
(>?) :: (PartialComparison t) => t -> t -> Maybe Bool
(>?) a = pGreaterEff (pCompareDefaultEffort a) a

-- | Downward rounded minimum
minDn :: (RoundedLattice t) => t -> t -> t
minDn a = minDnEff (minmaxDefaultEffort a) a

-- | Upward rounded minimum
minUp :: (RoundedLattice t) => t -> t -> t
minUp a = minUpEff (minmaxDefaultEffort a) a

-- | Downward rounded maximum
maxDn :: (RoundedLattice t) => t -> t -> t
maxDn a = maxDnEff (minmaxDefaultEffort a) a

-- | Upward rounded maximum
maxUp :: (RoundedLattice t) => t -> t -> t
maxUp a = maxUpEff (minmaxDefaultEffort a) a

-- | Outward rounded minimum
minOut :: (RefinementRoundedLattice t) => t -> t -> t
minOut a = minOutEff (minmaxInOutDefaultEffort a) a

-- | Outward rounded maximum
maxOut :: (RefinementRoundedLattice t) => t -> t -> t
maxOut a = maxOutEff (minmaxInOutDefaultEffort a) a

-- | Inward rounded minimum
minIn :: (RefinementRoundedLattice t) => t -> t -> t
minIn a = minInEff (minmaxInOutDefaultEffort a) a

-- | Inward rounded maximum
maxIn :: (RefinementRoundedLattice t) => t -> t -> t
maxIn a = maxInEff (minmaxInOutDefaultEffort a) a


