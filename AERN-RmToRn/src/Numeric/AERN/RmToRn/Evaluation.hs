{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-|
    Module      :  Numeric.AERN.RmToRn.Evaluate
    Description :  operations focusing on function evaluation  
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Operations focusing on function evaluation.
-}

module Numeric.AERN.RmToRn.Evaluation where

import Numeric.AERN.RmToRn.Domain
import Numeric.AERN.Basics.Interval

class (HasDomainBox f) => CanEvaluateOtherType f
    where
    type EvalOps f :: * -> *
    evalOtherType :: (Show t) => (EvalOps f t) -> (VarBox f t) -> f -> t

class (CanEvaluateOtherType f) => HasEvalOps f t
    where
    type EvalOpsEffortIndicator f t
    evalOpsDefaultEffort :: f -> t -> EvalOpsEffortIndicator f t
    evalOpsOut :: EvalOpsEffortIndicator f t -> f -> t -> EvalOps f t 
    evalOpsIn :: EvalOpsEffortIndicator f t -> f -> t -> EvalOps f t 

{-
    The following are special cases of the above, which
    can sometimes be implemented more efficiently.
-}

class (HasDomainBox f) => CanEvaluate f
    where
    evalAtPointOut :: (VarBox f (Domain f)) -> f -> (Interval (Domain f))
    evalAtPointIn :: (VarBox f (Domain f)) -> f -> (Interval (Domain f))
    
class (HasDomainBox f) => CanSubstitute f
    where
    substituteOut :: (VarBox f (Domain f)) -> f -> f
    substituteIn :: (VarBox f (Domain f)) -> f -> f
    
