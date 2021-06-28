-- base
import           XMonad
import qualified XMonad.StackSet as W

-- config
import           XMonad.Config.Desktop

-- hooks
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks

-- layout
import           XMonad.Layout.Spacing
import           XMonad.Layout.ThreeColumns
import           XMonad.Layout.ToggleLayouts

-- prompt
import           XMonad.Prompt
import           XMonad.Prompt.Man
import           XMonad.Prompt.Shell

-- utils
import           System.Exit
import           XMonad.Util.EZConfig
import           XMonad.Util.Run
import           XMonad.Util.SpawnOnce


-- spacing
myGaps = Border 10 10 10 10
mySpacing = spacingRaw False myGaps True myGaps True

-- layouts
myLayouts = toggleLayouts threeCol tile
  where
    --          layout       nmaster  delta    ratio
    threeCol  = ThreeColMid  1        (5/100)  (55/100)
    tile      = Tall         1        (5/100)  (50/100)


-- autolaunch applications
myStartupHook :: X ()
myStartupHook = do
  return ()


-- prompt configuration
myPrompt :: XPConfig
myPrompt = def
           {
             font              = "xft:Ubuntu Nerd Font:pixelsize=13"
           , bgColor           = "#282828"
           , fgColor           = "#ebdbb2"
           , promptBorderWidth = 0
           , position          = Top
           }


-- custom key bindings
myKeyBindings :: [(String, X ())]
myKeyBindings =

  -- program bindings
  [ ("M-b", spawn "$BROWSER")                               -- launch a web browser
  , ("M-d", spawn "discord")                                -- launch discord
  , ("M-e", spawn "emacs")                                  -- launch discord
  , ("M-f", spawn "$TERMINAL -e lf")                        -- launch a file manager
  , ("M-p", spawn "$TERMINAL -e pulsemixer")                -- launch an audio mixer
  , ("M-t", spawn "$TERMINAL")                              -- launch a terminal

  -- xmonad bindings
  , ("M-r", shellPrompt myPrompt)                           -- launch a shell prompt
  , ("M-S-m", manPrompt myPrompt)                           -- launch a manpage prompt
  , ("M-S-q", io (exitWith ExitSuccess))                    -- quit xmonad
  , ("M-S-r", spawn "xmonad --recompile; xmonad --restart") -- recompile and restart xmonad

  , ("M-w", kill)                                           -- close the focused window

  , ("M-j", windows W.focusDown)                            -- move focus to the next window
  , ("M-k", windows W.focusUp)                              -- move focus to the previous window
  , ("M-m", windows W.focusMaster)                          -- move focus to the master window

  , ("M-S-j", windows W.swapDown)                           -- swap the focused window with the next window
  , ("M-S-k", windows W.swapUp)                             -- swap the focused window with the previous window
  , ("M-<Space>", windows W.swapMaster)                     -- swap the focused window and the master window

  , ("M-h", sendMessage Shrink)                             -- shrink the master area
  , ("M-l", sendMessage Expand)                             -- expand the master area

  , ("M-S-t", withFocused $ windows . W.sink)               -- push window back into tiling

  , ("M-<Tab>", sendMessage ToggleLayout)                   -- toggle between the configured layouts
  ]


-- run xmonad with the configured settings
main :: IO ()
main = do
  xmproc <- spawnPipe "xmobar ~/.config/xmobar/xmobarrc"
  xmonad $ docks desktopConfig
    -- simple stuff
    { terminal           = "$TERMINAL"
    , focusFollowsMouse  = True
    , clickJustFocuses   = False
    , borderWidth        = 2
    , modMask            = mod4Mask
    , workspaces         = ["dev", "www", "docs", "mus", "chat", "misc"]
    , normalBorderColor  = "#628374"
    , focusedBorderColor = "#8ec07c"

    -- hooks, layouts
    , layoutHook         = desktopLayoutModifiers $ avoidStruts $ mySpacing $ myLayouts
    , manageHook         = composeAll[]
    , handleEventHook    = mempty
    , logHook            = dynamicLogWithPP xmobarPP
                           { ppOutput          = hPutStrLn xmproc
                           , ppCurrent         = xmobarColor "#8ec07c" "" . wrap "[" "]"
                           , ppVisible         = xmobarColor "#928374" ""
                           , ppHidden          = xmobarColor "#d5c4a1" "" . wrap " " " "
                           , ppHiddenNoWindows = xmobarColor "#928374" "" . wrap " " " "
                           , ppUrgent          = xmobarColor "#fb4934" ""
                           , ppLayout          = xmobarColor "#d79921" "" . wrap " " " "
                           , ppTitle           = xmobarColor "#83a598" "" . shorten 60 . wrap " " ""
                           , ppSep             = " <fc=#7c6f64>|</fc> "
                           }
    , startupHook        = myStartupHook
    }

    -- keybindings
    `additionalKeysP` myKeyBindings
