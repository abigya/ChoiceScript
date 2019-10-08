%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include <math.h>
	#include "choicescript_yyparser.tab.h"
	#ifdef __APPLE__
	extern int yylex(void);
	extern int yyparse(void);
	#endif
%}

%{
int valid_int=0, valid_float=0;
%}

%option noyywrap
d	[0-9]
%s 	INDENT EXPR

%%
"*comment ".*"\n"?      { /* comment*/ }
<EXPR>\n 	    	    { BEGIN(INITIAL); }
^[\t ]+             	    { printf("INDENT %ld\n", strlen(yytext)); BEGIN(INDENT);}
<EXPR>[+-]?[0-9]+   	    { printf("INT: %s\n", yytext); }
<EXPR>[+-]?[0-9]+\.[0-9]*   { printf("FLOAT: %s\n", yytext); }
<EXPR>[+-]?\.[0-9]+   	    { printf("FLOAT: %s\n", yytext); }
<EXPR>\+ 		    { puts("PLUS"); }
<EXPR>\-		    { puts("MINUS"); }
<EXPR>\/		    { puts("DIVIDE"); }
<EXPR>\* 		    { puts("MULTIPLY"); }
<EXPR>\> 		    { puts("GT"); }
<EXPR>\<		    { puts("LT"); }
<EXPR>\= 		    { puts("EQUAL TO"); }

^[[" "]]+\n		{puts("~space indentation");/*one or more spaces*/}
^[[\t]]+\n		{puts("~tab indentation");/*one or more tabs*/}
<INDENT>"*choice" |
^"*choice"		{puts("~Choice command"); BEGIN(INITIAL);
				return YY_CS_CHOICE;}
<INDENT>"*goto_scene" |				
^"*goto_scene"		{puts("~goto_scene command");
				return YY_CS_GOTO_SCENE;}
<INDENT>"*goto" |				
^"*goto"			{puts("~goto command");
				return YY_CS_GOTO;}
<INDENT>"*label" |				
^"*label"		{puts("~label command");
				return YY_CS_LABEL;}
<INDENT>"*finish" |				
^"*finish"		{puts("~Finish command");
				return YY_CS_FINISH;}
<INDENT>"*create" |				
^"*create"		{puts("~Create command");
				return YY_CS_CREATE;}
<INDENT>"*set" |				
^"*set"			{puts("~Set command");
				return YY_CS_SET;}
<INDENT>"*if" |				
^"*if"			{puts("~If command");
				return YY_CS_IF;}
<INDENT>"*else" |				
^"*else"		{puts("~Else command");
				return YY_CS_ELSE;}
<INDENT>"*elseif" |				
^"*elseif"		{puts("~Elseif command");
				return YY_CS_ELSEIF;}
<INDENT>"*scene_list" |				
^"*scene_list"		{puts("~scene_list command");
				return YY_CS_SCENE_LIST;}
<INDENT>"*image" |				
^"*image"		{puts("~image command");
				return YY_CS_IMAGE;}
<INDENT>"*line_break" |				
^"*line_break"		{puts("~line_break command");
				return YY_CS_LINE_BREAK;}
<INDENT>"*input_text" |				
^"*input_text"		{puts("~input_text command");
				return YY_CS_INPUT_TEXT;}
<INDENT>"*input_number" |				
^"*input_number"	{puts("~input_number command");
				return YY_CS_INPUT_NUMBER;}
<INDENT>"*rand" |				
^"*rand"		{puts("~rand command");
				return YY_CS_RAND;}
<INDENT>"*stat_chart" |				
^"*stat_chart"		{puts("~stat_chart command");
				return YY_CS_STAT_CHART;}
<INDENT>"*bug" |				
^"*bug"			{puts("~bug command");
				return YY_CS_BUG;}
<INDENT>"*page_break" |				
^"*page_break"		{puts("~page_break command");
				return YY_CS_PAGE_BREAK;}
<INDENT>"*hide_reuse" |				
^"*hide_reuse"		{puts("~hide_reuse command");
				return YY_CS_HIDE_REUSE;}
<INDENT>"*disabe_reuse" |				
^"*disable_reuse"	{puts("~disable_reuse command");
				return YY_CS_DISABLE_REUSE;}
<INDENT>"*gosub_scene" |				
^"*gosub_scene"		{puts("~gosub_scene command");
				return YY_CS_GOSUB_SCENE;}
<INDENT>"*gosub" |				
^"*gosub"		{puts("~gosub command");
				return YY_CS_GOSUB;}
<INDENT>"*return" |				
^"*return"		{puts("~return command");
				return YY_CS_RETURN;}
<INDENT>"*ending" |				
^"*ending"		{puts("~ending command");
				return YY_CS_ENDING;}
<INDENT>"*link" |				
^"*link"		{puts("~link command");
				return YY_CS_LINK;}
<INDENT>#.+\n |
^#.+\n              	{ printf("CASE: `%s`\n", strtok(yytext + 1, "\n\r")); }
[^[" "]]+       	{ printf("STRING: `%s`\n", yytext); }
[ \n\t]+		{puts("~space");}
. 			{printf("^%s",yytext);}

%%

int main(void){
	fprintf(stdout,"Hello from lexer!\n");
	yylex();
	return 0;

}


int yyerror(void){
	fprintf(stderr,"Error!\n");
	exit(1);
	
}







