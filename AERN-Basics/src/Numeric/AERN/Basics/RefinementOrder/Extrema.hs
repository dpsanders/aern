{-|
    Module      :  Numeric.AERN.Basics.RefinementOrder.Extrema
    Description :  types that have top and bottom  
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
-}
module Numeric.AERN.Basics.RefinementOrder.Extrema where

{-|
    A type with extrema.
-}
class (HasTop t, HasBottom t) => HasExtrema t

{-|
    A type with a top element.
-}
class HasTop t where
    top :: t

{-|
    A type with a top element.
-}
class HasBottom t where
    bottom :: t
    
(⊤) :: (HasTop t) => t   
(⊤) = top
(⊥) :: (HasBottom t) => t   
(⊥) = bottom