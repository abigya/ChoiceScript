BIN = ./scanner
OBJS = csparser.o lex.yy.o
CFLAGS = -Wall
YACC = bison
LEX = flex

all: $(BIN)

$(BIN): $(OBJS)
	$(CC) $(OBJS) -o $(BIN)

csparser.c csparser.h: choicescript_yyparser.y
	$(YACC) -d choicescript_yyparser.y -o csparser.c

lex.yy.c: choicescript_yylexer.l 
	$(LEX) -i choicescript_yylexer.l

test: $(BIN)
	(cd sample; ../$(BIN) <gosub.txt) 

latex: $(BIN)
	$(BIN) < sample/gosub.txt > gosub.tex 

clean:
	rm -f $(OBJS) $(BIN) lex.yy.c csparser.c csparser.h *.tex *.aux *.log *.pdf *.out



