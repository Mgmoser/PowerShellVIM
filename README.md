# Introduction to VIM Motions for PowerShell Users

### With Andrew Pla and Mason Moser

Link to the PowerShell Wednesday's Video:


### VIM Introduction
______________________________________________________________   k
Move around:  Use the cursor keys, or "h" to go left,	       h   l
"j" to go down, "k" to go up, "l" to go right.              	 j
Close this window:  Use ":q<Enter>".
Get out of Vim:  Use ":qa!<Enter>" (careful, all changes are lost!).

#### There are 3 main modes:
	1) normal
		- Escape key always brings you back to normal mode.
		- i key puts you into insert mode
		- v key puts you into visual mode
		- The modes will always be displayed in the bottom left of your screen. Like a status indicator.
		- You can run commands from normal mode.
	2) insert
		- You insert text with in this mode, works as normal mostly.
	3) visual
		- Beginners will use this less at first.
		- Visual mode is useful because it allows you to highlight/select text (visually), then do something with it.

### Anatomy of a VIM shortcut command (in normal mode):

Command + Count + Motion

If you hit a command twice, it applies the command to the entire line of text. Ie. ```dd``` deletes the entire line of code.

### Common Commands:
d - delete
c - change
y - yank          -> We don't "copy" in vim. We "yank", cute right?
v - visual mode
x - deletes one letter
. - repeat last command

### Common Motions:

w - word
l -letter
$ - end of line
^ - beginning of line

### Wait Buffers? What's that?
Buffers are where your text goes automatically anytime you delete it or yank it. There are othertimes that this happens, but this is all you need to worry about now.

Hit ```dd``` to delete an entire line, move to a line you want to insert it, and then hit ```p``` and the deleted text will be pasted below your cursor.


### Tips:

Go to line = <number>G
Jump by word = w
Jump by back a word = b

### Editor Settings (These typically don't work in VSCode):
Set editor to include number lines = :set number
Set editor to include relative number lines = :set relativenumber


###

###

###

###

###

###

###

###

###

### Resources:

- Learn to type: https://www.keybr.com/
- Neovim Intallation Instructions: https://neovim.io/doc/install/

