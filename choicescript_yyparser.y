/**@file choicescript_yyparser.y */
/**@author Abigya Devkota and Dmitry Zinoviev*/
/**@date December 3, 2019*/
/**@brief Yacc file with grammar rules*/
%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	void yyerror(char*);
	void import(char*);
        void *safe_malloc(size_t size);
	int yylex();
	int level = 0; /* Are we at the top level? */
	static const char* STARTUP_NAME = "startup";
	extern FILE *OUTPUT;
  	extern FILE *yyout;
	static char *allscenes[10] = {NULL}; /*should there be a limit on the number of scenes ?*/
        static int count = 0;
%}

%code requires {
  extern int level;
  typedef struct slist {
    char *s;
    struct slist *next; } slist;
}

%union{
	int i;
	double d;
	char *s;
	slist *slist;
}

%token YY_AND
%token YY_AUTHOR
%token YY_BEGINBOLD
%token YY_BEGINITALICS
%token YY_BUG
%token YY_CHOICE
%token YY_FAKE_CHOICE			
%token YY_CREATE
%token YY_DISABLE_REUSE
%token YY_ALLOW_REUSE
%token YY_ELSE
%token YY_ELSEIF
%token YY_ENDBOLD
%token YY_ENDING
%token YY_ENDITALICS
%token YY_FINISH
%token YY_GOSUB
%token YY_GOSUB_SCENE
%token YY_GOTO	    
%token YY_GOTO_SCENE	
%token YY_GOTO_RANDOM_SCENE		     
%token YY_HIDE_REUSE
%token YY_IF
%token YY_IMAGE
%token YY_INPUT_NUMBER
%token YY_INPUT_TEXT
%token YY_LABEL
%token YY_LINE_BREAK
%token YY_LINK
%token YY_NINDENT
%token YY_PAGE_BREAK
%token YY_PINDENT
%token YY_RAND
%token YY_RETURN
%token YY_SCENE_LIST
%token YY_SET
%token YY_STAT_CHART
%token YY_TITLE
%token YY_URL
%token<d> YY_FLOAT
%token<i> YY_INT
%token<s> YY_CASE
%token<s> YY_STRING
%token<s> YY_VAR
%type<slist> scenes blockofscenes

%left '+' '-' '/' '*'
%left '<' '=' '>'
%left YY_AND

%start book

%%
book: {
  if (level == 0) { /* Are we in startup.txt? */
    fprintf(OUTPUT,"\\documentclass{book}\n");
    fprintf(OUTPUT,"\\usepackage{hyperref}\n");
    fprintf(OUTPUT,"\\usepackage{fancybox}\n");
    fprintf(OUTPUT,"\\usepackage{enumitem}\n");
    fprintf(OUTPUT,"\\usepackage{graphicx}\n");
    fprintf(OUTPUT,"\\begin{document}\n");
    fprintf(OUTPUT,"\\date{}\n");}
 } preamble {
	if (level==0){
   		fprintf(OUTPUT,"\\maketitle\n");
   		fprintf(OUTPUT,"\\label{__START__}");	
	}
 } story {
   if (level == 0) { /* Are we in startup.txt? */
     fprintf(OUTPUT,"\\end{document}\n");
   }
 };

preamble:
	title author 
	|author title
	|title
	|author
	|%empty;

title:
	YY_TITLE {fputs("\\title{",OUTPUT);} vars {fputs("}", OUTPUT);};
author:
	YY_AUTHOR {fputs("\\author{",OUTPUT);} vars {fputs("}", OUTPUT);};
	
story:
	  assignment {fprintf(yyout,"Assignment found\n");} story
	| choice story
	| fake-choice story
	| label story
	| conditional {fprintf(yyout,"Conditional found\n");} story
	| tagged-word story
	| scenelist story
	| link story
	| page_break story
	| line_break story
        | goto story
	| image story
  	| goto-scene   {fprintf(yyout,"Goto-scene found\n");}story
	| goto-random-scene   {fprintf(yyout,"Goto-random-scene found\n");}story
  	| gosub         {fprintf(yyout,"gosub found\n");}story
	| gosub-scene   {fprintf(yyout,"gosub-scene found\n");}story
        | ending {fprintf(yyout, "Ending found\n");} story
	| YY_HIDE_REUSE {fprintf(yyout,"Hide Reuse found\n");} story
	| YY_DISABLE_REUSE {fprintf(yyout,"Hide Disable found\n");} story
	| %empty;

