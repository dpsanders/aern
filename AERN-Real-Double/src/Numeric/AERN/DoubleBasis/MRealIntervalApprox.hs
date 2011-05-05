{-|
    Module      :  Numeric.AERN.DoubleBasis.MRealIntervalApprox
    Description :  Mutable Double intervals for approximating real intervals  
    Copyright   :  (c) Michal Konecny, Jan Duracz
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Mutable versions of the abstract data type 'RealIntervalApprox'
-}
module Numeric.AERN.DoubleBasis.MRealIntervalApprox
(
    -- |
    -- A convenience module re-exporting various in-place interval 
    -- operations with default effort indicators.

    -- * Main type
    MRealIntervalApprox,

    -- * Outward rounded operations

    -- | 
    -- In-place interval extensions of common functions.
    --
    -- The /first/ parameter of the in-place operations listed below
    -- is the /out/ parameter. Actual parameters are allowed to appear 
    -- both as in and out paramers as in e.g.
    --
    -- > meetOutInPlace xM xM yM
    --
    -- which is equivalent to the assignment version 
    --
    -- > xM </\>= yM

    -- ** Order operations
    
    -- *** Numerical order
    -- | 
    -- Outward rounded in-place interval extensions of the corresponding 
    -- operations on Double.
    minOutInPlace,maxOutInPlace,

    -- *** Refinement order
    -- | 
    -- Outward rounded in-place lattice operations in the interval poset.

    -- **** Operations with explicit out parameter    
    meetOutInPlace,joinOutInPlace,

    -- **** Assignment operations 

    -- ***** ASCII versions
    (</\>=),(<\/>=),

    -- ***** Unicode versions
    (<⊓>=),(<⊔>=),

    -- ** Field operations

    -- *** Interval operations

    -- **** Operations with explicit out parameter    
    addOutInPlace,subtrOutInPlace,
    multOutInPlace,divOutInPlace,
    
    -- **** Assignment operations 
    (<+>=),(<->=),(<*>=),(</>=),

    -- *** Mixed type operations

    -- **** Operations with explicit out parameter    
    mixedAddOutInPlace,mixedMultOutInPlace,mixedDivOutInPlace,
    powerToNonnegIntOutInPlace,

    -- **** Assignment operations
    (<+>|=),(<*>|=),(</>|=),(<^>=),
    
    -- ** Elementary functions
    absOutInPlace,expOutInPlace,sqrtOutInPlace,

    -- *** Elementary functions with iteration effort control
    -- |
    -- To be used eg as follows:
    -- 
    -- > expOutInPlaceIters 10 resM xM
    --
    -- which means that at most 10 iterations should be used while computing exp of x
    expOutInPlaceIters,sqrtOutInPlaceIters,
    
    -- * Inward rounded operations

    -- ** Order operations
    
    -- *** Numerical order
    -- | 
    -- Inward rounded in-place interval extensions of the corresponding 
    -- operations on Double.
    minInInPlace,maxInInPlace,

    -- *** Refinement order
    -- | 
    -- Inward rounded in-place lattice operations in the interval poset.

    -- **** Operations with explicit out parameter    
    meetInInPlace,joinInInPlace,

    -- **** Assignment operations 

    -- ***** ASCII versions
    (>/\<=),(>\/<=),

    -- ***** Unicode versions
    (>⊓<=),(>⊔<=),

    -- ** Field operations

    -- *** Interval operations

    -- **** Operations with explicit out parameter    
    addInInPlace,subtrInInPlace,
    multInInPlace,divInInPlace,

    -- **** Assignment operations 
    (>+<=),(>-<=),(>*<=),(>/<=),

    -- *** Mixed type operations

    -- **** Operations with explicit out parameter    
    mixedAddInInPlace,mixedMultInInPlace,mixedDivInInPlace,
    powerToNonnegIntInInPlace,

    -- **** Assignment operations 
    (>+<|=),(>*<|=),(>/<|=),(>^<=),
    
    -- ** Elementary functions
    absInInPlace,expInInPlace,sqrtInInPlace,
    
    -- *** Elementary functions with iteration effort control
    -- |
    -- To be used eg as follows:
    -- 
    -- > expInInPlaceIters 10 resM xM
    --
    -- which means that at most 10 iterations should be used while computing exp of x
    expInInPlaceIters,sqrtInInPlaceIters,
    
    -- * Base class and associted type
    CanBeMutable(..)
)
where

import Numeric.AERN.Basics.Mutable
  (CanBeMutable(..))

import Numeric.AERN.Basics.NumericOrder.InPlace.OpsDefaultEffort
  (minOutInPlace,maxOutInPlace,
   minInInPlace,maxInInPlace)

import Numeric.AERN.Basics.RefinementOrder.InPlace.OpsDefaultEffort
  (meetOutInPlace,(</\>=),(<⊓>=),
   joinOutInPlace,(<\/>=),(<⊔>=),
   meetInInPlace,(>/\<=),(>⊓<=),
   joinInInPlace,(>\/<=),(>⊔<=))

import Numeric.AERN.RealArithmetic.Basis.Double()
import Numeric.AERN.RealArithmetic.Interval.Mutable()
import Numeric.AERN.RealArithmetic.Interval.Mutable.ElementaryFromFieldOps()

import qualified Numeric.AERN.RealArithmetic.NumericOrderRounding as NumOrd
import Numeric.AERN.RealArithmetic.RefinementOrderRounding.InPlace.OpsDefaultEffort
  (addOutInPlace,(<+>=),
   subtrOutInPlace,(<->=),
   multOutInPlace,(<*>=),
   divOutInPlace,(</>=),
   absOutInPlace,expOutInPlace,sqrtOutInPlace,
   mixedAddOutInPlace,(<+>|=),
   mixedMultOutInPlace,(<*>|=),
   mixedDivOutInPlace,(</>|=),
   powerToNonnegIntOutInPlace,(<^>=),
   addInInPlace,(>+<=),
   subtrInInPlace,(>-<=),
   multInInPlace,(>*<=),
   divInInPlace,(>/<=),
   absInInPlace,expInInPlace,sqrtInInPlace,
   mixedAddInInPlace,(>+<|=),
   mixedMultInInPlace,(>*<|=),
   mixedDivInInPlace,(>/<|=),
   powerToNonnegIntInInPlace,(>^<=))

import Numeric.AERN.RealArithmetic.Interval.Mutable.ElementaryFromFieldOps
    (expOutInPlaceIters, expInInPlaceIters, sqrtOutInPlaceIters, sqrtInInPlaceIters)

import Numeric.AERN.DoubleBasis.RealIntervalApprox (RealIntervalApprox)
import Control.Monad.ST (runST)

-- | 
-- Mutable intervals with Double endpoints. Created and handled using
-- the methods of 'CanBeMutable' as in e.g.
-- 
-- > identity :: RealIntervalApprox -> RealIntervalApprox 
-- > identity x =
-- >   runST $
-- >     do
-- >     xM <- makeMutable x
-- >     result <- readMutable xM
-- >     return result
type MRealIntervalApprox = Mutable RealIntervalApprox
