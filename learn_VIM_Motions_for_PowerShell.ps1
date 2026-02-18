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
It's where the text goes when you delete or yank it. You can have multiple buffers:
- Default buffer (acts like a clipboard, but data enters it automatically)
- Some other automatic buffers.
- Named buffers (you can name them and use them to store text for later use)


Common Motions:
w - word
l -letter
$ - end of line
^ - beginning of line where the text starts
0 - beginning of line



#>
#Below are the tutorial exercises. They are seperated by many lines for the presentation.

#Navigate tutorial with below tips to make it easier to get to each exercise.

#   Go down half a page and/or up half a page with ctrl+d and ctrl+u.
#   Go to next occurence of space before a line with text or the next blank line after without text with shift+} and shift+{
#   In normal mode, hit 20j to go down 20 lines. This is probaly the easiest way to jump to the next exercise, but not the most efficeient.






















#Delete/Yank/Change a whole line. dd/yy/cc  (Clearly there is an error below, fix it with VIM!)

Write-Output $variable
$variable = 'Hello VIM!'
























#Create a multiple parameters in the param block to reduce typing.

param(
	[string]$Name,
	[int]$Count
)














#Change a word. You know the one you want to change...

Write-Host "Hello $Name, you have $Count new messages. Also, I Andrew Pla cannot edit with VIM."




















#Go to begginning of a line and the end of the line.

Write-Host "Hello $Name, you have $Count new messages. Also, I Andrew Pla can edit with VIM."

















#Go to the next ({[]}) with %


$listOfNumbers = 1, 2, 3, 4, 5

foreach ($number in $listOfNumbers) {
	Write-Host [string]$number
}















#Go to the bottom of the page. - shift+G

#Find text (ctrl+f replacement)
#   - all you need to do is hit the / and type what you want to search for.
#   - Next, hit enter to select the pattern.
#   - After hitting enter, you can hit n to go to the next occurence of the pattern and shift+n to go to the previous occurence of the pattern.

#Increment a number one digit. (ctrl+a)
#(This works with a count too!)
#1

#De-increment a number one digit. (ctrl+x)
#96

#Capitalize a letter with ~.

#Capitalize all the letters in the line with gUU.

#Lowercase all the letters in the line with guu.

#Surround code with characters.
#Change a variable everywhere in the file.
# Requires a command