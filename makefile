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
	(cd sample; ../$(BIN) <variables.txt) 

latex: $(BIN)
	$(BIN) < sample/variables.txt > startup.tex 

clean:
	rm -f $(OBJS) $(BIN) lex.yy.c csparser.c csparser.h startup.tex variables.aux variables.log variables.tex variables.pdf



