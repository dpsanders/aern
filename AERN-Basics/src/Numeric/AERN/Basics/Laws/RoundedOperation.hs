{-|
    Module      :  Numeric.AERN.Basics.Laws.Relation
    Description :  common properties of rounded binary operations 
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Common properties of rounded binary operations.
-}

module Numeric.AERN.Basics.Laws.RoundedOperation where

import Numeric.AERN.Basics.Laws.Utilities

roundedIdempotent :: (Rel t) -> (Op t) -> (Op t) -> t -> Bool
roundedIdempotent =
    equalRoundingUpDn11 (\(*) e -> e) (\(*) e -> e * e)  

roundedCommutative :: (Rel t) -> (Op t) -> (Op t) -> t -> t -> Bool
roundedCommutative = 
    equalRoundingUpDn12 (\(*) e1 e2 -> e1 * e2) (\(*) e1 e2 -> e2 * e1)  


roundedAssociative :: (Rel t) -> (Op t) -> (Op t) -> t -> t -> t -> Bool
roundedAssociative = 
    equalRoundingUpDn13 
        (\(*) e1 e2 e3 -> (e1 * e2) * e3) 
        (\(*) e1 e2 e3 -> e1 * (e2 * e3))  

roundedModular :: 
    (Rel t) -> (Op t) -> (Op t) -> (Op t) -> (Op t) -> t -> t -> t -> Bool
roundedModular = 
    equalRoundingUpDn23 
        (\(/\) (\/) e1 e2 e3 -> (e1 /\ e3) \/ (e2 /\ e3)) 
        (\(/\) (\/) e1 e2 e3 -> ((e1 /\ e3) \/ e2) /\ e3)  

roundedLeftDistributive :: 
    (Rel t) -> (Op t) -> (Op t) -> (Op t) -> (Op t) -> t -> t -> t -> Bool
roundedLeftDistributive = 
    equalRoundingUpDn23 
        (\(/\) (\/) e1 e2 e3 -> e1 \/ (e2 /\ e3)) 
        (\(/\) (\/) e1 e2 e3 -> (e1 \/ e2) /\ (e1 \/ e3))     

equalRoundingUpDn11 :: (Expr1Op1 t) -> (Expr1Op1 t) -> (Rel t) -> (Op t) -> (Op t) -> t -> Bool
equalRoundingUpDn11 expr1 expr2  (<=) (*^) (*.) e =
    (expr1 (*.) e <= (expr2 (*^) e))
    &&
    (expr2 (*.) e <= (expr1 (*^) e))
    
equalRoundingUpDn12 :: (Expr1Op2 t) -> (Expr1Op2 t) -> (Rel t) -> (Op t) -> (Op t) -> t -> t -> Bool
equalRoundingUpDn12 expr1 expr2  (<=) (*^) (*.) e1 e2 =
    (expr1 (*.) e1 e2 <= (expr2 (*^) e1 e2))
    &&
    (expr2 (*.) e1 e2 <= (expr1 (*^) e1 e2))
    
equalRoundingUpDn13 :: (Expr1Op3 t) -> (Expr1Op3 t) -> (Rel t) -> (Op t) -> (Op t) -> t -> t -> t -> Bool
equalRoundingUpDn13 expr1 expr2  (<=) (*^) (*.) e1 e2 e3 =
    (expr1 (*.) e1 e2 e3 <= (expr2 (*^) e1 e2 e3))
    &&
    (expr2 (*.) e1 e2 e3 <= (expr1 (*^) e1 e2 e3))
    
equalRoundingUpDn23 :: (Expr2Op3 t) -> (Expr2Op3 t) -> (Rel t) -> (Op t) -> (Op t) -> (Op t) -> (Op t) -> t -> t -> t -> Bool
equalRoundingUpDn23 expr1 expr2  (<=) (*^) (**^) (*.) (**.) e1 e2 e3 =
    (expr1 (*.) (**.) e1 e2 e3 <= (expr2 (*^) (**^) e1 e2 e3))
    &&
    (expr2 (*.) (**.) e1 e2 e3 <= (expr1 (*^) (**^) e1 e2 e3))
    
     