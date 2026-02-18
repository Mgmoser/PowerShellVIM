<#
                                            									 k
Move around:  Use the cursor keys, or "h" to go left,	       h   l
"j" to go down, "k" to go up, "l" to go right.              	 j
Close this window:  Use ":q<Enter>".
Get out of Vim:  Use ":qa!<Enter>" (careful, all changes are lost!).

There are 3 main modes:
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

Anatomy of a motion:

Command + Count + Motion

We don't "copy" in vim. We "yank", cut right?

Common Commands:
d - delete
c - change
y - yank
v - visual mode

Wait Buffers? What's that?

Common Motions:


Set editor to include number lines = :set number
Set editor to include relative number lines = :set relativenumber

Tips:

Go to line = <number>G
Jump by word = w
Jump by back a word = b

}

#>
#Delete/Yank/Change a whole line. dd/yy/cc

#Create a multiple parameters in the param block to reduce typing.

param(
	[string]$Name,
	[int]$Count
)

#Change a word.

#Go to begginning of a line and the end of the line.

#Change a variable everywhere in the file.

#Surround code with characters.

#Go to the next ({["'"]}) with %

#Go down half a page and/or up half a page.

#Go to the bottom of the page.

#Find text (ctrl+f replacement)

#Jump to the next blank line.

#Increment a number one digit. (ctrl+a)
#(This works with a count too!)
#1

#De-increment a number one digit. (ctrl+x)
#96

#Capitalize a letter with ~.

#Capitalize all the letters in the line with gUU.

#Lowercase all the letters in the line with guu.
