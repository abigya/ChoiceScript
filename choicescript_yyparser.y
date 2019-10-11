%{
	#include <stdlib.h>
	#include <stdio.h>
	void yyerror(char*);
	int yylex();
%}

%token YY_CS_CHOICE			
%token YY_CS_GOTO_SCENE			     
%token YY_CS_GOTO	    
%token YY_CS_LABEL
%token YY_CS_FINISH
%token YY_CS_CREATE
%token YY_CS_SET
%token YY_CS_IF
%token YY_CS_ELSE
%token YY_CS_ELSEIF
%token YY_CS_SCENE_LIST
%token YY_CS_IMAGE
%token YY_CS_LINE_BREAK
%token YY_CS_INPUT_TEXT
%token YY_CS_INPUT_NUMBER
%token YY_CS_RAND
%token YY_CS_STAT_CHART
%token YY_CS_BUG
%token YY_CS_PAGE_BREAK
%token YY_CS_HIDE_REUSE
%token YY_CS_DISABLE_REUSE
%token YY_CS_GOSUB_SCENE
%token YY_CS_GOSUB
%token YY_CS_RETURN
%token YY_CS_ENDING
%token YY_CS_LINK
%token YY_CS_ADD
%token YY_CS_SUBTRACT
%token YY_CS_DIVIDE
%token YY_CS_MULTIPLY
%token YY_CS_GREATER
%token YY_CS_LESS
%token YY_CS_EQUAL
%token YY_CS_STRING
%token YY_CS_INT
%token YY_CS_FLOAT
%token YY_CS_CASE
%token YY_CS_PINDENT
%token YY_CS_NINDENT
%token YY_CS_NOINDENT


%start story
%%
story:
	assignment {puts("Assignment found");} story
	|choice {puts("Choice found");} story
	|goto {puts("goto found");} story
	|;
	
assignment:
	   YY_CS_SET YY_CS_STRING expression;
expression:
	   YY_CS_INT
	   | YY_CS_FLOAT;
choice: 
	YY_CS_CHOICE YY_CS_PINDENT cases YY_CS_NINDENT;
cases:
	case cases
	| case;
case:
	YY_CS_CASE YY_CS_PINDENT story {puts("Case found");} YY_CS_NINDENT;
goto:
	YY_CS_GOTO YY_CS_STRING;
	
	  
	
%%

