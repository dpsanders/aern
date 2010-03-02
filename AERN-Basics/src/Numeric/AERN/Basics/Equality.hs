{-|
    Module      :  Numeric.AERN.Basics.Equality
    Description :  properties of (semidecidable) equality 
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
-}
module Numeric.AERN.Basics.Equality where

import Numeric.AERN.Basics.Effort
import Numeric.AERN.Basics.Laws.Relation
import Numeric.AERN.Basics.Laws.SemidecidableRelation

propEqReflexive :: (Eq t) => t -> Bool
propEqReflexive = reflexive (==)

propEqSymmetric :: (Eq t) => t -> t -> Bool
propEqSymmetric = symmetric (==)

propEqTransitive :: (Eq t) => t -> t -> t -> Bool
propEqTransitive = transitive (==)

{-|
    A type with semi-decidable equality
-}
class SemidecidableEq t where
    maybeEqual :: [EffortIndicator] -> t -> t -> Maybe Bool
    maybeEqualDefaultEffort :: t -> [EffortIndicator]
    (==?) :: t -> t -> Maybe Bool
    a ==? b = maybeEqual (maybeEqualDefaultEffort a) a b

propSemidecidableEqReflexive :: (SemidecidableEq t) => t -> Bool
propSemidecidableEqReflexive = semidecidableReflexive (==?)

propSemidecidableEqSymmetric :: (SemidecidableEq t) => t -> t -> Bool
propSemidecidableEqSymmetric = semidecidableSymmetric (==?)

propSemidecidableEqTransitive :: (SemidecidableEq t) => t -> t -> t -> Bool
propSemidecidableEqTransitive = semidecidableTransitive (==?)
