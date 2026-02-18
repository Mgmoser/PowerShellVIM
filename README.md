# Introduction to VIM Motions for PowerShell Users

### With Andrew Pla and Mason Moser

Link to the PowerShell Wednesday's video:
- Add recording link here

## Start Here (If You've Never Used Vim)

Move around with arrow keys, or with Vim movement keys:
- `h` = left
- `j` = down
- `k` = up
- `l` = right

Basic exit commands:
- Close current window: `:q<Enter>`
- Exit Vim without saving: `:qa!<Enter>` (careful, all changes are lost)

## The 3 Main Modes

1. **Normal mode**
   - `Esc` always gets you back to normal mode
   - `i` enters insert mode
   - `v` enters visual mode
   - Modes are shown at the bottom-left status area
   - You run most Vim commands from normal mode
2. **Insert mode**
   - This is where you type text normally
3. **Visual mode**
   - Beginners use this less at first
   - Useful for selecting text, then doing something with that selection

## Anatomy of a Vim Motion

In normal mode, most editing actions are:

`Command + Count + Motion`

Example:
- `dd` deletes a full line (same operator pressed twice applies to the whole line)

## Common Commands (Operators)

- `d` = delete
- `c` = change
- `y` = yank (we do not "copy" in Vim, we "yank"... cute right?)
- `v` = visual mode
- `x` = delete one character
- `.` = repeat last command

## Common Motions

- `w` = move forward by word
- `b` = move back by word
- `l` = move right by letter
- `0` = very beginning of line (column 0)
- `^` = first non-whitespace character on the line
- `$` = end of line

Useful combinations:
- `dw` = delete word
- `d$` / `D` = delete to end of line
- `dt<char>` = delete up to a specific character
- `cw` = change word
- `C` = change to end of line
- `ci"` / `ci{` / `ci(` = change inside delimiters
- `di"` / `di(` = delete inside delimiters

## Wait... Buffers? What's That?

Buffers are where deleted/yanked text goes automatically.

Types you should know:
- **Default buffer**: acts like your automatic clipboard
- **Other automatic buffers**: Vim keeps a few histories for you automatically
- **Named buffers**: you can intentionally store text in named slots for later use

Quick example:
1. `dd` to delete a line
2. Move cursor
3. `p` to put (paste) it below

## Core Navigation

- Go to top of file: `gg`
- Go to bottom of file: `G`
- Go to line: `{number}G`
- Jump by word: `w`
- Jump back by word: `b`
- Jump quickly by count: `20j` (move down 20 lines)
- Match bracket/brace/paren: `%`
- Find text: `/searchTerm` (this is your Vim version of `Ctrl+F`)
- Scroll half page down/up: `Ctrl+d` / `Ctrl+u`
- Jump to next/previous paragraph-ish block: `Shift+}` / `Shift+{`
- Center cursor line on screen: `zz`

## Editor Settings (Often Not Supported in VSCode Vim)

- Show line numbers: `:set number`
- Show relative numbers: `:set relativenumber`

## Exercise Outline (Concise)

The full guided exercises live in `learn_VIM_Motions_for_PowerShell.ps1`.

Beginner progression:
1. **Movement and positioning**
   - Start/end of line (`0`, `^`, `$`)
   - Top/bottom/specific line (`gg`, `G`, `{n}G`)
   - Navigation helpers (`20j`, `Ctrl+d`, `Ctrl+u`, `Shift+}`, `Shift+{`, `zz`)
2. **Basic edits**
   - Delete character (`x`)
   - Line ops (`dd`, `yy`, `cc`, `p`)
   - Undo/redo (`u`, `Ctrl+r`)
   - Open new lines (`o`, `O`)
3. **Operator + motion fluency**
   - `dw`, `D`, `C`, `cw`, `dt<char>`, `.`
4. **Search and structure**
   - `/` search (replace the usual editor `Ctrl+F` flow)
   - `%` matching delimiters
   - Inside delimiters (`ci"`, `ci{`, `di(`)
5. **Productivity and formatting**
   - Duplicate lines (`yy`, `p`)
   - Visual line mode (`V`) and indent/dedent (`>`, `<`)
   - Number increment/decrement (`Ctrl+a`, `Ctrl+x`)
   - Case toggles (`~`, `gUU`, `guu`)
   - Substitute in file (`:%s/old/new/g`)

## Installation and Setup (Beginner-Friendly)

If you are brand new, run the guided installer script first:
- `buildNeovimInAnyOS.ps1`

What it covers:
- Detects OS and available package manager
- Confirms install command before running
- Handles common elevation/admin cases
- Checks whether `nvim` is in `PATH`
- Offers optional health check
- Offers optional starter config install (with backup if config exists)
- Provides troubleshooting tips if something fails

Official Neovim install docs:
- https://neovim.io/doc/install/

## Resources

- Learn to type faster: https://www.keybr.com/
- Official Neovim install instructions: https://neovim.io/doc/install/

