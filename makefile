TARGET = ./scanner
OBJS = choicescript_yyparser.tab.o lex.yy.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET)

choicescript_yyparser.tab.c choicescript_yyparser.tab.h: choicescript_yyparser.y
	bison -d choicescript_yyparser.y

choicescript_yyparser.tab.o: choicescript_yyparser.tab.c

lex.yy.o: lex.yy.c 

lex.yy.c: choicescript_yylexer.l preprocess.l
	  flex -i choicescript_yylexer.l
	  flex -i choicescript_yylexer.l

test: $(TARGET)
	$(TARGET) <sample/variables.txt
clean:
	rm -f $(OBJS) $(TARGET) lex.yy.c choicescript_yyparser.tab.c choicescript_yyparser.tab.h



