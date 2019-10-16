%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include <math.h>
	#include "choicescript_yyparser.tab.h"
	static int depth = 0;
	void adjustIndent(char* text); 
	#ifdef __APPLE__
	extern int yylex(void);
	extern int yyparse(void);
	#endif
%}

%option noyywrap
d	[0-9]
%s 	INDENT EXPR

%%
"*comment".*\n     { /* comment*/ }
^[:space:]*\n		    { adjustIndent(yytext);}
^[\t ]+            	    { adjustIndent(yytext);}	
\x1			{puts("positive indent");return YY_CS_PINDENT;}
\x2			{puts("negative indent"); return YY_CS_NINDENT;}			
<EXPR>[+-]?[0-9]+   	    { /**printf("INT: %s\n", yytext);**/ return YY_CS_INT;}
<EXPR>[+-]?[0-9]+\.[0-9]*   { /**printf("FLOAT: %s\n", yytext);**/return YY_CS_FLOAT; }
<EXPR>[+-]?\.[0-9]+   	    { /*printf("FLOAT: %s\n", yytext);**/ return YY_CS_FLOAT; }
<EXPR>\+ 		    { puts("PLUS"); }
<EXPR>\-		    { puts("MINUS"); }
<EXPR>\/		    { puts("DIVIDE"); }
<EXPR>\* 		    { puts("MULTIPLY"); }
<EXPR>\> 		    { puts("GT"); }
<EXPR>\<		    { puts("LT"); }
<EXPR>\= 		    { puts("EQUAL TO"); }
<EXPR>\and		    { puts("AND");}
<EXPR>\&		    { puts("JOIN");}
<EXPR>\round([+-]?[0-9]+\.[0-9]*) {puts("ROUND");}
<EXPR>\round([+-]?\.[0-9]+)	  {puts("ROUND");}
<EXPR>\[a-zA-Z0-9]+#[0-9]+	  {puts("extracting characters");}
<EXPR>\$\{+[virtue]\}+		  {puts("Virtue expression");}




"*choice"		{puts("~Choice command"); BEGIN(INITIAL);
				return YY_CS_CHOICE;}
		
"*goto_scene"		{puts("~goto_scene command"); BEGIN(INITIAL);
				/**return YY_CS_GOTO_SCENE;**/}
				
"*goto"		{puts("~goto command"); BEGIN(INITIAL);
				return YY_CS_GOTO;}
				
"*label"		{puts("~label command"); adjustIndent("");
				return YY_CS_LABEL;}
			
"*finish"		{puts("~Finish command"); BEGIN(INITIAL);}
				/**return YY_CS_FINISH;}**/
<INDENT>"*create" |				
^"*create"		{puts("~Create command"); BEGIN(INITIAL);}
				/**return YY_CS_CREATE;}**/
				
"*set"			{puts("~Set command"); BEGIN(EXPR);
				return YY_CS_SET;}
			
"*if"			{ BEGIN(EXPR);
				return YY_CS_IF;}
				
"*else"		{BEGIN(EXPR);
				return YY_CS_ELSE;}
				
"*elseif"		{BEGIN(EXPR);
				return YY_CS_ELSEIF;}
<INDENT>"*scene_list" |				
^"*scene_list"		{puts("~scene_list command"); BEGIN(INITIAL);}
				/**return YY_CS_SCENE_LIST;}**/
<INDENT>"*image" |				
^"*image"		{puts("~image command"); BEGIN(INITIAL);}
				/**return YY_CS_IMAGE;}**/
<INDENT>"*line_break" |				
^"*line_break"		{puts("~line_break command"); BEGIN(INITIAL);}
				/**return YY_CS_LINE_BREAK;}**/
<INDENT>"*input_text" |				
^"*input_text"		{puts("~input_text command"); BEGIN(INITIAL);}
				/**return YY_CS_INPUT_TEXT;}**/
<INDENT>"*input_number" |				
^"*input_number"	{puts("~input_number command"); BEGIN(INITIAL);}
				/**return YY_CS_INPUT_NUMBER;}**/
<INDENT>"*rand" |				
^"*rand"		{puts("~rand command"); BEGIN(INITIAL);}
				/**return YY_CS_RAND;}**/
<INDENT>"*stat_chart" |				
^"*stat_chart"		{puts("~stat_chart command"); BEGIN(INITIAL);}
				/**return YY_CS_STAT_CHART;}**/
<INDENT>"*bug" |				
^"*bug"			{puts("~bug command"); BEGIN(INITIAL);}
				/**return YY_CS_BUG;}**/
<INDENT>"*page_break" |				
^"*page_break"		{puts("~page_break command"); BEGIN(INITIAL);}
				/**return YY_CS_PAGE_BREAK;}**/
<INDENT>"*hide_reuse" |				
^"*hide_reuse"		{puts("~hide_reuse command"); BEGIN(INITIAL);}
				/**return YY_CS_HIDE_REUSE;}**/
<INDENT>"*disabe_reuse" |				
^"*disable_reuse"	{puts("~disable_reuse command"); BEGIN(INITIAL);}
				/**return YY_CS_DISABLE_REUSE;}**/
<INDENT>"*gosub_scene" |				
^"*gosub_scene"		{puts("~gosub_scene command"); BEGIN(INITIAL);}
				/**return YY_CS_GOSUB_SCENE;}**/
<INDENT>"*gosub" |				
^"*gosub"		{puts("~gosub command"); BEGIN(INITIAL);}
				/**return YY_CS_GOSUB;}**/
<INDENT>"*return" |				
^"*return"		{puts("~/**return command"); BEGIN(INITIAL);}
				/**return YY_CS_/**return;}**/
<INDENT>"*ending" |				
^"*ending"		{puts("~ending command"); BEGIN(INITIAL);}
				/**return YY_CS_ENDING;}**/
<INDENT>"*link" |				
^"*link"		{puts("~link command"); BEGIN(INITIAL);}
				/**return YY_CS_LINK;}**/
<INDENT>#.+\n |
#.+\n              	{ printf("CASE: `%s`\n", strtok(yytext + 1, "\n\r"));return YY_CS_CASE; }
[^[:space:]\x1\x2]+       	{ printf("STRING: `%s`\n", yytext);return YY_CS_STRING; }
^[$][!][{][a-zA-Z]+[}]$		{puts("capitalize first letter of string");}
^[$][!]+[{][a-zA-Z]+[}]$	 {puts("capitalize the entire string");}
^[$][{][a-zA-Z]+[}]$		{puts("quoted string");}



%%

int main(void){
	fprintf(stdout,"Hello from lexer!\n");
	yyparse();
	return 0;

}


int yyerror(void){
	fprintf(stderr,"Error!\n");
	exit(1);
	
}








