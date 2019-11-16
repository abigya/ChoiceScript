%{
#include "csparser.h"
#ifdef __APPLE__
  extern int yylex(void);
  extern int yyparse(void);
#endif
  void adjustIndent(char*); 
  void *safe_malloc(size_t size);
  char *my_strdup(const char *ptr);
  int brace_balance = 0; /* Maintain the balance of braces */
  int parse;
  FILE *OUTPUT;
 
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

"*comment".*$   /* comment */
{EOL}           { BEGIN(INITIAL); /* Remove line breaks */ }
[[:blank:]]     /* Remove single spaces */
^[[:blank:]]+   { adjustIndent(yytext); /* Indent */ }
^[[:^space:]]+  { BEGIN(INITIAL); yyless(0); adjustIndent(""); /* Outdent */ }
<<EOF>>	        { /* End of file */
  if (brace_balance == 0) { /* Return to the includer */
    yypop_buffer_state();
    yyterminate();
    BEGIN(INITIAL); 
  } else { /* "unread" the missing unindents */
    adjustIndent("");
  }
 };

\x1             { fprintf(yyout,"{\n"); brace_balance++; return YY_PINDENT;}
\x2		{ fprintf(yyout,"}\n"); brace_balance--; return YY_NINDENT;}

<EXPR>{INT}   	{ yylval.i = atoi(yytext); return YY_INT;}
<EXPR>{FLT}   	{ yylval.d = atoi(yytext); return YY_FLOAT; }
<EXPR>"and"	{ return YY_AND;}
<EXPR>"+" 	{ return yytext[0];}
<EXPR>"-"	{ return yytext[0];}
<EXPR>"/"	{ return yytext[0];}
<EXPR>"*" 	{ return yytext[0];}
<EXPR>">" 	{ return yytext[0];}
<EXPR>"<"	{ return yytext[0];}
<EXPR>"=" 	{ return yytext[0];}
<EXPR>"&"	{ return yytext[0];}
<EXPR>','       { return yytext[0];}
<EXPR>"("	{ return yytext[0];}
<EXPR>")"       { return yytext[0];}
 /**possibly missing <= >= != OR NOT**/


"*choice"	{fprintf(yyout,"CHOICE\n"); return YY_CHOICE; }
"*create"	{fprintf(yyout,"CREATE"); BEGIN(EXPR); return YY_CREATE; }
"*else"		{fprintf(yyout,"ELSE"); return YY_ELSE; }
"*elseif"	{fprintf(yyout,"ELIF"); BEGIN(EXPR); return YY_ELSEIF; }	
"*finish"	{fprintf(yyout,"FINISH");return YY_FINISH; }
"*goto"		{fprintf(yyout,"GOTO");BEGIN(EXPR); return YY_GOTO; }
"*goto_scene"	{fprintf(yyout,"GOTO_SCENE");BEGIN(EXPR); return 				YY_GOTO_SCENE; }
"*if"		{fprintf(yyout,"IF");BEGIN(EXPR); return YY_IF; }
"*label"	{fprintf(yyout,"LABEL");BEGIN(EXPR); return YY_LABEL; }
"*scene_list"	{fprintf(yyout,"SCENE_LIST");return YY_SCENE_LIST; }
"*set"		{fprintf(yyout,"SET");BEGIN(EXPR); return YY_SET; }
		
"*image"	{fprintf(yyout,"image command");return YY_IMAGE;}
		
"*line_break"	{fprintf(yyout,"line_break command");return YY_LINE_BREAK;}
			
"*input_text"	{fprintf(yyout,"input_text command");return YY_INPUT_TEXT;}
						
"*input_number"	{fprintf(yyout,"input_number command"); return YY_INPUT_NUMBER;}
						
"*rand"		{fprintf(yyout,"rand command");return YY_RAND;}
			
"*stat_chart"	{fprintf(yyout,"stat_chart command");return 				YY_STAT_CHART;}		
			
"*bug"		{fprintf(yyout,"bug command");return YY_BUG;}
		
"*page_break"	{fprintf(yyout,"page_break command"); return YY_PAGE_BREAK;}
			
"*hide_reuse"	{fprintf(yyout,"hide_reuse command");return YY_HIDE_REUSE;}
			
"*disable_reuse" {fprintf(yyout,"disable_reuse command");return 			YY_DISABLE_REUSE;}
			
"*gosub_scene"	{fprintf(yyout,"gosub_scene command");BEGIN(EXPR);return 				YY_GOSUB_SCENE;}
			
"*gosub"	{fprintf(yyout,"gosub command");BEGIN(EXPR);return YY_GOSUB;}
			
"*return"	{fprintf(yyout,"return command");return YY_RETURN;}
			
"*ending"	{fprintf(yyout,"ending command");return YY_ENDING;}
			
"*link"		{fprintf(yyout,"link command");return YY_LINK;}
"*title"	{fprintf(yyout,"title command");BEGIN(EXPR);return YY_TITLE;}
"*author"	{fprintf(yyout,"author command");BEGIN(EXPR); return YY_AUTHOR;}

#.+$            { fprintf(yyout,"%%CASE(%s)\n", strtok(yytext + 1, "\n\r"));
                  yylval.s = my_strdup( strtok(yytext + 1, "\n\r"));
                  return YY_CASE; }

 /* This part needs fixing */
