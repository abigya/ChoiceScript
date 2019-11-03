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
%token YY_CS_AND
%token<s> YY_CS_STRING
%token<s> YY_CS_VAR
%token<i> YY_CS_INT
%token<d> YY_CS_FLOAT
%token<s> YY_CS_CASE
%token YY_CS_PINDENT
%token YY_CS_NINDENT
%token YY_CS_BEGINBOLD
%token YY_CS_ENDBOLD
%token YY_CS_BEGINITALICS
%token YY_CS_ENDITALICS
%token YY_CS_TITLE
%token YY_CS_AUTHOR

%left '+' '-' '/' '*'
%left '<' '=' '>'
%left YY_CS_AND

%start book

%%
book:
	{puts("\\documentclass{book}");
         puts("\\begin{document}");
        puts("\\date{}");}
	preamble {puts("\\maketitle");}
        story {puts("\\end{document}");};
preamble:
	title author 
	|author title
	|title
	|author; 
title:
	YY_CS_TITLE {puts("\\title{");} vars {fputs("}",stdout);};
author:
	YY_CS_AUTHOR {puts("\\author{");} vars {fputs("}",stdout);};
	
story:
	  assignment {puts("%Assignment found");} story
	| choice {puts("%Choice found");} story
	| label {puts("%Label found");} story
	| conditional {puts("%Conditional found");} story
	| tagged-word story
	| scenelist story
	| %empty;
scenelist:
          YY_CS_SCENE_LIST blockofwords;

blockofwords: YY_CS_PINDENT blockofwords YY_CS_NINDENT
        | YY_CS_PINDENT words YY_CS_NINDENT;
words:
	YY_CS_STRING{puts($1);} words
	| YY_CS_STRING{puts($1);};
vars:
	YY_CS_VAR{puts($1);} vars
	| YY_CS_VAR{puts($1);};
tagged-word:
	      YY_CS_STRING {puts($1);} 
	      | YY_CS_BEGINBOLD {puts("{\\bf");} tagged-string YY_CS_ENDBOLD {fputs("}",stdout);}
	      | YY_CS_BEGINITALICS {puts("{\\it");}tagged-string YY_CS_ENDITALICS {fputs("}",stdout);};
             
tagged-string:
		tagged-word tagged-string
		| %empty;
		
break:
    YY_CS_FINISH {puts("%Finish found");}
  | goto         {puts("%Goto found");}
  | goto-scene   {puts("%Goto-scene found");}
  | %empty ;

assignment:
	   YY_CS_SET YY_CS_VAR arithmetic-expression;

conditional:
    YY_CS_IF logical-expression block else-if-continuation else-continuation;

else-if-continuation:
    YY_CS_ELSEIF logical-expression block else-if-continuation
  | %empty ;

else-continuation:
	     YY_CS_ELSE block
	   | %empty;

block:
        YY_CS_PINDENT story break YY_CS_NINDENT 
      | YY_CS_PINDENT block YY_CS_NINDENT ;

arithmetic-operator:
		  '+'
		| '-'
 		| '/'
 		| '*';

relational-operator:
 		  '>'
		| '<'
 		| '='
		;

logical-operator:
		YY_CS_AND;

arithmetic-expression:
             arithmetic-term arithmetic-remainder;

arithmetic-term:
	     YY_CS_INT
	   | YY_CS_FLOAT 
	   | YY_CS_VAR
	   | '(' arithmetic-expression ')'
	   | YY_CS_VAR '(' params ')' /* Function call */
	   ;

params:
             arithmetic-expression ',' params
           | %empty ;

arithmetic-remainder:
	     arithmetic-operator arithmetic-expression
	   | %empty ;

logical-expression:
	  relational-expression logical-operator relational-expression
	| relational-expression;

relational-expression:
         arithmetic-expression relational-operator arithmetic-expression
       | '(' relational-expression ')' ;

choice: 
	YY_CS_CHOICE {puts("\\begin{description}");}block-cases {puts("\\end{description}");};

block-cases:
        YY_CS_PINDENT cases YY_CS_NINDENT
      | YY_CS_PINDENT block-cases YY_CS_NINDENT;

cases:
	case cases
	| case;

case:
	YY_CS_CASE {printf("\\item[%s]\n",$1);}block {puts("%Case found");};

goto:
	YY_CS_GOTO YY_CS_VAR  {printf("To continue, go to page \\pageref{%s}.\n",$2);};

goto-scene:
	YY_CS_GOTO_SCENE YY_CS_VAR;

label: 
	YY_CS_LABEL YY_CS_VAR {printf("\\newpage\n\\marginpar{Label ``%s''}\\label{%s}\n\n",$2,$2);};

%%

