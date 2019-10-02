%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include <math.h>
%}

%{
int valid_int=0, valid_float=0;
%}

%option noyywrap
d	[0-9]

%%
[-+]?{d}+ 		{printf("~(int)%s\n",yytext);} 
[-+]?(({d}+\.{d}*)|(\.{d}+))	{printf("~(float)%s\n",yytext);}
"#".*"\n"?      	{puts("~label");}
^\t*	        	{puts("~Tab indentation"); /*one or more tabs*/}
^" "*			{puts("~space indentation");/*one or more spaces*/}
"*choice"		{puts("~Choice command");}
"*goto_scene"	{puts("~goto_scene command");}
"*goto"		{puts("~goto command");}
"*label"	{puts("~label command");}
"*finish"	{puts("~Finish command");}
"*create"	{puts("~Create command");}
"*set"		{puts("~Set command");}
"*if"		{puts("~If command");}
"*else"		{puts("~Else command");}
"*elseif"	{puts("~Elseif command");}
"*scene_list"	{puts("~scene_list command");}
"*image"	{puts("~image command");}
"*line_break"	{puts("~line_break command");}
"*input_text"	{puts("~input_text command");}
"*input_number"	{puts("~input_number command");}
"*rand"		{puts("~rand command");}
"*stat_chart"	{puts("~stat_chart command");}
"*bug"		{puts("~bug command");}
"*page_break"	{puts("~page_break command");}
"*hide_reuse"	{puts("~hide_reuse command");}
"*disable_reuse"	{puts("~disable_reuse command");}
"*gosub_scene"	{puts("~gosub_scene command");}
"*gosub"	{puts("~gosub command");}
"*return"	{puts("~return command");}
"*ending"	{puts("~ending command");}
"*link"		{puts("~link command");}
"*comment ".*"\n"?      { /* comment*/ }
"+"		{puts("~add");}
[ \n\t]+	{puts("~space");}
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







