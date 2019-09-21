TARGET = scanner
OBJS = lex.yy.o interpreter.o

all: $(TARGET)

scanner: $(OBJS)
	$(CC) $(OBJS) -o $(TARGET)

lex.yy.o: lex.yy.c 

lex.yy.c: choicescript_yylexer.l
	  flex -I choicescript_yylexer.l

test:
	scanner foo.js
clean:
	rm -f $(OBJS) $(TARGET) lex.yy.c
