%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include <math.h>
	#include "choicescript_yyparser.tab.h"
	static int depth = 0; 
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
^[:space:]*\n		    
^[\t ]+            	    
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
				
"*goto"			{puts("~goto command"); BEGIN(INITIAL);
				return YY_CS_GOTO;}
				
"*label"		{puts("~label command"); 
				return YY_CS_LABEL;}
			
"*finish"		{puts("~Finish command"); BEGIN(INITIAL);}
				/**return YY_CS_FINISH;}**/
				
"*create"		{puts("~Create command"); BEGIN(INITIAL);}
				/**return YY_CS_CREATE;}**/
				
"*set"			{puts("~Set command"); BEGIN(EXPR);
				return YY_CS_SET;}
			
"*if"			{ BEGIN(EXPR); return YY_CS_IF;}
				
"*else"			{BEGIN(EXPR); return YY_CS_ELSE;}
				
"*elseif"		{BEGIN(EXPR);return YY_CS_ELSEIF;}	
		
"*scene_list"		{puts("~scene_list command"); BEGIN(INITIAL);}
				/**return YY_CS_SCENE_LIST;}**/
				
"*image"		{puts("~image command"); BEGIN(INITIAL);}
				/**return YY_CS_IMAGE;}**/
			
"*line_break"		{puts("~line_break command"); BEGIN(INITIAL);}
				/**return YY_CS_LINE_BREAK;}**/
				
"*input_text"		{puts("~input_text command"); BEGIN(INITIAL);}
				/**return YY_CS_INPUT_TEXT;}**/
				
"*input_number"		{puts("~input_number command"); BEGIN(INITIAL);}
				/**return YY_CS_INPUT_NUMBER;}**/
				
"*rand"			{puts("~rand command"); BEGIN(INITIAL);}
				/**return YY_CS_RAND;}**/
			
"*stat_chart"		{puts("~stat_chart command"); BEGIN(INITIAL);}
				/**return YY_CS_STAT_CHART;}**/
				
"*bug"			{puts("~bug command"); BEGIN(INITIAL);}
				/**return YY_CS_BUG;}**/
			
"*page_break"		{puts("~page_break command"); BEGIN(INITIAL);}
				/**return YY_CS_PAGE_BREAK;}**/
				
"*hide_reuse"		{puts("~hide_reuse command"); BEGIN(INITIAL);}
				/**return YY_CS_HIDE_REUSE;}**/
				
"*disable_reuse"	{puts("~disable_reuse command"); BEGIN(INITIAL);}
				/**return YY_CS_DISABLE_REUSE;}**/
				
"*gosub_scene"		{puts("~gosub_scene command"); BEGIN(INITIAL);}
				/**return YY_CS_GOSUB_SCENE;}**/
				
"*gosub"		{puts("~gosub command"); BEGIN(INITIAL);}
				/**return YY_CS_GOSUB;}**/
				
"*return"		{puts("~/**return command"); BEGIN(INITIAL);}
				/**return YY_CS_/**return;}**/
				
"*ending"		{puts("~ending command"); BEGIN(INITIAL);}
				/**return YY_CS_ENDING;}**/
				
"*link"			{puts("~link command"); BEGIN(INITIAL);}
				/**return YY_CS_LINK;}**/

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








