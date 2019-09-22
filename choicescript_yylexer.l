%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
%}


%option noyywrap

%%

%%

int main(void){
	fprintf(stdout,"Hello from lexer!\n");
	return 0;

}


int yyerror(void){
	fprintf(stderr,"Error!\n");
	exit(1);
	
}







