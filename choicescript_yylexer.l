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


%%
^[-+]?[0-9]* valid_int++; 
^[-+]?[0-9]*[.][0-9]+$ valid_float++;
"#".*"\n"?      	{puts("label");}
^\t*	        	{puts("Tab indentation"); /*one or more tabs*/}
^" "*			{puts("space indentation");/*one or more spaces*/}
"*choice"		{puts("Choice command");}
"*goto_scene".*"\n"?	{puts("goto_scene command");}
"*goto".*"\n"?		{puts("goto command");}
"*label".*"\n"?		{puts("label command");}
"*finish".*"\n"?	{puts("Finish command");}
"*create".*"\n"?	{puts("Create command");}
"*set".*"\n"?		{puts("Set command");
			/*char *token = yytext;
			maybe pass to a function to get the number and choice*/}
"*if".*"\n"?		{puts("If command");}
"*else".*"\n"?		{puts("Else command");}
"*elseif".*"\n"?	{puts("Elseif command");}
"*scene_list".*"\n"?	{puts("scene_list command");}
"*image".*"\n"?		{puts("image command");}
"*line_break".*"\n"?	{puts("line_break command");}
"*input_text".*"\n"?	{puts("input_text command");}
"*input_number".*"\n"?	{puts("input_number command");}
"*rand".*"\n"?		{puts("rand command");}
"*stat_chart".*"\n"?	{puts("stat_chart command");}
"*bug".*"\n"?		{puts("bug command");}
"*page_break".*"\n"?	{puts("page_break command");}
"*hide_reuse".*"\n"?	{puts("hide_reuse command");}
"*disable_reuse".*"\n"?	{puts("disable_reuse command");}
"*gosub_scene".*"\n"?	{puts("gosub_scene command");}
"*gosub".*"\n"?		{puts("gosub command");}
"*return".*"\n"?	{puts("return command");}
"*ending".*"\n"?	{puts("ending command");}
"*link".*"\n"?		{puts("link command");}
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







