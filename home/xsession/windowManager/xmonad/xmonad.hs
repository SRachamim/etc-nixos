import XMonad
import XMonad.Config.Xfce
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

myNormColor :: String
myNormColor   = "#2E3440"  -- Border color of normal windows

myFocusColor :: String
myFocusColor  = "#5E81AC"  -- Border color of focused windows

myManageHook = composeAll
   [ className =? "Tor Browseu"  --> doFloat
   ]

main = do   
    xmproc <- spawnPipe "xmobar"
    xmonad $ docks xfceConfig
        { layoutHook = avoidStruts  $  layoutHook xfceConfig
        , terminal = "kitty"
	, startupHook = ewmhDesktopsStartup >> setWMName "LG3D"
	, manageHook    = myManageHook <+> manageHook defaultConfig
        , focusFollowsMouse = False
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , workspaces  = ["1:spot", "2:personal", "3:fg"]
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        } `additionalKeys`
        [ ((mod1Mask, xK_p), spawn "rofi -combi-modi drun,ssh -show combi")
        ]
