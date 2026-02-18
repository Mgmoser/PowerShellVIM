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

Common Commands/operators:
d - delete
c - change
y - yank

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

List of Beautifyl Combinations (work with any of the d/c/y operators):

dw - delete word or 3dw, delete 3 words
d$ - delete from the cursor to the end of the line
dd - delete the entire line
dt<character> - delete to the character specified
di( - delete inside of the parentheses



#>
#Below are the tutorial exercises. They are seperated by many lines for the presentation.

#Navigate tutorial with below tips to make it easier to get to each exercise.

#   Go down half a page and/or up half a page with ctrl+d and ctrl+u.
#   Go to next occurence of space before a line with text or the next blank line after without text with shift+} and shift+{
#   In normal mode, hit 20j to go down 20 lines. This is probaly the easiest way to jump to the next exercise, but not the most efficeient.




















# ==========================================
# GROUP 1: BASIC NAVIGATION
# ==========================================




















#Exercise 1: Go to the beginning and end of a line. Use 0 or ^ to jump to the start, and $ to jump to the end.
#   0 = go to column 0 (very beginning of the line)
#   ^ = go to the first non-whitespace character
#   $ = go to the end of the line
#   zz = move your code to be centered around your cursor!
#   ctrl+u/d = scroll up or down half a page.
#   Try it on the long line below! Also, I hear Andrew Pla can navigate lines faster than anyone.

Write-Host "Hello $Name, you have $Count new messages. Also, I Andrew Pla can edit with VIM."




















#Exercise 2: Go to the top and bottom of the file. Use gg to go to the top, Shift+G to go to the bottom, and {number}G to go to a specific line.
#   gg = go to the first line of the file
#   G (Shift+G) = go to the last line of the file
#   10G = go to line 10
#   Try jumping to the bottom of this file with Shift+G, then come back here with gg.

Get-ChildItem -Path C:\Scripts -Recurse |
    Where-Object { $_.Extension -eq '.ps1' } |
    ForEach-Object { Write-Host "Found script: $($_.Name)" }




















# ==========================================
# GROUP 2: BASIC EDITING (Characters and Lines)
# ==========================================




















#Exercise 3: Delete a character with x. Place your cursor on the extra character and press x to delete it.
#   x = delete the character under the cursor
#   There are typos in the line below. Use x to fix them!

$messaage = "Helllo Worlld"
Write-Hostt $messaage




















#Exercise 4: Delete/Yank/Change a whole line with dd, yy, cc. (Clearly there is an error below, fix it with VIM!)
#   dd = delete the entire line (and yank it into the buffer)
#   yy = yank (copy) the entire line
#   p  = put (paste) the yanked/deleted line below your cursor
#   cc = change the entire line (deletes it and puts you in insert mode)
#   The Write-Output is before the variable assignment. Use dd to cut the line, move down, then p to paste it after.

Write-Output $variable
$variable = 'Hello VIM!'




















#Exercise 5: Undo and Redo. Make some changes to the code below, then undo them!
#   u = undo the last change
#   Ctrl+r = redo (undo the undo)
#   Try deleting a few words or lines below, then press u repeatedly to undo. Press Ctrl+r to redo.

function Get-Greeting {
    param([string]$Name)
    $timeOfDay = (Get-Date).Hour
    if ($timeOfDay -lt 12) {
        return "Good morning, $Name!"
    } else {
        return "Good afternoon, $Name!"
    }
}




















#Exercise 6: Open a new line with o and O. This is how you quickly add new lines of code without moving to the end and pressing Enter.
#   o = open a new line BELOW the current line and enter insert mode
#   O = open a new line ABOVE the current line and enter insert mode
#   The pipeline below is missing a Sort-Object step. Place your cursor on the Where-Object line, press o to open a line below it, and add:  Sort-Object CPU -Descending |

Get-Process |
    Where-Object { $_.CPU -gt 10 } |
    Select-Object Name, CPU, Id |
    Format-Table -AutoSize




















# ==========================================
# GROUP 3: WORD-LEVEL OPERATIONS
# ==========================================




















#Exercise 7: Delete a word with dw. Place your cursor at the start of the word you want to remove and type dw.
#   dw = delete from cursor to the start of the next word
#   d2w = delete two words
#   Remove the EXTRAWORD words from the pipeline below to fix the command.

Get-Process EXTRAWORD | Where-Object EXTRAWORD { $_.CPU -gt 50 } | Select-Object EXTRAWORD Name, CPU, Id




















#Exercise 8: Delete or change to the end of the line with D or C. Very useful for changing the tail end of a pipeline or parameter value.
#   D = delete from cursor to end of line (same as d$)
#   C = change from cursor to end of line (same as c$, drops you into insert mode)
#   The commands below have wrong endings. Place your cursor on the part that's wrong and press C to fix them.

Get-Service -Name 'wuauserv' | Restart-Service -Force -WrongParameter -Bogus
Get-EventLog -LogName Application -Newest 50 | Where-Object { $_.EntryType -eq 'Error' } | Export-Csv -Path C:\wrong\path\here.csv




















#Exercise 9: Change a word with cw. Place your cursor on the first letter of the word you want to change and type cw.
#   cw = delete the word and drop you into insert mode so you can type the replacement
#   You know the one you want to change... Andrew Pla has something to say.

Write-Host "Hello $Name, you have $Count new messages. Also, I Andrew Pla cannot edit with VIM."




















#Exercise 10: Repeat your last command with the dot key (.). Do a change once, then just press . to repeat it!
#   . = repeat the last change you made
#   The function below has the wrong verb. Use cw on the first "Receive" to change it to "Get", press Escape, then move to the next "Receive" and just press . to repeat.

function Receive-ServerStatus {
    $servers = @('Server01', 'Server02', 'Server03')
    foreach ($server in $servers) {
        $status = Receive-CimInstance -ClassName Win32_OperatingSystem -ComputerName $server
        Write-Host "$server last boot: $($status.LastBootUpTime)"
    }
}
Receive-ServerStatus




















# ==========================================
# GROUP 4: SEARCH AND NAVIGATION
# ==========================================




















#Exercise 11: Find text with / (this replaces Ctrl+F in most editors).
#   / = start a forward search, then type your search term and hit Enter
#   n = jump to the next match
#   N (Shift+n) = jump to the previous match
#   Try searching for "Andrew" by typing /Andrew and pressing Enter. Then press n to cycle through all the matches.
#   In one line you can jump to a match by hitting f<character to jump to> or t<character to jump to>
#   f jumps onto the character, t jumps just in front of the character. I like f, but both are useful and you can think of f as "find" and t as "to"
#   after using f or t, you can hit ; to jump to the next match of the same character, or , to jump to the previous match of the same character.

$presenters = @('Andrew Pla', 'Mason Moser')
foreach ($presenter in $presenters) {
    Write-Host "$presenter is presenting today!"
}
$organizer = 'Andrew Pla'
Write-Host "Special thanks to $organizer for co-hosting this talk!"
$topic = 'VIM Motions for PowerShell'
Write-Host "Andrew Pla and Mason Moser welcome you to $topic"




















#Exercise 12: Jump to the matching bracket with %. Place your cursor on any (, {, or [ and press % to jump to its match.
#   % = jump to the matching parenthesis, bracket, or brace
#   This is extremely useful when navigating nested PowerShell code.

$listOfNumbers = 1, 2, 3, 4, 5

foreach ($number in $listOfNumbers) {
    if ($number -gt 3) {
        Write-Host "$number is greater than 3"
    } else {
        Write-Host "$number is 3 or less"
    }
}




















# ==========================================
# GROUP 5: CHANGE/DELETE INSIDE DELIMITERS
# ==========================================




















#Exercise 13: Change or delete inside quotes, braces, and parentheses with ci", ci{, di(, etc. This is a game-changer for PowerShell.
#   ci" = change inside double quotes (deletes the string contents and drops you into insert mode)
#   ci' = change inside single quotes
#   ci{ = change inside curly braces (the scriptblock contents)
#   ci( = change inside parentheses
#   di" = delete inside double quotes (empties the string)
#   The "i" stands for "inside". You can also use "a" for "around" which includes the delimiters themselves.
#   Try ci" on the wrong message below to fix it. Then try ci{ on the scriptblock to replace its body.

$errorMessage = "Something went horribly wrong with the flux capacitor"
Write-Error $errorMessage

$action = { Get-ChildItem -Path C:\OldPath -Recurse | Remove-Item -Force }
Invoke-Command -ScriptBlock $action

Get-ADUser -Filter { Department -eq "WrongDepartment" } | Set-ADUser -Department "IT"




















# ==========================================
# GROUP 6: COPY, PASTE, AND DUPLICATION
# ==========================================




















#Exercise 14: Yank and put lines to duplicate them. Use yy to copy a line, then p to paste it below.
#   yy = yank (copy) the current line
#   p  = put (paste) below the current line
#   Use yy on one of the existing parameters, then p to paste copies. Edit each copy to create new parameters.

function New-Person{
	[CmdletBinding()]
	#Add parameters: Height, Skills, FavoriteFood
	param(
		[string]$Name,
		[int]$Age
	)

	[PSCustomObject]@{
		Name = $Name
		Age = $Age
	}

}




















# ==========================================
# GROUP 7: VISUAL MODE AND INDENTATION
# ==========================================




















#Exercise 15: Select lines with V (visual line mode) and indent or dedent them with > and <.
#   V = enter visual line mode (selects entire lines)
#   > = indent the selected lines one level
#   < = dedent (unindent) the selected lines one level
#   The code below was pasted without indentation. Select the body of the function with V, extend your selection with j, then press > to indent.
#   You can press . to repeat the indent if you need more levels.

function Get-DiskSpace {
param([string]$ComputerName = $env:COMPUTERNAME)
$disks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $ComputerName
foreach ($disk in $disks) {
$freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
$totalGB = [math]::Round($disk.Size / 1GB, 2)
Write-Host "$($disk.DeviceID) - Free: ${freeGB}GB / Total: ${totalGB}GB"
}
}




















# ==========================================
# GROUP 8: NUMBERS AND CASE
# ==========================================




















#Exercise 16: Increment and decrement a number. Place your cursor on a number and press Ctrl+a to increment, Ctrl+x to decrement.
#   Ctrl+a = increment the number under (or after) the cursor by 1
#   Ctrl+x = decrement the number under (or after) the cursor by 1
#   This works with a count too! 5 Ctrl+a increments by 5.
#   Try incrementing and decrementing the numbers below.

$retryCount = 3
$maxConnections = 10
$timeoutSeconds = 30




















#Exercise 17: Toggle case. Use ~ to toggle a single character, gUU to uppercase a whole line, guu to lowercase a whole line.
#   ~ = toggle the case of the character under the cursor (and move right)
#   gUU = make the entire line UPPERCASE
#   guu = make the entire line lowercase
#   Fix the casing on the lines below.

$environment = "PRODUCTION"
$LOGLEVEL = "debug"
write-host "Deploying to $environment with log level $LOGLEVEL"




















# ==========================================
# GROUP 9: ADVANCED
# ==========================================




















#Exercise 18: Substitute text across the file. Use :%s/old/new/g to replace all occurrences in the file.
#   :s/old/new    = replace first occurrence of "old" with "new" on the current line
#   :s/old/new/g  = replace ALL occurrences on the current line
#   :%s/old/new/g = replace ALL occurrences in the ENTIRE file
#   The variable below is poorly named. Use :%s/\$x/\$computerName/g to rename it everywhere.

$x = Get-Content -Path "C:\servers.txt"
foreach ($entry in $x) {
    Test-Connection -ComputerName $entry -Count 1 -ErrorAction SilentlyContinue |
        ForEach-Object { Write-Host "Ping to $entry ($x): $($_.ResponseTime)ms" }
}
Write-Host "Checked all entries in `$x"
