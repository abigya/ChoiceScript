%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
%}


%option noyywrap


%%
"#"      	{puts("label");}
^\t*	        {puts("Tab indentation"); /*indentation one or more tabs*/}
^" "*		{puts("space indentation");/*indentation one or more spaces*/}
"*choice"	{puts("Choice command");}
"*goto"		{puts("goto command");}
"*label"	{puts("label command");}
"*finish"	{puts("Finish command");}
"*comment ".*"\n"?      { /* comment*/ }
.+               {puts(yytext);}

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







