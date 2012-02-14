{-# LANGUAGE CPP #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ImplicitParams #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-|
    Module      :  Numeric.AERN.RealArithmetic.Interval.Conversion
    Description :  conversions between intervals and standard numeric types
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Conversion between intervals and standard numeric types.
    
    This module is hidden and reexported via its parent Interval. 
-}

module Numeric.AERN.RealArithmetic.Interval.Conversion 
()
where

import Numeric.AERN.RealArithmetic.RefinementOrderRounding

import qualified Numeric.AERN.RealArithmetic.NumericOrderRounding as ArithUpDn

import Numeric.AERN.Basics.Exception
import Numeric.AERN.Basics.Interval

import Control.Exception

instance (ArithUpDn.Convertible t e, Show t) => Convertible t (Interval e) where
    type ConvertEffortIndicator t (Interval e) = 
        ArithUpDn.ConvertEffortIndicator t e
    convertDefaultEffort i (Interval l r) = ArithUpDn.convertDefaultEffort i l 
    convertInEff effort x =
        Interval xUp xDn
        where
        xUp = convertUpEffException effort x
        xDn = convertDnEffException effort x
    convertOutEff effort x =
        Interval xDn xUp
        where
        xUp = convertUpEffException effort x
        xDn = convertDnEffException effort x

convertUpEffException effort x =
    case ArithUpDn.convertUpEff effort x of
       Just xUp -> xUp
       _ -> throw $ AERNException $
                "failed to convert to interval: x = " ++ show x
    
convertDnEffException effort x =
    case ArithUpDn.convertDnEff effort x of
       Just xDn -> xDn
       _ -> throw $ AERNException $
                "failed to convert to interval: x = " ++ show x
           
instance (ArithUpDn.Convertible e t) => 
        ArithUpDn.Convertible (Interval e) t where
#if (__GLASGOW_HASKELL__ >= 704)
    type ConvertEffortIndicator (Interval e) t = 
        ArithUpDn.ConvertEffortIndicator e t
#else
    type ArithUpDn.ConvertEffortIndicator (Interval e) t = 
        ArithUpDn.ConvertEffortIndicator e t
#endif
    convertDefaultEffort (Interval l r) i = ArithUpDn.convertDefaultEffort l i 
    convertUpEff effort (Interval l r) = ArithUpDn.convertUpEff effort r
    convertDnEff effort (Interval l r) = ArithUpDn.convertDnEff effort l

