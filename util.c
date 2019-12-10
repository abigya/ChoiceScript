/** 
*@file util.c 
*@author Abigya Devkota and Dmitry Zinoviev
*@date December 3, 2019
*@brief C file with important functions 
*/

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

/**
*If there is an error in any given opened file, this function displays the line number where it exists and terminates the parser. 
* @param None
* @return No return value. 
*/
int yyerror(void) {
  fprintf(stderr, "(infile):%d: syntax yyout\n", yylineno);
  exit(EXIT_FAILURE);      
}

/**
*This is a safe function built on strdup. 
*It prevents strdup from processing a null pointer. 
* @param ptr A character pointer.
* @return Returns a copy of the parameter. 
*/
char *my_strdup(const char *ptr){
   void* check = strdup(ptr);
   if (!check) abort();
   return check;
}
/**
*This is a safe function built on malloc. 
*It prevents malloc from allocating memory for a null pointer.
* @param size Size of memory to be allocated.
* @return Allocated memory for the given size. 
*/
void *safe_malloc(size_t size){
    void* result = malloc(size);
    if(NULL==result){
	abort();
    }
    return result;
}
/**
*This is the main function of the parser. 
*It allows the user to enter their own output filename. 
*If no filename is given, the output goes to startup.tex.
*The parser terminates if any errors are found. 
*yyparse() is called if there are no errors. 
*All diagnostic messages are sent to cs.log through yyout. 
*/
int main(int argc, char *argv[]) {
	yyout = fopen("cs.log","w");
	if (!yyout){
		perror("cs.log");
		exit(EXIT_FAILURE);
	}
	char *outfilename = argc!=2 ? "startup.tex" : argv[1];
	  OUTPUT = fopen(outfilename,"w");
	  if (!OUTPUT){
			perror(outfilename);
			return EXIT_FAILURE;
	  }
	
        
	
	fprintf(stderr, "ChoiceScript -> LaTeX\n");
	yyparse(); 
	return EXIT_SUCCESS;
}

