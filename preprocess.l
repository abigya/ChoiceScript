%{
	#include <stdio.h>	
	int depth = 0;
	void adjustIndent(char* text);
%}

%option noyywrap

%%

^[ \t]*[\n\r]+ 	
^[ \t]+ {adjustIndent(yytext);}
^[^ \t]	{unput(yytext[0]); adjustIndent("");}
<<EOF>>		{adjustIndent("");yyterminate();};

%%

void adjustIndent(char* text){
	int new_depth = strlen(text);
	for (int i=0;i<(new_depth-depth);i++){
		putchar('\x1');
	}
	for (int i=0;i<(depth-new_depth);i++){
		putchar('\x2');
	}
	depth = new_depth;
}

int main(void){
	fprintf(stdout,"Hello from preprocessor!\n");
	yylex();
	return 0;

}


int yyerror(void){
	fprintf(stderr,"Error!\n");
	exit(1);
	
}