scenelist:
  YY_SCENE_LIST blockofscenes {
    for (slist *start = $2; start; start = start->next){
      if (strcmp(start->s, STARTUP_NAME)) {
	  fprintf(OUTPUT,"\\uppercase{\\chapter{%s}}\\label{%s}\n", start->s, start->s);
	  allscenes[count] = start->s;
          fprintf(yyout,"%s was imported\n",allscenes[count]);
	  count ++;
	  import(start->s);
	}
    }
    fprintf(OUTPUT,"\\chapter{Main Matter}\n");
  };

blockofscenes:
        YY_PINDENT blockofscenes YY_NINDENT { $$ = $2; }
        | YY_PINDENT scenes YY_NINDENT { $$ = $2; };

scenes:
        YY_STRING scenes { $$ = safe_malloc(sizeof(slist));
	  $$->s = $1; $$->next = $2; }
        | YY_STRING { $$ = safe_malloc(sizeof(slist));
	  $$->s = $1; $$->next = NULL; };

vars:
	YY_VAR{fprintf(OUTPUT,"%s\n",$1);} vars
	| YY_VAR{fprintf(OUTPUT,"%s\n",$1);};

tagged-word:
	      YY_STRING {fprintf(OUTPUT,"%s\n",$1);} 
	      | YY_BEGINBOLD {fputs("{\\bf ",OUTPUT);} tagged-string YY_ENDBOLD {fputs("}",OUTPUT);}
	      | YY_BEGINITALICS {fputs("{\\it ",OUTPUT);} tagged-string YY_ENDITALICS {fputs("}",OUTPUT);};
             
tagged-string:
		tagged-word tagged-string
		| %empty;
	
break:
     YY_FINISH { fprintf(OUTPUT,"$\\diamondsuit$\n\n"); /* Needs work! */} 
   | YY_RETURN { fprintf(OUTPUT,"\n{\\it Go back and continue reading}~$\\hookleftarrow$\n\n"); }
   | %empty ;

assignment:
	   YY_SET YY_VAR arithmetic-expression
	   | YY_CREATE YY_VAR arithmetic-expression;

conditional:
           YY_IF logical-expression { fprintf(OUTPUT,"xxx~?~$\\Rightarrow$"); } block else-if-continuation else-continuation;

else-if-continuation:
    YY_ELSEIF logical-expression { fprintf(OUTPUT,"xxx~??~$\\Rightarrow$"); } block else-if-continuation
  | %empty ;

else-continuation:
	     YY_ELSE  { fputs("!~$\\Rightarrow$",OUTPUT); } block
	   | %empty;

block:
        YY_PINDENT story break YY_NINDENT 
      | YY_PINDENT block YY_NINDENT ;

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
		YY_AND;

arithmetic-expression:
             arithmetic-term arithmetic-remainder;

arithmetic-term:
	     YY_INT
	   | YY_FLOAT 
	   | YY_VAR
	   | '(' arithmetic-expression ')'
	   | YY_VAR '(' params ')' /* Function call */
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
	YY_CHOICE {fprintf(OUTPUT,"\\begin{description}[style=nextline]");}
        block-cases {fprintf(OUTPUT,"\\end{description}");};

fake-choice: 
	YY_FAKE_CHOICE {fprintf(OUTPUT,"\\begin{description}[style=nextline]");}
        block-cases {fprintf(OUTPUT,"\\end{description}");};
block-cases:
        YY_PINDENT cases YY_NINDENT
      | YY_PINDENT block-cases YY_NINDENT;

cases:
	case cases
	| case;

