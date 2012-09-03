module Main where

import Numeric.AERN.Poly.IntPoly
import Numeric.AERN.Poly.IntPoly.Plot ()

import qualified Numeric.AERN.RmToRn.Plot.FnView as FV
import Numeric.AERN.RmToRn.Plot.CairoDrawable

import Numeric.AERN.RmToRn.Domain
import Numeric.AERN.RmToRn.New
import Numeric.AERN.RmToRn.Evaluation

import Numeric.AERN.RealArithmetic.Basis.Double ()
--import Numeric.AERN.RealArithmetic.Basis.MPFR

import Numeric.AERN.Basics.Interval
import Numeric.AERN.RealArithmetic.Interval ()
import Numeric.AERN.RealArithmetic.Interval.ElementaryFromFieldOps ()

import qualified Numeric.AERN.RealArithmetic.RefinementOrderRounding as ArithInOut
import Numeric.AERN.RealArithmetic.RefinementOrderRounding.OpsDefaultEffort

import Numeric.AERN.RealArithmetic.ExactOps

import qualified Numeric.AERN.RefinementOrder as RefOrd
--import Numeric.AERN.RefinementOrder.OpsDefaultEffort

import qualified Numeric.AERN.NumericOrder as NumOrd
--import Numeric.AERN.NumericOrder.OpsDefaultEffort

--import Numeric.AERN.Basics.Consistency
--import Numeric.AERN.Basics.ShowInternals
--import Numeric.AERN.Basics.Effort


import qualified Graphics.UI.Gtk as Gtk

--import qualified Control.Concurrent as Concurrent
import Control.Concurrent.STM

import qualified Data.Map as Map
--import qualified Data.List as List

import System.Environment (getArgs)

import Numeric.AERN.Misc.Debug
_ = unsafePrint

--type CF = Interval MPFR
type CF = Interval Double
type FnEndpt = IntPoly String CF
type Fn = Interval FnEndpt

main :: IO ()
main =
    do
    args <- getArgs
    let [exampleName, maxdegS] = args
    let maxdeg = read maxdegS
    case getFnDefs exampleName maxdeg of
        Just fnDefs -> plot fnDefs
        _ -> error $ "unknown example " ++ exampleName

plot :: ([[Fn]], FV.FnMetaData Fn) -> IO ()
plot (fns, fnmeta) =
    do
    -- enable multithreaded GUI:
    _ <- Gtk.unsafeInitGUIForThreadedRTS
    fnDataTV <- atomically $ newTVar $ FV.FnData $ addPlotVar fns
    fnMetaTV <- atomically $ newTVar $ fnmeta
    _ <- FV.new sampleFn effDrawFn effCF effEval (fnDataTV, fnMetaTV) Nothing
--    Concurrent.forkIO $ signalFn fnMetaTV
    Gtk.mainGUI
    where
    ((sampleFn :_) :_) = fns 
    effDrawFn = cairoDrawFnDefaultEffort sampleFn
    effEval = evaluationDefaultEffort sampleFn
    effCF = ArithInOut.roundedRealDefaultEffort (0:: CF)
    --effCF = (100, (100,())) -- MPFR

addPlotVar :: [[Fn]] -> [[(Fn, String)]]
addPlotVar fns =
    map (map addV) fns
    where
    addV fn = (fn, plotVar)
        where
        (plotVar : _) = vars
        vars = map fst $ toAscList dombox
        dombox = getDomainBox fn   

getFnDefs :: [Char] -> Int -> Maybe ([[Fn]], FV.FnMetaData Fn)
getFnDefs exampleName maxdeg =
    Map.lookup exampleName $ examples maxdeg

examples :: Int -> Map.Map [Char] ([[Fn]], FV.FnMetaData Fn)
examples maxdeg =
    Map.fromList $
    [
        ("minmax", fnDefsMinmax maxdeg)
    ,
        ("mult1", fnDefsMult1 maxdeg)
    ,
        ("expMx2", fnDefsExpMx2 maxdeg)
    ]   