"[b]" 		{fprintf(yyout,"begin bold");return YY_BEGINBOLD;}
"[/b]"           {fprintf(yyout,"end bold");return YY_ENDBOLD;}
"[i]" 		{fprintf(yyout,"begin italics");return YY_BEGINITALICS;}
"[/i]"           {fprintf(yyout,"end italics");return YY_ENDITALICS;}

<EXPR>"#{"[^}]+"}"      { fprintf(yyout,"Index"); }
<EXPR>"$"+"{"{CHAR}+"}" { fprintf(yyout,"Reference");}

<EXPR>{CHAR}+ { fprintf(yyout,"%%VAR(%s)\n", yytext);
                      yylval.s = my_strdup(yytext); return YY_VAR; }
{CHAR}+ { fprintf(yyout,"%%STR(%s)\n", yytext);
                      yylval.s = my_strdup(yytext); return YY_STRING; }
	

 
\$![{a-zA-Z}]+$	{ fprintf(yyout,"capitalize first letter of string");}
\$!![{a-zA-Z}]+$ { fprintf(yyout,"capitalize the entire string");}
\$[{a-zA-Z}]+$	{ fprintf(yyout,"quoted string");}

%%

int main(void) {
	yyout = fopen("cs.log","w");
	OUTPUT = fopen("output.tex","w");
        if (!OUTPUT){
		perror("startup.tex");
		exit(EXIT_FAILURE);
	}
	if (!yyout){
		perror("cs.log");
		exit(EXIT_FAILURE);
	}
	fprintf(yyout, "ChoiceScript -> LaTeX\n");
	yyparse();
	return EXIT_SUCCESS;
}

int yyerror(void) {
  fprintf(yyout, "(infile):%d: syntax yyout\n", yylineno);
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
   if (!check) abort();
   return check;
}

void *safe_malloc(size_t size){
    void* result = malloc(size);
    if(NULL==result){
	abort();
    }
    return result;
}

void import(char* file) {
 char* fullfile = safe_malloc(strlen(file) + strlen(".txt") + 1);
 strcpy(fullfile, file);
 strcat(fullfile, ".txt");
 FILE *f = fopen(fullfile, "r");
 if (!f) {
   perror(fullfile);
   free(fullfile);
   return;
 }
 fprintf(yyout, "Opened (%s)\n", fullfile);
 yylineno = 1;
 yypush_buffer_state(yy_create_buffer(f, YY_BUF_SIZE)); 
 free(fullfile);
 
 level = 1;
 yyparse(); /* Parse the includes recursively */
 level = 0;
}

