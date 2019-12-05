BIN = ./scanner
OBJS = csparser.o lex.yy.o util.o
CFLAGS = -Wall -g
YACC = bison
LEX = flex

all: $(BIN)

$(BIN): $(OBJS)
	$(CC) $(OBJS) -o $(BIN)
	
util.o: util.c flex.h

csparser.c csparser.h: choicescript_yyparser.y
	$(YACC) -d choicescript_yyparser.y -o csparser.c

flex.h lex.yy.c: choicescript_yylexer.l 
	$(LEX) -i --header-file=flex.h choicescript_yylexer.l

test: $(BIN)
	(cd sample; ../$(BIN) <startup.txt) 

latex: $(BIN)
	(cd sample; ../$(BIN) < startup.txt ; pdflatex startup.tex)

clean:
	rm -f $(OBJS) $(BIN) lex.yy.c csparser.c csparser.h flex.h *.tex *.aux *.log *.pdf *.out
	(cd sample; rm -f *.tex *.aux *.log *.pdf *.out)
 


