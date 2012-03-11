module Main where

import Numeric.AERN.Poly.IntPoly

import Numeric.AERN.RmToRn.Domain
import Numeric.AERN.RmToRn.New
import Numeric.AERN.RmToRn.Evaluation
import Numeric.AERN.RmToRn.Integration

import Numeric.AERN.RealArithmetic.Basis.Double
--import Numeric.AERN.RealArithmetic.Basis.MPFR
import Numeric.AERN.Basics.Interval

import qualified Numeric.AERN.RealArithmetic.RefinementOrderRounding as ArithInOut
import Numeric.AERN.RealArithmetic.RefinementOrderRounding.OpsDefaultEffort

import Numeric.AERN.RealArithmetic.ExactOps
import Numeric.AERN.RealArithmetic.Measures 

import qualified Numeric.AERN.RefinementOrder as RefOrd
import Numeric.AERN.RefinementOrder.OpsDefaultEffort

import qualified Numeric.AERN.NumericOrder as NumOrd
import Numeric.AERN.NumericOrder.OpsDefaultEffort

import Numeric.AERN.Basics.Consistency
import Numeric.AERN.Basics.PartialOrdering
import Numeric.AERN.Basics.ShowInternals

import Numeric.AERN.Misc.Debug

import System.IO

import qualified Data.Map as Map
import qualified Data.List as List

--type CF = Interval MPFR
type CF = Interval Double
type Poly = IntPoly String CF

main :: IO ()
main =
    do
    putStrLn "basic arithmetic:"
    putStrLn $ "0 = " ++ showP c0
    putStrLn $ "1 = " ++ showP c1
    putStrLn $ "x = " ++ showP x
    putStrLn $ "y = " ++ showP y
    putStrLn $ "x + y = " ++ (showP $ xPy)
    putStrLn $ "x + y + 1 + 1 = " ++ (showP $ xPyP1P1)
    putStrLn $ "(x + y)*(x - y) = " ++ (showP $ xPyBTxMyB)
    putStrLn $ "2(x + y + 2) = " ++ (showP $ twoBxPyP2)
    putStrLn "structure changes:"
    putStrLn $ "2(x + y + 2)[size 1] = " 
                    ++ (showP $ reduceCount $ changeSizeLimits cfgSize1 $ twoBxPyP2)
    putStrLn $ "2(x + y + 2) [new vars z1,z2 at the front] = " 
                    ++ (showP $ addVariablesFront (zip ["z1","z2"] doms) twoBxPyP2)
    putStrLn $ "2(x + y + 2) [new vars z1,z2 at the back] = " 
                    ++ (showP $ addVariablesBack (zip ["z1","z2"] doms) twoBxPyP2)
--    putStrLn "endpoints (ie boundaries):"
--    putStrLn $ "getEndpoints([0,1]x^2+[-1,0]) = " ++ (showPPair $ RefOrd.getEndpointsOutWithDefaultEffort $ c01 <*> (x <*> x <-> c1))
--    putStrLn $ "fromEndpoints(x^2-1, 0) = " ++ (showP $ RefOrd.fromEndpointsOutWithDefaultEffort ((x <*> x <-> c1), c0))
--    putStrLn "evaluation and substitution:"
--    putStrLn $ "(x + y + 2)generic[x=-1,y=-1] = " ++ (show $ evalOtherType evalOpsOutCf (Map.fromList [("x",-1),("y",-1)]) xPyP1P1)
--    putStrLn $ "(x + y + 2)generic[x=[-1,0],y=[-1,0]] = " ++ (show $ evalOtherType evalOpsOutCf (Map.fromList [("x",(-1) </\> 0),("y",(-1) </\> 0)]) xPyP1P1)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)generic[x=-1,y=-1] = " ++ (show $ evalOtherType evalOpsOutCf (Map.fromList [("x",-1),("y",-1)]) integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)generic[x=[-1,0],y=[-1,0]] = " ++ (show $ evalOtherType evalOpsOutCf (Map.fromList [("x",(-1) </\> 0),("y",(-1) </\> 0)]) integTwoBxPyP2)
--    putStrLn "random generation:"
--    randomPolysThin <- sample' (case NumOrd.arbitraryTupleInAreaRelatedBy (x, Just (0 </\> 1)) [1] [] of Just gen -> gen)
--    let _ = [x] : randomPolysThin
--    putStr $ "random 10 polynomials:\n" ++ (unlines $ map (showP . head) $ randomPolysThin)
    putStrLn "numerical comparison:"
    putStrLn $ "(x^2-1 `comp` 1) = " ++ (show $ numCompare (x <*> x <-> c1) c1)
    putStrLn $ "(x^2-1 `comp` 0) = " ++ (show $ numCompare (x <*> x <-> c1) c0)
    putStrLn $ "(x^2-1 `comp` -0.5) = " ++ (show $ numCompare (x <*> x <-> c1) (neg (cHalf)))
    putStrLn $ "(x^2-1 `comp` -1) = " ++ (show $ numCompare (x <*> x <-> c1) (c0 <-> c1))
    putStrLn $ "(x^2-1 `comp` -2) = " ++ (show $ numCompare (x <*> x <-> c1) ((c0 <-> c1) <-> c1))