fnDefsMinmax :: Int -> ([[Fn]], FV.FnMetaData Fn)
fnDefsMinmax maxdeg = (fns, fnmeta)
    where
    fnmeta =
        (FV.defaultFnMetaData x)
        {
            FV.dataFnGroupNames = ["max 1/16", "max 7/16", "max 15/16"],
            FV.dataFnNames = 
                [
                    ["x", "1/16", "maxOut"]
                , 
                    ["x", "7/16", "maxOut"]
                ,
                    ["x", "15/16", "maxOut"]
                ]
                ,
            FV.dataFnStyles = 
                [
                    [black, black, blue]
                ,
                    [black, black, blue]
                ,
                    [black, black, blue]
                ]
        }
    fns = 
        [ 
         [x, cOneOver16, 
          NumOrd.maxOutEff effMinmaxInOut (x) cOneOver16
         ]
         ,
         [x, cSevenOver16, 
          NumOrd.maxOutEff effMinmaxInOut (x) cSevenOver16
         ]
         ,
         [x, cOneMinusOneOver16, 
          NumOrd.maxOutEff effMinmaxInOut (x) cOneMinusOneOver16
         ]
        ]
    cfg =
        IntPolyCfg
            {
                ipolycfg_vars = vars,
                ipolycfg_domsLZ = doms,
                ipolycfg_domsLE = replicate (length vars) 0,
                ipolycfg_sample_cf = 0 :: CF,
                ipolycfg_maxdeg = maxdeg,
                ipolycfg_maxsize = 1000
            }
    
    dombox = Map.fromList $ zip vars doms
    vars = ["x"]
    doms = [constructCF 0 1]

    x = newProjection cfg dombox "x" :: Fn
--    c0 = newConstFn cfg dombox 0 :: Fn
--    c1 = newConstFn cfg dombox 1 :: Fn
--    cHalf = newConstFn cfg dombox 0.5 :: Fn
--    cHalf1 = newConstFn cfg dombox $ 0.5 </\> 1 :: Fn
    cOneOver16 = newConstFn cfg dombox $ 0.5^(4::Int) :: Fn
    cSevenOver16 = newConstFn cfg dombox $ 7 * 0.5^(4::Int) :: Fn
    cOneMinusOneOver16 = newConstFn cfg dombox $ 15 * 0.5^(4::Int) :: Fn
    
    effMinmaxInOut = NumOrd.minmaxInOutDefaultEffort sampleFn
    sampleFn = x 

fnDefsMult1 :: Int -> ([[Fn]], FV.FnMetaData Fn)
fnDefsMult1 maxdeg = (fns, fnmeta)
    where
    fnmeta =
        (FV.defaultFnMetaData x)
        {
            FV.dataFnGroupNames = ["poly int" ,"int poly"]
            ,
            FV.dataFnNames = 
                [
                    ["a1","b1","a1 <*> b1"]
                ,
                    ["a1","b1","a1 <*> b1"]
                ]
            ,
            FV.dataFnStyles = 
                [
                    replicate 3 blue
                , 
                    replicate 3 red
                ]
        }
    fns = 
        [
            [
                a1,
                b1,
                a1 <*> b1
            ]
            ,
            [
                mkFnFromEndpt a1E,
                mkFnFromEndpt b1E,
                mkFnFromEndpt $ a1E <*> b1E
            ]
        ]
    a1,b1 :: Fn
    a1 =
    --  (x-0.5) + [_0,0.5^]
        (x <+>| (-0.5 :: Double)) 
        <+>| 
        (constructCF 0 (0.5))
    b1 = 
    --  [_-1,1^]
        c0 <+>|
        (constructCF (-1) (1))
    
    mkFnFromEndpt :: FnEndpt -> Fn
    mkFnFromEndpt e = Interval e e
    
    a1E,b1E :: FnEndpt
    a1E =
    --  -((x-0.5) + [_0,0.5^])
        neg $
            (xE <+>| (-0.5 :: Double)) 
            <+>| 
            (constructCF 0 (0.5))
    b1E = 
    --  [_-1,1^]
        c0E <+>|
        (constructCF (-1) (1))

    cfg =
        IntPolyCfg
            {
                ipolycfg_vars = vars,
                ipolycfg_domsLZ = doms,
                ipolycfg_domsLE = replicate (length vars) 0,
                ipolycfg_sample_cf = 0 :: CF,
                ipolycfg_maxdeg = maxdeg,
                ipolycfg_maxsize = 1000
            }

    x = newProjection cfg dombox "x" :: Fn
    c0 = newConstFn cfg dombox 0 :: Fn
    
    xE = newProjection cfg dombox "x" :: FnEndpt
    c0E = newConstFn cfg dombox 0 :: FnEndpt
    
    dombox = Map.fromList $ zip vars doms
    vars = ["x"]
    doms = [constructCF 0 1]

