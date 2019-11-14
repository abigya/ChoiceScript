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

\x1             { fputs("{\n", stderr); brace_balance++; return YY_PINDENT;}
\x2		{ fputs("}\n", stderr); brace_balance--; return YY_NINDENT;}

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


"*choice"	{/*fprintf(stderr,"CHOICE\n"); */return YY_CHOICE; }
"*create"	{/*/*fprintf(stderr,"CREATE");*/ BEGIN(EXPR); return YY_CREATE; }
"*else"		{/*/*fprintf(stderr,"ELSE");*/ return YY_ELSE; }
"*elseif"	{/*/*fprintf(stderr,"ELIF");*/ BEGIN(EXPR); return YY_ELSEIF; }	
"*finish"	{return YY_FINISH; }
"*goto"		{/*/*fprintf(stderr,"GOTO");*/ BEGIN(EXPR); return YY_GOTO; }
"*goto_scene"	{BEGIN(EXPR); return YY_GOTO_SCENE; }
"*if"		{/*/*fprintf(stderr,"IF");*/ BEGIN(EXPR); return YY_IF; }
"*label"	{/*/*fprintf(stderr,"LABEL");*/ BEGIN(EXPR); return YY_LABEL; }
"*scene_list"	{/*/*fprintf(stderr,"SCENE_LIST");*/ return YY_SCENE_LIST; }
"*set"		{/*/*fprintf(stderr,"SET");*/ BEGIN(EXPR); return YY_SET; }
		
"*image"	{/*fprintf(stderr,"image command");*/return YY_IMAGE;}
		
"*line_break"	{/*fprintf(stderr,"line_break command");*/ return YY_LINE_BREAK;}
			
"*input_text"	{/*fprintf(stderr,"input_text command");*/ return YY_INPUT_TEXT;}
						
"*input_number"	{/*fprintf(stderr,"input_number command");*/ return YY_INPUT_NUMBER;}
						
"*rand"		{/*fprintf(stderr,"rand command");*/return YY_RAND;}
			
"*stat_chart"	{/*fprintf(stderr,"stat_chart command");*/return YY_STAT_CHART;}		
			
"*bug"		{/*fprintf(stderr,"bug command");*/return YY_BUG;}
		
"*page_break"	{/*fprintf(stderr,"page_break command"); */return YY_PAGE_BREAK;}
			
"*hide_reuse"	{/*fprintf(stderr,"hide_reuse command");*/return YY_HIDE_REUSE;}
			
"*disable_reuse" {/*fprintf(stderr,"disable_reuse command");*/return YY_DISABLE_REUSE;}
			
"*gosub_scene"	{/*fprintf(stderr,"gosub_scene command");*/BEGIN(EXPR);return YY_GOSUB_SCENE;}
			
"*gosub"	{/*fprintf(stderr,"gosub command");*/BEGIN(EXPR);return YY_GOSUB;}
			
"*return"	{/*fprintf(stderr,"return command"); */return YY_RETURN;}
			
"*ending"	{/*fprintf(stderr,"ending command");*/return YY_ENDING;}
			
"*link"		{ /*fprintf(stderr,"link command");*/ return YY_LINK;}
"*title"	{ /*fprintf(stderr,"title command"); */BEGIN(EXPR);return YY_TITLE;}
"*author"	{ /*fprintf(stderr,"author command");*/BEGIN(EXPR); return YY_AUTHOR;}

#.+$            { printf("%%CASE(%s)\n", strtok(yytext + 1, "\n\r"));
                  yylval.s = my_strdup( strtok(yytext + 1, "\n\r"));
                  return YY_CASE; }

 /* This part needs fixing */
"[b]" 		{/*fprintf(stderr,"begin bold");*/return YY_BEGINBOLD;}
"[/b]"           {/*fprintf(stderr,"end bold"); */return YY_ENDBOLD;}
"[i]" 		{/*fprintf(stderr,"begin italics");*/return YY_BEGINITALICS;}
"[/i]"           {/*fprintf(stderr,"end italics"); */return YY_ENDITALICS;}

<EXPR>"#{"[^}]+"}"      { puts("Index"); }
<EXPR>"$"+"{"{CHAR}+"}" { puts("%Reference");}

<EXPR>{CHAR}+ { fprintf(stderr,"%%VAR(%s)\n", yytext);
                      yylval.s = my_strdup(yytext); return YY_VAR; }
{CHAR}+ { fprintf(stderr,"%%STR(%s)\n", yytext);
                      yylval.s = my_strdup(yytext); return YY_STRING; }
	

 
\$![{a-zA-Z}]+$	{ fprintf(stderr,"capitalize first letter of string");}
\$!![{a-zA-Z}]+$ { fprintf(stderr,"capitalize the entire string");}
\$[{a-zA-Z}]+$	{ fprintf(stderr,"quoted string");}

%%

int main(void) {
	fprintf(stderr, "ChoiceScript -> LaTeX\n");
	yyparse();
	return EXIT_SUCCESS;
}

int yyerror(void) {
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
 fprintf(stderr, "Opened (%s)\n", fullfile);
 yylineno = 1;
 yypush_buffer_state(yy_create_buffer(f, YY_BUF_SIZE)); 
 free(fullfile);
 
 level = 1;
 yyparse(); /* Parse the includes recursively */
 level = 0;
}