--    putStrLn "min/max up/dn:"
--    putStrLn $ "x - 0.5 `maxUp` 0 = " ++ (showP $ NumOrd.maxUpEff minmaxUpDnEff (x <-> cHalf) c0)
--    putStrLn $ "x - 0.5 `maxDn` 0 = " ++ (showP $ NumOrd.maxDnEff minmaxUpDnEff (x <-> cHalf) c0)
--    putStrLn $ "x - 0.5 `minUp` 0 = " ++ (showP $ NumOrd.minUpEff minmaxUpDnEff (x <-> cHalf) c0)
--    putStrLn $ "x - 0.5 `minDn` 0 = " ++ (showP $ NumOrd.minDnEff minmaxUpDnEff (x <-> cHalf) c0)
--    putStrLn $ "x - 1/16 `maxUp` 0 = " ++ (showP $ NumOrd.maxUpEff minmaxUpDnEff (x <-> cOneOver16) c0)
--    putStrLn $ "x - 1/16 `maxDn` 0 = " ++ (showP $ NumOrd.maxDnEff minmaxUpDnEff (x <-> cOneOver16) c0)
--    putStrLn $ "x - 1/16 `minUp` 0 = " ++ (showP $ NumOrd.minUpEff minmaxUpDnEff (x <-> cOneOver16) c0)
--    putStrLn $ "x - 1/16 `minDn` 0 = " ++ (showP $ NumOrd.minDnEff minmaxUpDnEff (x <-> cOneOver16) c0)
--    putStrLn "min/max in/out:"
--    putStrLn $ "x - 0.5 `maxOut` 0 = " ++ (showP $ NumOrd.maxOutEff minmaxInOutEff (x <-> cHalf) c0)
--    putStrLn $ "x - 0.5 `maxIn` 0 = " ++ (showP $ NumOrd.maxInEff minmaxInOutEff (x <-> cHalf) c0)
--    putStrLn $ "x - 0.5 `minOut` 0 = " ++ (showP $ NumOrd.minOutEff minmaxInOutEff (x <-> cHalf) c0)
--    putStrLn $ "x - 0.5 `minIn` 0 = " ++ (showP $ NumOrd.minInEff minmaxInOutEff (x <-> cHalf) c0)
--    putStrLn $ "x - 1/16 `maxOut` 0 = " ++ (showP $ NumOrd.maxOutEff minmaxInOutEff (x <-> cOneOver16) c0)
--    putStrLn $ "x - 1/16 `maxIn` 0 = " ++ (showP $ NumOrd.maxInEff minmaxInOutEff (x <-> cOneOver16) c0)
--    putStrLn $ "x - 1/16 `minOut` 0 = " ++ (showP $ NumOrd.minOutEff minmaxInOutEff (x <-> cOneOver16) c0)
--    putStrLn $ "x - 1/16 `minIn` 0 = " ++ (showP $ NumOrd.minInEff minmaxInOutEff (x <-> cOneOver16) c0)
    putStrLn "integration:"
    putStrLn $ "1 + int (2(x + y + 2)) dx = " ++ (showP integxTwoBxPyP2)
    putStrLn $ "1 + int (2(x + y + 2)) dy = " ++ (showP integyTwoBxPyP2)
