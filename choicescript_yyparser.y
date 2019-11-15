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
%token YY_CREATE
%token YY_DISABLE_REUSE
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
    puts("\\documentclass{book}");
    puts("\\usepackage{hyperref}");
    puts("\\usepackage{fancybox}");
    puts("\\usepackage{enumitem}");
    puts("\\begin{document}");
    puts("\\date{}");}
 } preamble {
   puts("\\maketitle");
 } story {
   if (level == 0) { /* Are we in startup.txt? */
     puts("\\end{document}");
   }
 };

preamble:
	title author 
	|author title
	|title
	|author
	|%empty;

title:
	YY_TITLE {puts("\\title{");} vars {fputs("}", stdout);};
author:
	YY_AUTHOR {puts("\\author{");} vars {fputs("}", stdout);};
	
story:
	  assignment {fprintf(stderr,"Assignment found\n");} story
	| choice story
	| label story
	| conditional {fprintf(stderr,"Conditional found\n");} story
	| tagged-word story
	| scenelist story
	| link story
	| page_break story
        | goto story
  	| goto-scene   {fprintf(stderr,"Goto-scene found\n");}story
  	| gosub         {fprintf(stderr,"gosub found\n");}story
	| gosub-scene   {fprintf(stderr,"gosub-scene found\n");}story
        | YY_ENDING {fprintf(stderr, "Ending found\n");} story
	| %empty;

scenelist:
  YY_SCENE_LIST blockofscenes {
    for (slist *start = $2; start; start = start->next){
      if (strcmp(start->s, STARTUP_NAME)) {
	  printf("\\uppercase{\\chapter{%s}\\label{%s}}\n", start->s, start->s);
	  import(start->s);
	}
    }
    puts("\\chapter{Main Matter}\n\n");
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
	YY_VAR{puts($1);} vars
	| YY_VAR{puts($1);};

tagged-word:
	      YY_STRING {puts($1);} 
	      | YY_BEGINBOLD {puts("{\\bf");} tagged-string YY_ENDBOLD {fputs("}",stdout);}
	      | YY_BEGINITALICS {puts("{\\it");} tagged-string YY_ENDITALICS {fputs("}",stdout);};
             
tagged-string:
		tagged-word tagged-string
		| %empty;
	
break:
     YY_FINISH { puts("$\\diamondsuit$\n\n"); /* Needs work! */} 
   | YY_RETURN { puts("\n{\\it Go back and continue reading}~$\\hookleftarrow$\n\n"); }
   | %empty ;

assignment:
	   YY_SET YY_VAR arithmetic-expression
	   | YY_CREATE YY_VAR arithmetic-expression;

conditional:
           YY_IF logical-expression { puts("xxx~?~$\\Rightarrow$"); } block else-if-continuation else-continuation;

else-if-continuation:
    YY_ELSEIF logical-expression { puts("xxx~??~$\\Rightarrow$"); } block else-if-continuation
  | %empty ;

else-continuation:
	     YY_ELSE  { puts("!~$\\Rightarrow$"); } block
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
	YY_CHOICE {puts("\\begin{description}[style=nextline]");}
        block-cases {puts("\\end{description}");};

block-cases:
        YY_PINDENT cases YY_NINDENT
      | YY_PINDENT block-cases YY_NINDENT;

cases:
	case cases
	| case;

case:
        YY_CASE {printf("\\item[%s]\n", $1);} block;

goto:
        YY_GOTO YY_VAR  {printf("{$\\triangleleft$~{\\it Go to {\\bf %s} on page \\pageref{%s}.}~$\\triangleright$}\n\n", $2, $2);};

gosub:
        YY_GOSUB YY_VAR  {printf("\n\n{$\\triangleleft$~{\\it Go to {\\bf %s} on page \\pageref{%s}. Come back here when you are done.}~$\\triangleright$}\n\n", $2, $2);};

goto-scene:
	YY_GOTO_SCENE YY_VAR {printf("{$\\triangleleft$~{\\it Go to {\\bf %s} on page \\pageref{%s}.}~$\\triangleright$}\n\n", $2, $2);};

gosub-scene:
	YY_GOSUB_SCENE YY_VAR;

label: 
        YY_LABEL YY_VAR {printf("\\Ovalbox{$\\surd$~%s\\label{%s}}\n",$2,$2);};

page_break:
	YY_PAGE_BREAK {printf("\\cleardoublepage\n");};

link:
	YY_LINK YY_STRING {printf("\\url{%s}\n", $2);};

%%


