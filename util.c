#include "csparser.h"
#include "flex.h"

/**
*This function opens and reads a given text file after adding .txt to the parameter. 
*It is used to read the list of scenes for a given story. 
* @param file A character pointer, preferably a filename. 
* @return No return value. 
*/
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
 /**
 *Creates a buffer associated with the given file and large enough to hold YY_BUF_SIZE characters
 */
 yypush_buffer_state(yy_create_buffer(f, YY_BUF_SIZE));
 free(fullfile);
 fprintf(OUTPUT,"\\uppercase{\\chapter{%s}}\\label{%s}\n", file, file);
 level = 1;
 yyparse(); /**< Parse the includes recursively */
 level = 0;
}
