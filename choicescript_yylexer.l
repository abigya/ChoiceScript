/** 
*@file choicescript_yylexer.l 
*@author Abigya Devkota and Dmitry Zinoviev
*@date December 3, 2019 
*@brief Lex file with tokens 
*/
%{
#include "csparser.h"
 

  
  int brace_balance = 0; /**< Maintain the balance of braces */
  FILE *OUTPUT; /**< File handle for ouput*/
  FILE *yyout; /**< File handle for diagnostic print outs*/
 
%}


%option noyywrap
%option noinput
%option yylineno

EOL     [[:space:]]{-}[[:blank:]]
D	 [[:digit:]]
INT     [+-]?{D}+
FLT     [+-]?(({D}+"."{D}*)|("."{D}+))
CHAR    [^[:space:]\x1\x2[]


%s 	EXPR

%%

"*comment".*$   /**< comment */
{EOL}           { BEGIN(INITIAL); /**< Remove line breaks */ }
^[[:space:]]*$  /* Skip blank lines */
^[[:blank:]]+   { adjustIndent(yytext); /* Indent */ }
^[[:^space:]]+  { BEGIN(INITIAL); yyless(0); adjustIndent(""); /**< Outdent */ }
<<EOF>>	        { /**< End of file */
  if (brace_balance == 0) { /**< Return to the includer */
    yypop_buffer_state();
    yyterminate();
    BEGIN(INITIAL); 
  } else { /**< "unread" the missing unindents */
    adjustIndent("");
  }
 };

\x1   { fprintf(yyout,"{\n"); brace_balance++; 
					return YY_PINDENT;} /**< @return Token to parser when positive indentation is detected*/
\x2		{ fprintf(yyout,"}\n"); brace_balance--; 
					return YY_NINDENT;} /**< @return Token to parser when negative indentation is detected*/

<EXPR>{INT}   	{ yylval.i = atoi(yytext); 
					return YY_INT;} /**< @return Token to parser when an integer is found*/
<EXPR>{FLT}   	{ yylval.d = atoi(yytext); 
					return YY_FLOAT; } /**< @return Token to parser when a floating point number is found*/
<EXPR>"and"	{ return YY_AND;} /**< @return Token to parser when and operator is found*/
<EXPR>"not"	{ return YY_NOT;} /**< @return Token to parser when not operator is found*/
<EXPR>"+" 	{ return yytext[0];} /**<Addition*/
<EXPR>"-"	{ return yytext[0];} /**<Subtraction*/
<EXPR>"/"	{ return yytext[0];}/**<Division*/
<EXPR>"*" 	{ return yytext[0];}/**<Multiplication*/
<EXPR>">" 	{ return yytext[0];}/**<Greater than*/
<EXPR>"<"	{ return yytext[0];}/**<Less than*/
<EXPR>"=" 	{ return yytext[0];}/**<Equal to*/
<EXPR>"&"	{ return yytext[0];}/**<And*/
<EXPR>','       { return yytext[0];}/**<Commas, preferably for funciton calls*/
<EXPR>"("	{ return yytext[0];}/**<Open bracket for function calls*/
<EXPR>")"       { return yytext[0];}/**<Close bracket for function calls*/
 /**possibly missing <= >= != OR NOT**/


"*choice"	{fprintf(yyout,"CHOICE\n"); 
						return YY_CHOICE; } /**< @return Token to parser when choice is found*/
"*fake_choice"	{fprintf(yyout,"FAKE_CHOICE\n"); 
						return YY_FAKE_CHOICE; } /**< @return Token to parser when fake_choice is found*/
"*create"	{fprintf(yyout,"CREATE\n"); BEGIN(EXPR); 
						return YY_CREATE; } /**< @return Token to parser when create is found*/
"*else"		{fprintf(yyout,"ELSE\n"); 
						return YY_ELSE; } /**< @return Token to parser when else is found*/
"*elseif"	{fprintf(yyout,"ELIF\n"); BEGIN(EXPR); 
						return YY_ELSEIF; } /**< @return Token to parser when elseif is found*/	
"*finish"	{fprintf(yyout,"FINISH\n");
						return YY_FINISH; } /**< @return Token to parser when finish is found*/
"*goto"		{fprintf(yyout,"GOTO\n");BEGIN(EXPR);
						return YY_GOTO; } /**< @return Token to parser when goto is found*/
"*goto_scene"	{fprintf(yyout,"GOTO_SCENE\n");BEGIN(EXPR); 
						return YY_GOTO_SCENE; } /**< @return Token to parser when goto_scene is found*/
"*goto_random_scene" {fprintf(yyout,"GOTO_RANDOM_SCENE\n");BEGIN(EXPR); 
						return YY_GOTO_RANDOM_SCENE; } /**< @return Token to parser when goto_random_scene is found*/
"*if"		{fprintf(yyout,"IF\n");BEGIN(EXPR); 
						return YY_IF; }/**< @return Token to parser when if is found*/
"*label"	{fprintf(yyout,"LABEL\n");BEGIN(EXPR); 
						return YY_LABEL; } /**< @return Token to parser when label is found*/
"*scene_list"	{fprintf(yyout,"SCENE_LIST\n");
						return YY_SCENE_LIST; }/**< @return Token to parser when scene_list is found*/
"*set"		{fprintf(yyout,"SET\n");BEGIN(EXPR); 
						return YY_SET; }/**< @return Token to parser when set is found*/
		
"*image"	{fprintf(yyout,"image command\n");
						return YY_IMAGE;}/**< @return Token to parser when image is found*/
		
"*line_break"	{fprintf(yyout,"line_break command\n");
						return YY_LINE_BREAK;}/**< @return Token to parser when line_break is found*/
			
"*input_text"	{fprintf(yyout,"input_text command\n");
						return YY_INPUT_TEXT;}/**< @return Token to parser when iput_text is found*/
						
"*input_number"	{fprintf(yyout,"input_number command\n"); 
						return YY_INPUT_NUMBER;}/**< @return Token to parser when input_number is found*/
						
"*rand"		{fprintf(yyout,"rand command\n");
						return YY_RAND;}/**< @return Token to parser when rand is found*/
			
"*stat_chart"	{fprintf(yyout,"stat_chart command");
						return YY_STAT_CHART;} /**< @return Token to parser when stat_chart is found*/		
			
"*bug"		{fprintf(yyout,"bug command");
						return YY_BUG;} /**< @return Token to parser when bug is found*/
		
"*page_break"	{fprintf(yyout,"page_break command"); 
						return YY_PAGE_BREAK;}/**< @return Token to parser when page_break is found*/
			
"*hide_reuse"	{fprintf(yyout,"hide_reuse command");
						return YY_HIDE_REUSE;}/**< @return Token to parser when hide_reuse is found*/
			
"*disable_reuse" {fprintf(yyout,"disable_reuse command");
						return YY_DISABLE_REUSE;}/**< @return Token to parser when disable_reuse is found*/
"*allow_reuse" {fprintf(yyout,"allow_reuse command");
						return YY_ALLOW_REUSE;}/**< @return Token to parser when allow_reuse is found*/
			
"*gosub_scene"	{fprintf(yyout,"gosub_scene command");BEGIN(EXPR);
						return YY_GOSUB_SCENE;}/**< @return Token to parser when gosub_scene is found*/
			
"*gosub"	{fprintf(yyout,"gosub command");BEGIN(EXPR);
						return YY_GOSUB;}/**< @return Token to parser when gosub is found*/
			
"*return"	{fprintf(yyout,"return command");
						return YY_RETURN;}/**< @return Token to parser when return is found*/
			
"*ending"	{fprintf(yyout,"ending command");
						return YY_ENDING;}/**< @return Token to parser when ending is found*/
			
"*link"		{fprintf(yyout,"link command");
						return YY_LINK;}/**< @return Token to parser when link is found*/
"*title"	{fprintf(yyout,"title command");BEGIN(EXPR);
						return YY_TITLE;}/**< @return Token to parser when title is found*/
"*author"	{fprintf(yyout,"author command");BEGIN(EXPR); 
						return YY_AUTHOR;}/**< @return Token to parser when author is found*/
"*more_games"	{fprintf(yyout,"more_games command"); 
						return YY_MORE_GAME;}/**< @return Token to parser when more_games is found*/
"*share_this_game"	{fprintf(yyout,"share_this_game command"); 
						return YY_SHARE_GAME;}/**< @return Token to parser when share_this_game is found*/
"*achieve"	{fprintf(yyout,"achieve command");BEGIN(EXPR); 
						return YY_ACHIEVE;}/**< @return Token to parser when achieve is found*/	
"*show_password" {fprintf(yyout,"show_password command"); 
						return YY_SHOW_PASSWORD;}/**< @return Token to parser when show_password is found*/
"*restore_game"	{fprintf(yyout,"restore_game command"); 
						return YY_RESTORE_GAME;}/**< @return Token to parser when restore_game is found*/
[[:blank:]]+"-"[[:blank:]]+	{yylval.s = "---"; 
						return YY_STRING; } /**< @return Token to parser when an empty string is found*/


#.+$            { fprintf(yyout,"%%CASE(%s)\n", strtok(yytext + 1, "\n\r"));
                  yylval.s = my_strdup( strtok(yytext + 1, "\n\r"));
                  return YY_CASE; } /**< @return Token to parser when a case is found*/

 /* This part needs fixing */
