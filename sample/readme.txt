*label Label
*choice
	#label 
		The label command is strictly used only as a reference. It is an Oval box with a checkmark and a name of the label like this \Ovalbox{$\surd$\label{label}}. Follow the labels in the page to read about a specific type of command.

*label Choices
*choice
	#choice
		The choice command is the fundamental command of ChoiceScript, defining the options by which the reader interacts with the story.Ordinary (non-conditional) options are preceded by the hash \# symbol. 

	#fake\_choice
		The fake\_choice command is an alternative to the choice command. To the reader, a [i]choice[/i] and a [i]fake\_choice[/i] appear identical. It does not actually require the use of any 	other commands within the body of the \#options text.

*label Conditionals
*choice
	#if
		The if conditional command compares variables (including textual string variables),checks if a variable is true or not, and checks if the value of a numeric variable is equal to, not equal to, greater than, or less than, a specific value.
	#elseif
		The elseif command (also spelled elsif) is only used after an [i]if[/i] command to specify an alternative if the initial [i]if[/i] condition fails. 

	#else
		The else command is only ever used in combination with the [i]if[/i] command, and sometimes also including the [i]elseif[/i] command.

*label Assignments
*choice 
	#create
		The create command is used to declare the permanent variables your book will use to reference and store its data, such as character statistics and other information pertinent to your book. The variables can only be created in the beggining of the story.
	#set
		The set command is used for assigning a new value to a variable, or modifying the value of a variable to something else. It can be used for both temporary variables and permanent variables.

*label Scenes
*line_break
The scenes in this book are referenced by a page number. If you see a [b]Go to Chapter[/b],it will take you to a different scene in the story. 
*line_break
*choice
	#scene\_list
		The scene\_list command is used to create a chronological list of all the scenes in the book, so that it may be referenced by commands such as [i]finish.[/i] This command is exclusive to the beginning of the story and cannot be used in any other scene.  
	#goto
		The goto command is used for jumping from one line to another within the same scene in the story.
	#goto\_scene
		The goto\_scene command allows you to jump to any scene in the story. The called scene is referenced by a page number to that chapter.  
	#goto\_random\_scene
		The goto\_random\_scene command is an easy means of directing the story to a scene selected completely at random, choosing from a specified list of available scenes not necessarily defined in the beginning of the story.
	#gosub
		The gosub command supports a simple form of subroutines. A subroutine is a section of the story able to be accessed where and when required at many different points within the same scene file.
	#gosub\_scene
		The gosub\_scene is an extension of the basic [i]gosub[/i] command. It grants the ability to go to a subroutine from any scene in the story.

*label Break
*choice
	#finish
		The finish command is one of two commands by which you are able to move the story on from one scene to the next, the other being [i]goto\_scene.[/i] 
	#return
		The return command takes you back to the scene where you left off if you chose to follow a subroutine and go to different scenes.

*label Ending
*choice
	#ending
		The ending command is intended to be used at the end of the story, whether the actual, final scene end or in the event of character death or inability to continue in the story for some other reason.

*label Bookmark
*choice
	#show\_password
		The show\_password command is used as a bookmark in the story when you want to save your progress. At the bottom of each chapter, there will be a checkpoint to ask if you have left a bookmark at that page. 
	#restore\_game
		The restore\_game command is used as a continuation point. At the bottom of each chapter, there will be a checkpoint to ask if you will be removing the bookmark from that chapter and reading the rest of the story.

*label MoreStories
*choice
	#more\_games
		The more\_games command adds a clickable link entitled Play more games like this! When clicked, it will redirect the player to this page: 
		*link http://www.choiceofgames.com/category/our-games/
	#share\_this\_game
		The share\_this\_game command encourages you to share the story with your friends!

*label Miscellaneous
*choice
	#image
		The image command adds a image to the story.
	#line\_break
		The line\_break command adds a new line in the text.
	#page\_break
		The page\_break command adds a new page in the story.
	#bug
		The bug command allows you to correct a mistake if you have forgotten to make a choice!
	#achieve
		The achieve command awards the reader with a pre-defined Achievement at a particular point in the story.  
	#link
		The link command adds a clickable link in the story.
	#title
		The title command gives a title to the story, usually in the front page of the book.
	#author
		The author command gives the name of the author, usually in the front page of the book.

*label Important
*choice
	#Limitations	
		This project does not support all ChoiceScript commands.
	#ThisProject 
		To learn more about how this project, what is missing or being added, go to: 
		*link https://github.com/abigya/ChoiceScript
		*line_break
	#ChoiceScript
		To learn more about ChoiceScript, go to:
		*link https://choicescriptdev.fandom.com/wiki/Choice
		*line_break 




