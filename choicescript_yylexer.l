%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
%}


%option noyywrap


%%
"#"      		{puts("label");}
^\t*	        	{puts("Tab indentation"); /*one or more tabs*/}
^" "*			{puts("space indentation");/*one or more spaces*/}
"*choice"		{puts("Choice command");}
"*goto"			{puts("goto command");}
"*label"		{puts("label command");}
"*finish"		{puts("Finish command");}
"*create"		{puts("Create command");}
"*set"			{puts("Set command");}
"*if"			{puts("If command");}
"*else"			{puts("Else command");}
"*elseif"		{puts("Elseif command");}
"*scene_list"		{puts("scene_list command");}
"*goto_scene"		{puts("goto_scene command");}
"*image"		{puts("image command");}
"*line_break"		{puts("line_break command");}
"*input_text"		{puts("input_text command");}
"*input_number"		{puts("input_number command");}
"*rand"			{puts("rand command");}
"*stat_chart"		{puts("stat_chart command");}
"*bug"			{puts("bug command");}
"*page_break"		{puts("page_break command");}
"*hide_reuse"		{puts("hide_reuse command");}
"*disable_reuse"	{puts("disable_reuse command");}
"*gosub"		{puts("gosub command");}
"*gosub_scene"		{puts("gosub_scene command");}
"*return"		{puts("return command");}
"*comment ".*"\n"?      { /* comment*/ }
".+" 			{ puts(yytext);}
             	

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







