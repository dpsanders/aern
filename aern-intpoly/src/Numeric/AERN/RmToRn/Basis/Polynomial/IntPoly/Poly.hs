{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ImplicitParams #-}
{-|
    Module      :  Numeric.AERN.RmToRn.Basis.Polynomial.IntPoly.Poly
    Description :  datatype of polynomials and related structure functions  
    Copyright   :  (c) Michal Konecny
    License     :  BSD3

    Maintainer  :  mikkonecny@gmail.com
    Stability   :  experimental
    Portability :  portable
    
    Datatype of polynomials and related structure functions.
-}

module Numeric.AERN.RmToRn.Basis.Polynomial.IntPoly.Poly
--    (
--    )
where
    
import Numeric.AERN.RmToRn.Basis.Polynomial.IntPoly.Config
    
import qualified Numeric.AERN.RealArithmetic.RefinementOrderRounding as ArithInOut
import Numeric.AERN.RealArithmetic.RefinementOrderRounding.OpsDefaultEffort
import Numeric.AERN.RealArithmetic.ExactOps
import Numeric.AERN.RealArithmetic.Measures (HasImprecision(..))

--import qualified Numeric.AERN.RefinementOrder as RefOrd
import Numeric.AERN.RefinementOrder.OpsDefaultEffort ((|==?))

import Numeric.AERN.Basics.ShowInternals
import Numeric.AERN.Basics.Exception
import Numeric.AERN.Basics.Consistency

import qualified Data.IntMap as IntMap

import Data.List (intercalate)

    
{-| 
    Multi-variate polynomials using a representation that
    depends on a specific ordering of variables.  The first variable
    is called the main variable. The polynomial is represented
    as a uni-variate polynomial in the main variable whose
    coefficients are polynomials in the remaining variables.
-}
data IntPoly var cf =
    IntPoly
        {
            intpoly_cfg :: IntPolyCfg var cf, 
            intpoly_terms :: IntPolyTerms var cf
        }

data IntPolyTerms var cf = 
        IntPolyC -- constant
            {
                intpoly_value :: cf -- no variables, only one constant term
            }
    |   IntPolyV  -- a proper polynomial
            {
                intpoly_mainVar :: var, -- name of the main variable
                intpoly_pwrCoeffs :: IntPolyPowers var cf 
                  -- coefficients of powers of the main variable as polynomials in other variables
                  -- often converted to a descending association list to evaluate using the Horner scheme
            }

type IntPolyPowers var cf = 
    IntMap.IntMap (IntPolyTerms var cf) 

{-|
    A different face of an IntPoly, where the assumption
    can be made that all coefficients are consistent.
    
    Many operations are simpler to implement with this assumtion.
    This type is used mainly to define outer-rounded
    minimum and maximum, which needs multiplication
    and itself is needed to define the more general IntPoly
    multiplication. 
 -}
newtype IntPolyWithConsistentCoeffs var cf =
    IntPolyWithConsistentCoeffs (IntPoly var cf)
    deriving (Show)

{-- formatting --}

instance 
    (Show var, Show cf, ArithInOut.RoundedReal cf) => 
    Show (IntPoly var cf)
    where
    show p@(IntPoly cfg terms)
        = "IntPoly{" ++ showPoly show show p ++ "; " ++ show cfg ++ "; " ++ show terms ++ "}" 

instance 
    (Show var, Show cf) 
    => 
    (Show (IntPolyTerms var cf))
    where
    show (IntPolyC val)
        = "C{" ++ show val ++ "}"
    show (IntPolyV x polys)
        = "V{" ++ show x ++ "/" ++ show (IntMap.toAscList polys) ++ "}"
    
instance
    (Show var, ShowInternals cf) =>
    (ShowInternals (IntPoly var cf))
    where
    type ShowInternalsIndicator (IntPoly var cf) 
        = ShowInternalsIndicator cf
    defaultShowIndicator (IntPoly cfg _) 
        = defaultShowIndicator $ ipolycfg_sample_cf cfg
    showInternals cfIndicator
        = showPoly (show) (showInternals cfIndicator)
    
showPoly ::
    (var -> String) -> 
    (cf -> String) -> 
    (IntPoly var cf -> String)
showPoly showVar showCoeff (IntPoly cfg poly) =
    sp "" poly
    where
    sp vars (IntPolyC value) 
        = (showCoeff value) ++ vars
    sp otherVars (IntPolyV var polys)
        = intercalate " + " $ map showTerm $ reverse $ IntMap.toAscList $ polys
        where
        showTerm (n,p) = sp (otherVars ++ showVarPower n) p
        showVarPower 0 = ""
        showVarPower 1 = showVar var
        showVarPower n = showVar var ++ "^" ++ show n
    
{-- simple spine-crawling operations --}

powersMapCoeffs :: (cf -> cf) -> IntPolyPowers var cf -> IntPolyPowers var cf
powersMapCoeffs f pwrCoeffs = IntMap.map (termsMapCoeffs f) pwrCoeffs

termsMapCoeffs :: (cf -> cf) -> IntPolyTerms var cf -> IntPolyTerms var cf
termsMapCoeffs f (IntPolyC val) = IntPolyC $ f val
termsMapCoeffs f (IntPolyV var polys) = IntPolyV var $ powersMapCoeffs f polys

polySplitWith ::
    (cf -> (cf,cf)) ->
    (IntPoly var cf) -> (IntPoly var cf, IntPoly var cf)
polySplitWith splitCf (IntPoly cfg terms) = 
    (IntPoly cfg termsL, IntPoly cfg termsR)
    where
    (termsL, termsR) = termsSplitWith splitCf terms
termsSplitWith ::
    (cf -> (cf,cf)) ->
    (IntPolyTerms var cf) -> (IntPolyTerms var cf, IntPolyTerms var cf)
termsSplitWith splitCf (IntPolyC val) = 
    (IntPolyC valL, IntPolyC valR)
    where
    (valL, valR) = splitCf val
termsSplitWith splitCf (IntPolyV var polys) = 
    (IntPolyV var polysL, IntPolyV var polysR)
    where
    polysL = IntMap.map fst polysLR
    polysR = IntMap.map snd polysLR
    polysLR = IntMap.map (termsSplitWith splitCf) polys

polyJoinWith ::
    cf {-^ zero coeff -} ->
    ((cf,cf) -> cf) ->
    (IntPoly var cf, IntPoly var cf) -> (IntPoly var cf) 
polyJoinWith z joinCf (IntPoly cfg termsL, IntPoly _ termsR) =
    (IntPoly cfg terms) 
    where
    terms = termsJoinWith z joinCf (termsL, termsR)
termsJoinWith ::
    cf {-^ zero coeff -} ->
    ((cf,cf) -> cf) ->
    (IntPolyTerms var cf, IntPolyTerms var cf) -> (IntPolyTerms var cf) 
termsJoinWith z joinCf (tL, tR) =
    aux (Just tL, Just tR)
    where
    aux (Just (IntPolyC valL), Just (IntPolyC valR)) = 
        IntPolyC val
        where
        val = joinCf (valL, valR)
    aux (Nothing, Just (IntPolyC valR)) = 
        IntPolyC val
        where
        val = joinCf (z, valR)
    aux (Just (IntPolyC valL), Nothing) = 
        IntPolyC val
        where
        val = joinCf (valL, z)
    aux (Just (IntPolyV var polysL), Just (IntPolyV _ polysR)) = 
        IntPolyV var $ IntMap.map aux polys 
        where
        polys = polysLR `IntMap.union` polysLonly `IntMap.union` polysRonly
        polysLonly = IntMap.map (\l -> (Just l, Nothing)) $ polysL `IntMap.difference` polysR 
        polysRonly = IntMap.map (\r -> (Nothing, Just r)) $ polysR `IntMap.difference` polysL 
        polysLR = IntMap.intersectionWith (\l -> \r -> (Just l, Just r)) polysL polysR  
    aux (Nothing, Just (IntPolyV var polysR)) = 
        IntPolyV var $ IntMap.map (aux . addNothing) polysR 
        where
        addNothing t = (Nothing, Just t)
    aux (Just (IntPolyV var polysL), Nothing) = 
        IntPolyV var $ IntMap.map (aux . addNothing) polysL 
        where
        addNothing t = (Just t, Nothing)


{-- Internal checks and normalisation --}

polyNormalise ::
    (ArithInOut.RoundedReal cf)
    => 
    IntPoly var cf -> IntPoly var cf
polyNormalise (IntPoly cfg poly)
    = IntPoly cfg (termsNormalise poly) 

termsNormalise ::
    (ArithInOut.RoundedReal cf) 
    =>
    IntPolyTerms var cf -> IntPolyTerms var cf
termsNormalise poly =
    pn poly
    where    
    pn p@(IntPolyC val) = p
    pn (IntPolyV x polys)
        = IntPolyV x $ IntMap.filterWithKey nonZeroOrConst $ IntMap.map pn polys
        where
        nonZeroOrConst degree subTerms =
            degree == 0 || (not $ termsIsZero subTerms)  

instance
    (HasLegalValues cf, Show cf, ArithInOut.RoundedReal cf, 
     Show var, Ord var) 
    =>
    HasLegalValues (IntPoly var cf)
    where
    maybeGetProblem (IntPoly cfg terms) = 
        maybeGetProblemForTerms cfg terms
    
maybeGetProblemForTerms cfg terms
    =
    aux vars terms
    where
    vars = ipolycfg_vars cfg
    intro = "cfg = " ++ show cfg ++ "; terms = " ++ show terms ++ ": "
    aux [] p@(IntPolyC value) = 
        fmap ((intro ++ "problem with coefficient: ") ++) $ maybeGetProblem value
    aux (cvar : rest) (IntPolyV tvar polys)
        | cvar == tvar =
            findFirstJust $ map (aux rest) $ IntMap.elems polys
        | otherwise = 
            Just $
                intro ++ 
                "variable name mismatch: declared = " ++ show cvar ++ " actual = " ++ show tvar  
    aux [] _ =
        Just $ intro ++ "more variables than declared"  
    aux _ _ =
        Just $ intro ++ "less variables than declared"  
    findFirstJust (j@(Just _) : rest) = j
    findFirstJust (Nothing:rest) = findFirstJust rest    
    findFirstJust [] = Nothing

{-- Order-related ops --}

flipConsistencyPoly (IntPoly cfg terms) =
    IntPoly cfg $ termsMapCoeffs flipConsistency terms 
    
polyIsExactEff ::
    (HasImprecision cf)
    =>
    (ImprecisionEffortIndicator cf) ->
    (IntPoly var cf) ->
    Maybe Bool
polyIsExactEff effImpr p@(IntPoly _ terms) = termsAreExactEff effImpr terms 

termsAreExactEff ::
    (HasImprecision cf)
    =>
    (ImprecisionEffortIndicator cf) ->
    (IntPolyTerms var cf) ->
    Maybe Bool
termsAreExactEff effImpr (IntPolyC val) = isExactEff effImpr val 
termsAreExactEff effImpr (IntPolyV var polys) =
    do -- the Maybe monad, ie if any coefficient returns Nothing, so does this function 
    results <- mapM (termsAreExactEff effImpr) $ IntMap.elems polys
    return $ and results

polyIsZero ::
    (ArithInOut.RoundedReal cf) 
    => 
    IntPoly var cf -> Bool
polyIsZero (IntPoly _ terms)
    = termsIsZero terms

termsIsZero ::
    (ArithInOut.RoundedReal cf) 
    => 
    IntPolyTerms var cf -> Bool
termsIsZero (IntPolyC val) = (val |==? (zero val)) == Just True
termsIsZero (IntPolyV x polys) = 
    case IntMap.toAscList polys of
        [] -> True
        [(0,p)] -> termsIsZero p
        _ -> False
