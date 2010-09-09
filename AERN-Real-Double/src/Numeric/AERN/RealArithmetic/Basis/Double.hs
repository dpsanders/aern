{-# LANGUAGE TypeFamilies #-}
{-|
    Module      :  Numeric.AERN.RealArithmetic.Basis.Double
    Description :  Instances for Double as interval endpoints.  
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable (indirect FFI)
    
    Instances of Double required for serving as interval endpoints,
    namely providing granularity, Comparison, lattice, rounded field and 
    rounded elementary operations.
-}
module Numeric.AERN.RealArithmetic.Basis.Double 
(
   module Numeric.AERN.RealArithmetic.Basis.Double.ShowInternals,
   module Numeric.AERN.RealArithmetic.Basis.Double.NumericOrder,
   module Numeric.AERN.RealArithmetic.Basis.Double.Conversion,
   module Numeric.AERN.RealArithmetic.Basis.Double.FieldOps,
   module Numeric.AERN.RealArithmetic.Basis.Double.MixedFieldOps,
   module Numeric.AERN.RealArithmetic.Basis.Double.Measures,
   module Numeric.AERN.RealArithmetic.Basis.Double.Mutable
)
where

import Numeric.AERN.RealArithmetic.Basis.Double.ShowInternals
import Numeric.AERN.RealArithmetic.Basis.Double.NumericOrder
import Numeric.AERN.RealArithmetic.Basis.Double.Conversion
import Numeric.AERN.RealArithmetic.Basis.Double.FieldOps
import Numeric.AERN.RealArithmetic.Basis.Double.MixedFieldOps
import Numeric.AERN.RealArithmetic.Basis.Double.Measures
import Numeric.AERN.RealArithmetic.Basis.Double.Mutable

import Numeric.AERN.RealArithmetic.NumericOrderRounding

instance RoundedReal Double where
    type RoundedRealEffortIndicator Double = ()
    roundedRealDefaultEffort _ = ()
    rrEffortComp _ _ = ()
    rrEffortMinmax _ _ = ()
    rrEffortToInt _ _ = ()
    rrEffortFromInt _ _ = ()
    rrEffortToInteger _ _ = ()
    rrEffortFromInteger _ _ = ()
    rrEffortToDouble _ _ = () 
    rrEffortFromDouble _ _ = ()
    rrEffortToRational _ _ = ()
    rrEffortFromRational _ _ = ()
    rrEffortAbs _ _ = ()
    rrEffortField _ _ = ()
    rrEffortIntMixedField _ _ = ()
    rrEffortIntegerMixedField _ _ = ()
    rrEffortDoubleMixedField _ _ = ()
    rrEffortRationalMixedField _ _ = ()
    
instance RoundedRealInPlace Double