case:
        YY_CASE {fprintf(OUTPUT,"\\item[%s]\n", $1);} block
	|YY_HIDE_REUSE  YY_CASE {fprintf(OUTPUT,"\\item[%s~\\Ovalbox{(~~)}]\n", $2);} block
	|YY_DISABLE_REUSE  YY_CASE {fprintf(OUTPUT,"\\item[%s~\\Ovalbox{(~~)}]\n", $2);/*needs improvement*/} block
	|YY_ALLOW_REUSE  YY_CASE {fprintf(OUTPUT,"\\item[%s]\n", $2);/*This needs work*/} block;

goto:
        YY_GOTO YY_VAR  {fprintf(OUTPUT,"{$\\triangleleft$~{\\it Go to {\\bf %s} on page~\\pageref{%s}.}~$\\triangleright$}\n\n", $2, $2);};

gosub:
        YY_GOSUB YY_VAR  {fprintf(OUTPUT,"\n\n{$\\triangleleft$~{\\it Go to {\\bf %s} on page~\\pageref{%s}. Come back here when you are done.}~$\\triangleright$}\n\n", $2, $2);};

goto-scene:
	YY_GOTO_SCENE YY_VAR {fprintf(OUTPUT,"{$\\triangleleft$~{\\it Go to Chapter~\\uppercase{{\\bf %s}} on page~\\pageref{%s}.}~$\\triangleright$}\n\n", $2, $2);};

gosub-scene:
	YY_GOSUB_SCENE YY_VAR {fprintf(OUTPUT,"\n\n{$\\triangleleft$~{\\it Go to Chapter~\\uppercase{{\\bf %s}} on page~\\pageref{%s}. Come back here when you are done.}~$\\triangleright$}\n\n", $2, $2);};

goto-random-scene:
	YY_GOTO_RANDOM_SCENE YY_VAR {fprintf(OUTPUT,"{$\\triangleleft$~{\\it Go to Chapter~\\uppercase{{\\bf %s}} on page~\\pageref{%s}.}~$\\triangleright$}\n\n", $2, $2);};
        /*YY_GOTO_RANDOM_SCENE blockofscenes {
	 for (slist *random = $2; random; random = random->next){
		for (int j=0;j<count;j++){
			if (!strcmp(random->s,allscenes[count])){
				count++;
				allscenes[count] = random->s;
				 fprintf(yyout,"%s was imported\n",allscenes[count]);
	  			import(random->s);
				fprintf(OUTPUT,"{$\\triangleleft$~{\\it Go to Chapter~\\uppercase{{\\bf %s}} on page~\\pageref{%s}.}~$\\triangleright$}\n\n", random->s, random->s);
			}	
		}
	 }
		
	};*/
	 
	

label: 
        YY_LABEL YY_VAR {fprintf(OUTPUT,"\\Ovalbox{$\\surd$~%s\\label{%s}}\n",$2,$2);};

page_break:
	YY_PAGE_BREAK {fprintf(OUTPUT,"\\cleardoublepage\n");};
line_break:
	YY_LINE_BREAK {fprintf(OUTPUT,"\n\n");};

link:
	YY_LINK YY_STRING {fprintf(OUTPUT,"\\url{%s}\n", $2);};
image:
	YY_IMAGE YY_STRING {fprintf(OUTPUT,"\\par\\includegraphics[width=0.75\\linewidth]{%s}\n\n",$2);};
ending:
	YY_ENDING {fprintf(OUTPUT,"\\begin{description}[style=nextline]");
	 fprintf(OUTPUT,"\\item[Play again]\nGo to page~\\pageref{__START__} to play the game again.\n");
	 fprintf(OUTPUT,"\\item[Play more games like this]\n\\url{https://www.choiceofgames.com/category/our-games/}\n");
	 fprintf(OUTPUT,"\\item[Share this game with friends]\nPlease support our work by sharing this game with friends! The more people play, the more resources we'll have to work on the next game.\n");
         fprintf(OUTPUT,"\\end{description}");};

%%