fnDefsExpMx2 :: Int -> ([[Fn]], FV.FnMetaData Fn)
fnDefsExpMx2 maxdeg = (fns, fnmeta)
    where
    fnmeta =
        (FV.defaultFnMetaData x)
        {
            FV.dataFnGroupNames = ["thin"] -- , "thin+1", "thick"]
            ,
            FV.dataFnNames = 
                [
                    ["-(x^2)","exp(-(x^2))"]
                ]
            ,
            FV.dataFnStyles = 
                [
                    [black, blue],
                    [black, blue],
                    [black, blue]
                ]
        }
    fns = 
        [
            [
                mx2,
                ArithInOut.expOutEff effExp mx2
            ]
        ]
    mx2 :: Fn
    mx2 =
    --  (x-0.5) + [_0,0.5^]
        neg (x <*> x)

    x = newProjection cfg dombox "x" :: Fn
    
    cfg =
        IntPolyCfg
            {
                ipolycfg_vars = vars,
                ipolycfg_domsLZ = doms,
                ipolycfg_domsLE = replicate (length vars) 0,
                ipolycfg_sample_cf = 0 :: CF,
                ipolycfg_maxdeg = maxdeg,
                ipolycfg_maxsize = 1000
            }

    dombox = Map.fromList $ zip vars doms
    vars = ["x"]
    doms = [constructCF (-1) 1]
    
    effExp = ArithInOut.expDefaultEffort x

constructCF :: Double -> Double -> CF
constructCF l r =
    RefOrd.fromEndpointsOutWithDefaultEffort (cf0 <+>| l, cf0 <+>| r)
cf0 :: CF
cf0 = 0
    
black :: FV.FnPlotStyle
black = FV.defaultFnPlotStyle
blue :: FV.FnPlotStyle
blue = FV.defaultFnPlotStyle 
    { 
        FV.styleOutlineColour = Just (0.1,0.1,0.8,1), 
        FV.styleFillColour = Just (0.1,0.1,0.8,0.1) 
    } 
red :: FV.FnPlotStyle
red = FV.defaultFnPlotStyle 
    { 
        FV.styleOutlineColour = Just (0.8,0.2,0.2,1), 
        FV.styleFillColour = Just (0.8,0.2,0.2,0.1) 
    } 


{- Error report being investigated:

IntPoly-DI >*< <*>:

TwoLEPairs 
((IntPoly{[_-1.0,0.0^]"x" + [_2.0,3.0000000000000004^]; 
        cfg{[("x",[_0.0,1.0^])];4/30}; V{"x"/[(0,C{[_2.0,3.0000000000000004^]}),(1,C{[_-1.0,0.0^]})]}},
  IntPoly{[_-226.68234077903497,0.0^]"x"^2 + [_-3.8597885883944825e-7,0.0^]"x" + [^230.6823411650138,3.0000000000000004_]; 
        cfg{[("x",[_0.0,1.0^])];4/30}; V{"x"/[(0,C{[^230.6823411650138,3.0000000000000004_]}),(1,C{[_-3.8597885883944825e-7,0.0^]}),(2,C{[_-226.68234077903497,0.0^]})]}}),(
  IntPoly{[_0.9999999999999999,2.0000000000000004^]; 
        cfg{[("x",[_0.0,1.0^])];4/30}; V{"x"/[(0,C{[_0.9999999999999999,2.0000000000000004^]})]}},
  IntPoly{[_-1.3749702075180186e-54,0.0^]"x"^2 + [_-0.46609761298834296,0.0^]"x" + [^3.4660976129883427,1.0000000000000002_]; cfg{[("x",[_0.0,1.0^])];4/30}; V{"x"/[(0,C{[^3.4660976129883427,1.0000000000000002_]}),(1,C{[_-0.46609761298834296,0.0^]}),(2,C{[_-1.3749702075180186e-54,0.0^]})]}}))
((),((),()))
((240,((),((),()))),())

  refinement monotone: [Failed]
Falsifiable with seed -1029358060, after 2 tests. Reason: Falsifiable

simplified polynomials:
  [_-1,0^]*x + [_2,3^]
  [_-226,0.0^]"x"^2 + [_-3e-7,0.0^]"x" + [^230,3_]
  
  [_1,2^]
  [_-1e-54,0.0^]"x"^2 + [_-0.5,0^]"x" + [^3.5,1]

---
  [_-1e-54,-1e-286^]*x^2 + [_-0.5,0.0^]*x + [_1.5,3.5^]
  [_-226,-1e-54^]*x^2 + [^0.0,-0.5_]*x + [^231,2.5_]

  [^-2.2,-2.5_]*x + [_3,9^]
  [_-1e-54,0.0^]*x^2 + [^-0.5,-2.5_]*x + [_4.7,8.2^]
  
-}
--    