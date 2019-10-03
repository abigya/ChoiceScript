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
%s 	INDENT

%%

[-+]?{d}+ 			{printf("~(int)%s\n",yytext);} 
[-+]?(({d}+\.{d}*)|(\.{d}+))	{printf("~(float)%s\n",yytext);}
^[[ ]]+				{printf("INDENT %ld\n", strlen(yytext));BEGIN(INDENT);}
[0-9]+				{printf("NUMBER: %s\n", yytext);}
<INDENT>[*#][[a-z]]+		{printf("COMMAND:`%s`\n",yytext); BEGIN(INITIAL);}
^[*#][[a-z]]+			{printf("COMMAND:`%s`\n",yytext);}
[^[ ]*#]+ 			{printf("STRING:`%s`\n",yytext);}
"#".*"\n"?      		{puts("~label");}
^\t*	        		{puts("~Tab indentation"); /*one or more tabs*/}
^" "*				{puts("~space indentation");/*one or more spaces*/}

"*choice"		{puts("~Choice command");
				return YY_CS_CHOICE;}			
"*goto_scene"		{puts("~goto_scene command");
				return YY_CS_GOTO_SCENE;}				     
"*goto"			{puts("~goto command");
				return YY_CS_GOTO;}		    
"*label"		{puts("~label command");
				return YY_CS_LABEL;}
"*finish"		{puts("~Finish command");
				return YY_CS_FINISH;}
"*create"		{puts("~Create command");
				return YY_CS_CREATE;}
"*set"			{puts("~Set command");
				return YY_CS_SET;}
"*if"			{puts("~If command");
				return YY_CS_IF;}
"*else"			{puts("~Else command");
				return YY_CS_ELSE;}
"*elseif"		{puts("~Elseif command");
				return YY_CS_ELSEIF;}
"*scene_list"		{puts("~scene_list command");
				return YY_CS_SCENE_LIST;}
"*image"		{puts("~image command");
				return YY_CS_IMAGE;}
"*line_break"		{puts("~line_break command");
				return YY_CS_LINE_BREAK;}
"*input_text"		{puts("~input_text command");
				return YY_CS_INPUT_TEXT;}
"*input_number"		{puts("~input_number command");
				return YY_CS_INPUT_NUMBER;}
"*rand"			{puts("~rand command");
				return YY_CS_RAND;}
"*stat_chart"		{puts("~stat_chart command");
				return YY_CS_STAT_CHART;}
"*bug"			{puts("~bug command");
				return YY_CS_BUG;}
"*page_break"		{puts("~page_break command");
				return YY_CS_PAGE_BREAK;}
"*hide_reuse"		{puts("~hide_reuse command");
				return YY_CS_HIDE_REUSE;}
"*disable_reuse"	{puts("~disable_reuse command");
				return YY_CS_DISABLE_REUSE;}
"*gosub_scene"		{puts("~gosub_scene command");
				return YY_CS_GOSUB_SCENE;}
"*gosub"		{puts("~gosub command");
				return YY_CS_GOSUB;}
"*return"		{puts("~return command");
				return YY_CS_RETURN;}
"*ending"		{puts("~ending command");
				return YY_CS_ENDING;}
"*link"			{puts("~link command");
				return YY_CS_LINK;}

"*comment ".*"\n"?      { /* comment*/ }
"+"			{puts("~add");
				return YY_CS_ADD;}
"-"			{puts("~subtract");
				return YY_CS_SUBTRACT;}
"/"			{puts("~divide");
				return YY_CS_DIVIDE;}
"*"			{puts("~multiply");
				return YY_CS_MULTIPLY;}
">"			{puts("~greater than");
				return YY_CS_GREATER;}
"<"			{puts("~less than");
				return YY_CS_LESS;}
"="			{puts("~equal to");
				return YY_CS_EQUAL;}


[ \n\t]+		{puts("~space");}
. 			{printf("^%s",yytext);}
[a-zA-Z0-9]+		{printf("^%s",yytext);}

             	

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