--    putStrLn "*** ops not using generic interfaces (yet): ***"
--    putStrLn "differentiation:"
--    putStrLn $ "d (2(x + y + 2))/dx = " ++ (showP $ diffPolyOut eff "x" twoBxPyP2)
--    putStrLn $ "d (2(x + y + 2))/dy = " ++ (showP $ diffPolyOut eff "y" twoBxPyP2) 
--    putStrLn $ "d (x^2 + 2xy + 4x + 1)/dx = " ++ (showP $ diffPolyOut eff "x" integTwoBxPyP2)
--    putStrLn $ "d (x^2 + 2xy + 4x + 1)/dy = " ++ (showP $ diffPolyOut eff "y" integTwoBxPyP2)
--    putStrLn "(ad hoc) evaluation and substitution:"
--    putStrLn $ "(x + y + 2)drct[x=-1,y=-1] = " ++ (show $ evalPolyAtPoint eff [-1, -1] xPyP1P1)
--    putStrLn $ "(x + y + 2)drct[x=[-1,0],y=[-1,0]] = " ++ (show $ evalPolyAtPoint eff [mOneToZ,mOneToZ] xPyP1P1)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)drct[x=-1,y=-1] = " ++ (show $ evalPolyAtPoint eff [-1,-1] integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)drct[x=[-1,0],y=[-1,0]] = " ++ (show $ evalPolyAtPoint eff [mOneToZ,mOneToZ] integTwoBxPyP2)
--    putStrLn $ "(x + y + 2)mono[x=-1,y=-1] = " ++ (show $ evalPolyOnInterval eff [(-1),(-1)] xPyP1P1)
--    putStrLn $ "(x + y + 2)mono[x=[-1,0],y=[-1,0]] = " ++ (show $ evalPolyOnInterval eff [(-1) </\> 0,(-1) </\> 0] xPyP1P1)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)mono[x=-1,y=-1] = " ++ (show $ evalPolyOnInterval eff [(-1),(-1)] integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)mono[x=[-1,0],y=[-1,0]] = " ++ (show $ evalPolyOnInterval eff [(-1) </\> 0,(-1) </\> 0] integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)subst[x=[y,y]] = " ++ (showP $ substPolyMainVar eff 0 y integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)subst[x=[0,y]] = " ++ (showP $ substPolyMainVar eff 0 (c01 <*> y) integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)subst[x=[0,x]] = " ++ (showP $ substPolyMainVar eff 0 (c01 <*> x) integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)subst[x=[x^2-1,0]] = " ++ (showP $ substPolyMainVar eff 0 (RefOrd.fromEndpointsOutWithDefaultEffort ((x <*> x <-> c1), c0)) integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)substElim[x=[2,2]] = " ++ (showP $ substPolyMainVarElim eff 0 2 integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)substElim[x=[0,2]] = " ++ (showP $ substPolyMainVarElim eff 0 (0 </\> 2) integTwoBxPyP2)
--    putStrLn "structural ops:"
--    putStrLn $ "(x^2 + 2xy + 4x + 1)[swap order of x,y] = " ++ (showP $ polySwapFirstTwoVars integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)[x->z] = " ++ (showP $ polyRenameMainVar "z" integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)[add z] = " ++ (showP $ polyAddMainVar () eff "z" (0 </\> 2) integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)[degree 1] = " ++ (showP $ reduceDeg $ changeSizeLimits cfgDeg1 integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)[degree 0] = " ++ (showP $ reduceDeg $ changeSizeLimits cfgDeg0 integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)[size 2] = " ++ (showP $ reduceCount $ changeSizeLimits cfgSize2 integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)[size 1] = " ++ (showP $ reduceCount $ changeSizeLimits cfgSize1 integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)[size 2, x tiny] = " ++ (showP $ reduceCount $ changeSizeLimits cfgXTinySize2 integTwoBxPyP2)
--    putStrLn $ "(x^2 + 2xy + 4x + 1)[size 1, x tiny] = " ++ (showP $ reduceCount $ changeSizeLimits cfgXTinySize1 integTwoBxPyP2)
--    putStrLn "elementary ops:"
--    putStrLn $ "sin x [n = 1] = " ++ (showP $ sineOutPolyThin ((),()) 4 eff 1 x)
--    putStrLn $ "sin x [n = 2] = " ++ (showP $ sineOutPolyThin ((),()) 4 eff 2 x)
--    putStrLn $ "sin x [n = 3] = " ++ (showP $ sineOutPolyThin ((),()) 4 eff 3 x)
----    putStrLn $ "exp(x + y + 2) = " ++ (showP $ expBxPyP2)
--    where
--    mOneToZ = (-1) </\> 0

showP ::
    Poly -> 
    String