"[b]" 		{fprintf(yyout,"begin bold");
					return YY_BEGINBOLD;} /**< @return Token to parser when begin bold tag is found*/
"[/b]"           {fprintf(yyout,"end bold");
					return YY_ENDBOLD;}/**< @return Token to parser when end bold tag is found*/
"[i]" 		{fprintf(yyout,"begin italics");
					return YY_BEGINITALICS;} /**< @return Token to parser when begin italics tag is found*/
"[/i]"           {fprintf(yyout,"end italics");
					return YY_ENDITALICS;} /**< @return Token to parser when end italics tag is found*/

<EXPR>"#{"[^}]+"}"      { fprintf(yyout,"Index"); }
<EXPR>"$"+"{"{CHAR}+"}" { fprintf(yyout,"Reference");}

<EXPR>{CHAR}+ { fprintf(yyout,"%%VAR(%s)\n", yytext);
                      yylval.s = my_strdup(yytext); 
			return YY_VAR; } /**< @return Token to parser when a variable is found*/
{CHAR}+ { fprintf(yyout,"%%STR(%s)\n", yytext);
                      yylval.s = my_strdup(yytext); 
			 return YY_STRING; }/**< @return Token to parser when a string is found*/
	

 
\$![{a-zA-Z}]+$	{ fprintf(yyout,"capitalize first letter of string");}
\$!![{a-zA-Z}]+$ { fprintf(yyout,"capitalize the entire string");}
\$[{a-zA-Z}]+$	{ fprintf(yyout,"quoted string");}
[[:blank:]]     /**< Remove single spaces */

%%

/**
*This function records the change in indentation in the ChoiceScript text files.
*\x1 marks positive indentation.
*\x2 marks negative indentation.
*For the parser to fully read a file, positive indents must match negative indents. 
*@param text A character pointer. 
*@return No return value.
*/
void adjustIndent(char* text){
  static int depth = 0;
  int new_depth = strlen(text);
  for (int i = 0; i < new_depth - depth; i++) unput('\x1');
  for (int i = 0; i < depth - new_depth; i++) unput('\x2');
  depth = new_depth;
}



