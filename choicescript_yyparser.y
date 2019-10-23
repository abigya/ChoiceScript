%{
	#include <stdlib.h>
	#include <stdio.h>
	void yyerror(char*);
	int yylex();
%}
%union{
	int i;
	double d;
	char *s;
}

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
%token YY_CS_AND
%token<s> YY_CS_STRING
%token<i> YY_CS_INT
%token<d> YY_CS_FLOAT
%token<s> YY_CS_CASE
%token YY_CS_PINDENT
%token YY_CS_NINDENT

%left YY_CS_AND YY_CS_LESS YY_CS_EQUAL YY_CS_GREATER YY_CS_ADD YY_CS_SUBTRACT YY_CS_DIVIDE YY_CS_MULTIPLY 

%start story

%%
story:
	assignment {puts("Assignment found");} story
	|choice {puts("Choice found");} story
	|goto {puts("Goto found");} story
	|label {puts("Label found");} story
	|conditional {puts("Conditional found");} story
	|;
	
assignment:
	   YY_CS_SET YY_CS_STRING arithmeticexpression;

conditional:
	    YY_CS_IF logicalexpression block elseifcontinuation elsecontinuation;
elsecontinuation:
		YY_CS_ELSE block
		|;
elseifcontinuation:
		   YY_CS_ELSEIF logicalexpression block elseifcontinuation
		   |;
block:
      YY_CS_PINDENT story YY_CS_NINDENT
      |YY_CS_PINDENT block YY_CS_NINDENT;		
arithmeticexpression:
	   YY_CS_INT
	   |YY_CS_FLOAT
	   |YY_CS_STRING
	   |arithmeticexpression arithmeticoperator arithmeticexpression;
arithmeticoperator:
		YY_CS_ADD
		| YY_CS_SUBTRACT
 		|YY_CS_DIVIDE
 		|YY_CS_MULTIPLY;
relationaloperator:
 		|YY_CS_GREATER
 		|YY_CS_LESS
 		|YY_CS_EQUAL
		;	
logicalexpression:
		  relationalexpression logicaloperator relationalexpression
		  |relationalexpression;
logicaloperator:
		YY_CS_AND;
relationalexpression:
		     arithmeticexpression relationaloperator arithmeticexpression; 	
choice: 
	YY_CS_CHOICE YY_CS_PINDENT YY_CS_PINDENT cases YY_CS_NINDENT YY_CS_NINDENT; 
cases:
	case cases
	| case;
case:
	YY_CS_CASE {puts("Case found");} YY_CS_PINDENT story  YY_CS_NINDENT;
goto:
	YY_CS_GOTO YY_CS_STRING;
label: 
	YY_CS_LABEL YY_CS_STRING;


	
	  
	
%%

