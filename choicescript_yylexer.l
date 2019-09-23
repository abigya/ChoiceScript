%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
%}


%option noyywrap

digit         [0-9]
letter        [a-zA-Z_]
alnum         {digit}|{letter}
string        \"([^\n\\\"]|\\.)*\"
quoted_string \'([^\n\\\']|\\.)*\'
permitted     {digit}|{letter}|[-%@_+\[\]\\/,\.:]
unsupported   [;()*^?~{}`]


%%
"#".*"\n"?      { /* comment */ }
[\t\n\b\v ]+    { /* whitespaces */ }
choice		{"What choice would you make?";}
create		{"Create leadership";}
set		{"Set leadership";}
if		{"Selected first choice";}
else		{"Selected second choice";}
elseif		{"Selected third choice";}
finish		{"Are you done?";}
endif		{"Game over";}



%%

int main(void){
	fprintf(stdout,"Hello from lexer!\n");
	return 0;

}


int yyerror(void){
	fprintf(stderr,"Error!\n");
	exit(1);
	
}