showP p = showPoly id show p -- ++ " [" ++ show p ++ "]"

showPPair ::
    (Poly, Poly) -> 
    String
showPPair (p1,p2) = "(" ++ showP p1 ++ "," ++ showP p2 ++ ")" 

x :: Poly
x = newProjection cfg dombox "x"
y :: Poly
y = newProjection cfg dombox "y"
c0 :: Poly
c0 = newConstFn cfg dombox 0
c1 :: Poly
c1 = newConstFn cfg dombox 1
cHalf :: Poly
cHalf = newConstFn cfg dombox 0.5
--cOneOver16 = newConstFn cfg dombox $ 0.5^4
c01 :: Poly
c01 = newConstFn cfg dombox $ 0 </\> 1

xPy :: Poly
xPy = x <+> y

xMy :: Poly
xMy = x <-> y

xPyP1P1 :: Poly
xPyP1P1 = xPy <+> c1 <+> c1

xPyBTxMyB :: Poly
xPyBTxMyB = xPy <*> xMy

twoBxPyP2 :: Poly
twoBxPyP2 = (2::Int) |<*> xPyP1P1

integxTwoBxPyP2 :: Poly
integxTwoBxPyP2 = c1 <+> primitiveFunctionOutEff eff twoBxPyP2 "x"

integyTwoBxPyP2 :: Poly
integyTwoBxPyP2 = c1 <+> primitiveFunctionOutEff eff twoBxPyP2 "y"

--expBxPyP2 = exp xPyP1P1

eff :: ArithInOut.RoundedRealEffortIndicator CF
--eff = (100, (100,())) -- MPFR with explicit precision
eff = ArithInOut.roundedRealDefaultEffort (0:: CF)
--minmaxUpDnEff = minmaxUpDnDefaultEffortIntPolyWithBezierDegree 10 x
--minmaxInOutEff = minmaxInOutDefaultEffortIntPolyWithBezierDegree 10 x

reduceDeg, reduceCount :: Poly -> Poly 
reduceDeg = reducePolyDegreeOut eff
reduceCount = reducePolyTermCountOut eff

evalOpsOutCf :: PolyEvalOps String CF CF
evalOpsOutCf = evalOpsOut eff x (0::CF)

numCompare :: 
     NumOrd.PartialComparison t 
     =>
     t -> 
     t -> 
     PartialOrderingPartialInfo
numCompare a b =
    NumOrd.pCompareInFullEff (NumOrd.pCompareDefaultEffort a) a b

cfg :: IntPolyCfg String CF
cfg =
    IntPolyCfg
        {
            ipolycfg_vars = vars,
            ipolycfg_domsLZ = domsLZ ,
            ipolycfg_domsLE = domsLE,
            ipolycfg_sample_cf = 0 :: CF,
            ipolycfg_maxdeg = 4,
            ipolycfg_maxsize = 30
        }

cfgDeg0 :: IntPolyCfg String CF
cfgDeg0 = cfg { ipolycfg_maxdeg = 0 }

cfgDeg1 :: IntPolyCfg String CF
cfgDeg1 = cfg { ipolycfg_maxdeg = 1 }

cfgSize1 :: IntPolyCfg String CF
cfgSize1 = cfg { ipolycfg_maxsize = 1 }

cfgSize2 :: IntPolyCfg String CF
cfgSize2 = cfg { ipolycfg_maxsize = 2 }

cfgSize3 :: IntPolyCfg String CF
cfgSize3 = cfg { ipolycfg_maxsize = 3 }

cfgXTiny :: IntPolyCfg String CF
cfgXTiny = cfg { ipolycfg_domsLZ = domsXTiny }

cfgXTinySize1 :: IntPolyCfg String CF
cfgXTinySize1 = cfgXTiny { ipolycfg_maxsize = 1 }

cfgXTinySize2 :: IntPolyCfg String CF
cfgXTinySize2 = cfgXTiny { ipolycfg_maxsize = 2 }

dombox :: DomainBox Poly
dombox = Map.fromList $ zip vars doms

vars :: [Var Poly]
vars = ["x", "y"]

doms :: [CF]
doms = zipWith (<+>) domsLE domsLZ

domsLZ :: [CF]
domsLZ = [0 </\> 2, 0 </\> 2]

domsLE :: [CF]
domsLE = [-1, -1]

domsXTiny :: [CF]
domsXTiny = [(0 </\> 0.0625), ((-1) </\> 1)]

