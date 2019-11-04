%{
#include "csparser.h"
#ifdef __APPLE__
  extern int yylex(void);
  extern int yyparse(void);
#endif
  void adjustIndent(char*); 
  char *my_strdup(const char *ptr);
  int brace_balance = 0; /* Maintain the balance of braces */
%}


%option noyywrap
%option noinput
%option yylineno

EOL     [[:space:]]{-}[[:blank:]]
D	[[:digit:]]
INT     [+-]?{D}+
FLT     [+-]?(({D}+"."{D}*)|("."{D}+))
CHAR    [^[:space:]\x1\x2[]

%s 	EXPR

%%

 //%x incl
 //%%
//include BEGIN(incl);
//[a-z]+   ECHO;
//[^a-z\n]*\n? ECHO;
//<incl>[ \t]*
//<incl>[^ \t\n]+ {
/*yyin = fopen(yytext,"r");
	if(!yyin){
		error("file not found\n");
	}	
	yypush_buffer_state(yy_create_buffer(yyin,YY_BUF_SIZE));
	BEGIN(INITIAL);
}
<<EOF>>{/*
	yypop_buffer_state();
	if(!YY_CURRENT_BUFFER){
		yyterminate();
	}




	*/ //}


{EOL}           { BEGIN(INITIAL); /* Remove line breaks */ }
[[:blank:]]     /* Remove single spaces */
^[[:blank:]]+   { adjustIndent(yytext); /* Indent */ }
^[[:^space:]]+  { BEGIN(INITIAL); yyless(0); adjustIndent(""); /* Outdent */ }
<<EOF>>	        { adjustIndent(""); if (brace_balance == 0) yyterminate(); /* End of file */ };

"*comment".*$   /* comment */
\x1             { puts("%{"); brace_balance++; return YY_CS_PINDENT;}
\x2		{ puts("%}"); brace_balance--; return YY_CS_NINDENT;}

<EXPR>{INT}   	{ printf("%%INT(%d)\n", atoi(yytext)); yylval.i = atoi(yytext); return YY_CS_INT;}
<EXPR>{FLT}   	{ printf("%%FLOAT(%.2f)\n", atof(yytext)); yylval.d = atoi(yytext); return YY_CS_FLOAT; }
<EXPR>"and"	{ puts("%AND"); return YY_CS_AND;}
<EXPR>"+" 	|
<EXPR>"-"	{ return yytext[0];}
<EXPR>"/"	|
<EXPR>"*" 	|
<EXPR>">" 	|
<EXPR>"<"	|
<EXPR>"=" 	|
<EXPR>"&"	|
<EXPR>','       |
<EXPR>"("	|
<EXPR>")"       { return yytext[0];}
 /**possibly missing <= >= != OR NOT**/

"*choice"	{puts("%CHOICE"); return YY_CS_CHOICE; }
"*create"	{puts("%CREATE"); BEGIN(EXPR); return YY_CS_CREATE; }
"*else"		{puts("%ELSE"); return YY_CS_ELSE; }
"*elseif"	{puts("%ELIF"); BEGIN(EXPR); return YY_CS_ELSEIF; }	
"*finish"	{return YY_CS_FINISH; }
"*goto"		{puts("%GOTO"); BEGIN(EXPR); return YY_CS_GOTO; }
"*goto_scene"	{BEGIN(EXPR); return YY_CS_GOTO_SCENE; }
"*if"		{puts("%IF"); BEGIN(EXPR); return YY_CS_IF; }
"*label"	{puts("%LABEL"); BEGIN(EXPR); return YY_CS_LABEL; }
"*scene_list"	{puts("%SCENE_LIST"); return YY_CS_SCENE_LIST; }
"*set"		{puts("%SET"); BEGIN(EXPR); return YY_CS_SET; }
		
"*image"	{puts("%~image command"); return YY_CS_IMAGE;}
		
"*line_break"	{puts("%~line_break command"); return YY_CS_LINE_BREAK;}
			
"*input_text"	{puts("%~input_text command"); return YY_CS_INPUT_TEXT;}
						
"*input_number"	{puts("%~input_number command"); return YY_CS_INPUT_NUMBER;}
						
"*rand"		{puts("%~rand command");return YY_CS_RAND;}
			
"*stat_chart"	{puts("%~stat_chart command");return YY_CS_STAT_CHART;}		
			
"*bug"		{puts("%~bug command");return YY_CS_BUG;}
		
"*page_break"	{puts("%~page_break command"); return YY_CS_PAGE_BREAK;}
			
"*hide_reuse"	{puts("%~hide_reuse command");return YY_CS_HIDE_REUSE;}
			
"*disable_reuse" {puts("%~disable_reuse command");return YY_CS_DISABLE_REUSE;}
			
"*gosub_scene"	{puts("%~gosub_scene command");return YY_CS_GOSUB_SCENE;}
			
"*gosub"	{puts("%~gosub command");return YY_CS_GOSUB;}
			
"*return"	{puts("%~return command"); return YY_CS_RETURN;}
			
"*ending"	{puts("%~ending command");return YY_CS_ENDING;}
			
"*link"		{ puts("%~link command"); return YY_CS_LINK;}
"*title"	{ puts("%~title command"); BEGIN(EXPR);return YY_CS_TITLE;}
"*author"	{ puts("%~author command");BEGIN(EXPR); return YY_CS_AUTHOR;}

#.+$            { printf("%%CASE(%s)\n", strtok(yytext + 1, "\n\r"));
                  yylval.s = my_strdup( strtok(yytext + 1, "\n\r"));
                  return YY_CS_CASE; }

 /* This part needs fixing */
"[b]" 		{puts("%begin bold");return YY_CS_BEGINBOLD;}
"[/b]"           {puts("%end bold"); return YY_CS_ENDBOLD;}
"[i]" 		{puts("%begin italics");return YY_CS_BEGINITALICS;}
"[/i]"           {puts("%end italics"); return YY_CS_ENDITALICS;}

<EXPR>"#{"[^}]+"}"      { puts("%Index"); }
<EXPR>"$"+"{"{CHAR}+"}" { puts("%Reference");}

<EXPR>{CHAR}+ { printf("%%VAR(%s)\n", yytext);
                      yylval.s = my_strdup(yytext); return YY_CS_VAR; }
{CHAR}+ { printf("%%STR(%s)\n", yytext);
                      yylval.s = my_strdup(yytext); return YY_CS_STRING; }


 
\$![{a-zA-Z}]+$	{ puts("%capitalize first letter of string");}
\$!![{a-zA-Z}]+$ { puts("%capitalize the entire string");}
\$[{a-zA-Z}]+$	{ puts("%quoted string");}

%%

int main(void){
	fprintf(stderr, "ChoiceScript -> LaTeX\n");
	yyparse();
	return EXIT_SUCCESS;
}

int yyerror(void){
  fprintf(stderr, "(infile):%d: syntax error\n", yylineno);
  exit(EXIT_FAILURE);      
}

void adjustIndent(char* text){
  static int depth = 0;
  int new_depth = strlen(text);
  for (int i = 0; i < new_depth - depth; i++) unput('\x1');
  for (int i = 0; i < depth - new_depth; i++) unput('\x2');
  depth = new_depth;
}
char *my_strdup(const char *ptr){
   void* check = strdup(ptr);
   if (check==NULL){
	abort();
   }
   return check;
		
}

