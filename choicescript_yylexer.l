%{
#include "csparser.h"
#ifdef __APPLE__
  extern int yylex(void);
  extern int yyparse(void);
#endif
  void adjustIndent(char*); 
  char *my_strdup(const char *ptr);
	
%}


%option noyywrap
%option noinput
%option yylineno

EOL     [[:space:]]{-}[[:blank:]]
D	[[:digit:]]
INT     [+-]?{D}+
FLT     [+-]?(({D}+"."{D}*)|("."{D}+))

%s 	EXPR

%%
{EOL}           { BEGIN(INITIAL); /* Remove line breaks */ }
[[:blank:]]     /* Remove single spaces */
^[[:blank:]]+   { adjustIndent(yytext); /* Indent */ }
^[[:^space:]]+  { BEGIN(INITIAL); yyless(0); adjustIndent(""); /* Outdent */ }
<<EOF>>	        { adjustIndent(""); yyterminate(); /* End of file */ };

"*comment".*$   /* comment */
\x1             { puts("{"); return YY_CS_PINDENT;}
\x2		{ puts("}"); return YY_CS_NINDENT;}

<EXPR>{INT}   	{ printf("INT(%d)\n", atoi(yytext));yylval.i = atoi(yytext); return YY_CS_INT;}
<EXPR>{FLT}   	{ printf("FLOAT(%.2f)\n", atof(yytext));yylval.d = atoi(yytext); return YY_CS_FLOAT; }
<EXPR>"+" 	{ puts("PLUS"); return YY_CS_ADD;}
<EXPR>"-"	{ puts("MINUS");return YY_CS_SUBTRACT; }
<EXPR>"/"	{ puts("DIVIDE"); return YY_CS_DIVIDE; }
<EXPR>"*" 	{ puts("MULTIPLY");return YY_CS_MULTIPLY; }
<EXPR>">" 	{ puts("GT"); return YY_CS_GREATER;}
<EXPR>"<"	{ puts("LT");return YY_CS_LESS; }
<EXPR>"=" 	{ puts("EQUAL TO");return YY_CS_EQUAL; }
<EXPR>"and"	{ puts("AND"); return YY_CS_AND;}
<EXPR>"&"	{ puts("JOIN");return YY_CS_JOIN;}
 /**possibly missing <= >= != OR NOT**/

 /* This part needs fixing */
<EXPR>"["round"(FLT),]+"     { puts("ROUND");}
<EXPR>[[:alpha:]{D}]+#{D}+  { puts("extracting characters");}
<EXPR>"[${"virtue"}]+"	    { puts("Virtue expression");}


"*choice"	{puts("CHOICE"); return YY_CS_CHOICE; }
"*create"	{puts("CREATE"); BEGIN(EXPR); return YY_CS_CREATE; }
"*else"		{puts("ELSE"); return YY_CS_ELSE; }
"*elseif"	{puts("ELIF"); BEGIN(EXPR); return YY_CS_ELSEIF; }	
"*finish"	{puts("FINISH"); return YY_CS_FINISH; }
"*goto"		{puts("GOTO"); BEGIN(EXPR); return YY_CS_GOTO; }
"*goto_scene"	{puts("GOTO_SCENE"); BEGIN(EXPR); return YY_CS_GOTO_SCENE; }
"*if"		{puts("IF"); BEGIN(EXPR); return YY_CS_IF; }
"*label"	{puts("LABEL"); return YY_CS_LABEL; }
"*scene_list"	{puts("SCENE_LIST"); return YY_CS_SCENE_LIST; }
"*set"		{puts("SET"); BEGIN(EXPR); return YY_CS_SET; }
		
"*image"	{puts("~image command"); return YY_CS_IMAGE;}
		
"*line_break"	{puts("~line_break command"); return YY_CS_LINE_BREAK;}
			
"*input_text"	{puts("~input_text command"); return YY_CS_INPUT_TEXT;}
						
"*input_number"	{puts("~input_number command"); return YY_CS_INPUT_NUMBER;}
						
"*rand"		{puts("~rand command");return YY_CS_RAND;}
			
"*stat_chart"	{puts("~stat_chart command");return YY_CS_STAT_CHART;}		
			
"*bug"		{puts("~bug command");return YY_CS_BUG;}
		
"*page_break"	{puts("~page_break command"); return YY_CS_PAGE_BREAK;}
			
"*hide_reuse"	{puts("~hide_reuse command");return YY_CS_HIDE_REUSE;}
			
"*disable_reuse" {puts("~disable_reuse command");return YY_CS_DISABLE_REUSE;}
			
"*gosub_scene"	{puts("~gosub_scene command");return YY_CS_GOSUB_SCENE;}
			
"*gosub"	{puts("~gosub command");return YY_CS_GOSUB;}
			
"*return"	{puts("~/**return command"); return YY_CS_RETURN;}
			
"*ending"	{puts("~ending command");return YY_CS_ENDING;}
			
"*link"		{ puts("~link command"); return YY_CS_LINK;}

#.+$            { printf("CASE(%s)\n", strtok(yytext + 1, "\n\r")); yylval.s = my_strdup( strtok(yytext + 1, 				"\n\r"));return YY_CS_CASE; }

[^[:space:]\x1\x2]+     { printf("STR(%s)\n", yytext); yylval.s = my_strdup(yytext);return YY_CS_STRING; }

 /* This part needs fixing */
[$!{:alpha:}]+	{ puts("capitalize first letter of string");}
[$!+{:alpha:}]+	{ puts("capitalize the entire string");}
[${:alpha:}]+	{ puts("quoted string");}

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

