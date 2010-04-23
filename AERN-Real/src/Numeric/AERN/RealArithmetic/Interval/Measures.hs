{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE ImplicitParams #-}
{-|
    Module      :  Numeric.AERN.RealArithmetic.Interval.Measures
    Description :  distance and imprecision for intervals
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Distance and imprecision for intervals.
    
    This module is hidden and reexported via its parent Interval. 
-}

module Numeric.AERN.RealArithmetic.Interval.Measures where

import Numeric.AERN.RealArithmetic.Measures
import Numeric.AERN.RealArithmetic.ExactOperations

import Numeric.AERN.Basics.Interval
import Numeric.AERN.Basics.Consistency

import qualified Numeric.AERN.Basics.NumericOrder as NumOrd
import qualified Numeric.AERN.Basics.RefinementOrder as RefOrd
import Numeric.AERN.Basics.RefinementOrder ((<⊓>))


instance (HasDistance e, RefOrd.OuterRoundedLattice (Distance e)) => HasDistance (Interval e) where
    type Distance (Interval e) = Distance e
    type DistanceEffortIndicator (Interval e) = 
        (DistanceEffortIndicator e, RefOrd.JoinMeetOutEffortIndicator (Distance e))
    distanceDefaultEffort (Interval l h) = 
        (effortDist, RefOrd.joinmeetOutDefaultEffort d)
        where
        effortDist = distanceDefaultEffort l 
        d = distanceBetweenEff effortDist l h
    distanceBetweenEff (effortDist, effortMeet) (Interval l1 h1) (Interval l2 h2) =
        let 
        ?joinmeetOutEffort = effortMeet
        in 
        (distanceBetweenEff effortDist l1 h2) <⊓> (distanceBetweenEff effortDist l2 h1)
    
instance 
    (HasDistance e, RefOrd.OuterRoundedLattice (Distance e), Neg (Distance e), 
     NumOrd.PartialComparison e) => 
    HasImprecision (Interval e) 
    where
    type Imprecision (Interval e) = Distance e
    type ImprecisionEffortIndicator (Interval e) = 
        (DistanceEffortIndicator e,
         RefOrd.JoinMeetOutEffortIndicator (Distance e), 
         ConsistencyEffortIndicator (Interval e))
    imprecisionDefaultEffort i@(Interval l h) = 
        (effortDist, effortMeet, consistencyDefaultEffort i) 
        where
        effortDist = distanceDefaultEffort l
        effortMeet = RefOrd.joinmeetOutDefaultEffort d
        d = distanceBetweenEff effortDist l h
    imprecisionOfEff (effortDist, effortMeet, effortConsistency) i@(Interval l h) =
        let 
        ?joinmeetOutEffort = effortMeet
        in
        case (isConsistentEff effortConsistency i) of
            Just True -> dist
            Just False -> neg dist
            Nothing -> dist <⊓> (neg dist)
        where 
        dist = distanceBetweenEff effortDist l h
    