local KEYS = 9
local EXTRA = 4

local art_xl = [==[
                                                                   -+-  4123 ft
                                                                    /\
                                                                   /  \
                                                                 /     \
                                                                 /  ..   \
                                                                /  . .   \                     -+-  3687 ft
                                                               //  ..%%%%%\                     /\
                                    /\                        /:. ...\%%%::\\                  /  \
                                   / .\                      //..: ./%\%%%%%\                  /.  \
                                  /    \                   /:/. .. / #%\:%%%%\               /...:%\
                                /....%::\         /\      /./:::../. #%%\%%#%%\             /...:%%%\
                               /.: /.\::%\       /  \     //.:  :/ .:##%%\##%#%\      /\    /. /.\:%%:\
              /\               /.:/..%\::%\     / .:%\    /.::.:/.:  %%#%#\%%###\    /  \ /.../ .%\#%%%%\
-   ~   ~-~  / .\- ~ ~/\ ~    /::/.  #%\%#\ ~~ / .:\%:\ ~/:~:::/: ::-\%###%\##%%%\\ /.-:%:\: / : %%#%%#%\  ~~-~ /\    -
            /..:::\  / .\    /::/::::#%%\%%%\ /:/\/#\%%//::;;:/:::::/#\#####\#####\//\/%#%\::.:::#%%\%####\    /  \\
          /:./:%%\\ / .:\   /::/::  :%#%#\%#\/ / :\%%\//:;:::;:::::;:#%######\##%/ /.%\#%\%\:;:: %%%\#\#%##/\   /.:#\
~ ~    ~/\/:/.:%%##/::.#/\\:;;/:::::/######%##/..%:\/;:;:::;;/::;/\/:;###\#####\#%//~.%:\#%\%\:::/%%##%\##/.:\/..~%#%\~--
        /.#\;:.:#%%/:: :/.#\\;/:::::/:\##%###%/: :%%%\#\;;:;;/:::/.:\::####\##%##\/:/. #%%\###%\;/;\%###%\/  %%\:::%#\/

~- ~~~/::##\;::##/:::/:::#\#\;;;::/::#####%#/:;;;%%##\;:;;/;;;/~-:#\;#####\###/:/:;:;%%##\####\:;######/::;%%#\:/##/ :\\
     /;;;###\:;\/:;:;/;;:###\\;:;/:;;##\####/;;;:#####\:;/:::/;;;:#:\#####\##//;;;;:#####\##\\;:##\##/;:;:####\;#/;;:::
_ ___ ________________________ _____________________________________________________________________ ___________________
:     - ::% %/ ~-\:::  :::~  //  - :::%%-   -\ ::  %%%%/  \: :\:    ~/ %%  %/%% \::     % % %%//::%%- - :: :%%%%/:-\\
 ~    ~\/\:\     ~\ -  \/-:: -:    -  %   -% \..-:/\::: : :\: :-/\::%%%/% %%%-% -\~. :- -/-- ::\--   -% \  /\ .~-%-/ --
-        -~  \  -   ~~-- ~~  ~\ :\ ~ % /-%/  ~ - .:/ :/ ~\  -: \~  :-/-% --/   ~~// \ -~ :/:-- :  -% - ~    ~ ~~\/    -
    ~   ~  ~              ~     ..~~ :-~~       \/      - -~ ~  ~ -. %--/ -   /             - ..: ~--~             ~   - 
   ~            ~          ~~ ~  -~   -/                        -:   . - -   -- ~~   ~       ~   \  -      ~         ~ ~
~           ~   ~  ~     ~       ~   -    ~       ~             -      ~-  ~       ~       ~    ~               ~

~~       ~      ~         -           ~ ~ ~       ~     ~        ~  ~--    --           ~     ~~         -      -    ~ ~

                                         G L A C I A L   L A K E   S U R V E Y
                                           Plate VII  ·  Mt. Solitary Massif
                                      63° 27' N  ·  134° 18' W  ·  Elev. 3,960 ft
]==]

local art_l = [==[
                                                   -+-  4123 ft
                                                    /\
                                                   /  \
                                                  /   .\                 -+-  3687 ft
                                                 /:::%%%:\                /\
                            /\                  /....%%\\                /. \
         /\                /  \                /.::./%%#\#%\            /..%:\
        /.:\             /..:::#\       /\    /.:::: %%%%\%\    /\    /::  \%%\       /\
-~~~ ~ /.-%:\~ -~/\  -  ~/::.%%#%\ -~ ~/.%\~ /::::/::#%%%#\\  ~/.%\ ~ ~/::/%\##\ ~~  / %\  -
      /\..%%%\  /.:\   /:::::\/\%\   / ..#%\;;:;:/::;\##%#%##%/ .%\ /;::./:#####\   /\:%%\ 
~--~-/.:\:##%%#/:::::\~ /;:;:/::\#\-~/::;%%\;;;:/;;;;#\#####\/;;:###\;:;/:;###\#\  / :\%##\~
   //::#:\###/;;;;::#\//;:;;/;;#\##\/;::;#####\/;:;;##\####/;::;#####\/;;;####\#/;;;#:\###\
_ ___ ________________________ _____________________________________________________________
/   \\  %:/ %%\~  :::  \\:~  \:   -%/\::    -% /\  :::%%  %% \::    ~%~/\  :%%%-/%\     / %~
     \/..-- -  - ~/ - \:: ::--/ /   \ .   -: :::\:: /%% % %%--  -/ \::: \ %%% %-   \-:  /
         \/         ~     ~\ ~/    ~           - ::.\-- /% --   ~       --.- / ~~      ~ 

                           G L A C I A L   L A K E   S U R V E Y
                             Plate VII  ·  Mt. Solitary Massif
                        63° 27' N  ·  134° 18' W  ·  Elev. 3,960 ft
]==]

local art_m = [==[
                                             /\
                                            / .\
                                            /.:\
                         /\               /:./%:%\          /\
                        /.%\             /.:/:\%%%#\       /.:\
         /\            /  %:\    /\     /::/::%#%%#%\    /...%:\  /\
        /.#\          /  :##%\  /::\  /\../:;:##\###\ /\ /:.:%%%\/.\
--  ~- / ::#\-~-/\  ~/;::;###%#/:-##\/.#\/:;::%##\###/.#\:;::##%#\:###/\
      /;;;::\  /;#\ /:;;;:####/:;;##/;:#:\;::;####\#/:;##\:;;######\#/;#
_ ___ ________________________ _________________________________________
%      -::: :/ ~- %/ -~:::~  %%  --%%\::  - -: %%  /%\::  /: :%%     % :

                 G L A C I A L   L A K E   S U R V E Y
                   Plate VII  ·  Mt. Solitary Massif
]==]

local art_s = [==[
                           /\
                 /\       / %\        /\
         /\     /::\    /:: %\       /.:\    /\
 ~   /\ /.#\- /\ ::#\ ~ ~/:.###\ -/\/::::\~ /::\ /\
    /;#\;;##\/:#\;###\ /;;;:####\/::\;;###\/;;:#/;#\
_ ___ ________________________ _______________________
     \  /:: %/\~ /:%%   \:~  %%    ::/::   / : :%\ %/
~   -/ \.%/  --  ~ --  ~\ .%  /  ---  : - -\ :/ \/

        G L A C I A L   L A K E   S U R V E Y
]==]

local art_tiny = [==[
G L A C I A L   L A K E
    S U R V E Y
]==]

local tiers = {
  { art = art_xl },
  { art = art_l },
  { art = art_m },
  { art = art_s },
  { art = art_tiny },
}

local function measure(art)
  local lines = vim.split(art, "\n", { plain = true, trimempty = true })
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  return #lines, width
end

for _, tier in ipairs(tiers) do
  tier.height, tier.width = measure(tier.art)
end

local function overhead(gap)
  return 2 + KEYS + (KEYS - 1) * gap + 2 + EXTRA
end

local function pick()
  local columns, lines = vim.o.columns, vim.o.lines
  for _, tier in ipairs(tiers) do
    if tier.width <= columns - 2 and tier.height + overhead(0) <= lines then
      return tier.art, tier.height + overhead(1) <= lines and 1 or 0
    end
  end
  return art_tiny, 0
end

local function sections(gap)
  return {
    { section = "header", padding = 2 },
    { section = "keys", gap = gap, padding = 1 },
    { section = "startup" },
  }
end

local function refresh_dashboard()
  if vim.bo.filetype ~= "snacks_dashboard" or not Snacks or not Snacks.dashboard then
    return
  end
  local header, gap = pick()
  Snacks.config.dashboard.preset.header = header
  Snacks.config.dashboard.sections = sections(gap)
  Snacks.dashboard.open({ buf = vim.api.nvim_get_current_buf() })
end

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.schedule(refresh_dashboard)
  end,
})

local art, gap = pick()

return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "accept", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
      },
    },
  },
  {
    "folke/trouble.nvim",
    opts = {
      use_diagnostic_signs = true,
      auto_close = true,
      auto_preview = true,
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = { header = art },
        sections = sections(gap),
      },
    },
  },
}
