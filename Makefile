LEX = flex
YACC = bison
CC = gcc
FILENAME = RI

# $@ is the name of the file to be made.
# $? is the names of the changed dependents.
# $< the name of the related file that caused the action.
# $* the prefix shared by target and dependent files.

all : lex.yy.c $(wildcard *.tab.c) $(wildcard *.tab.h)
	$(CC) lex.yy.c $(wildcard *.tab.c) -o $(FILENAME)

lex.yy.c : $(FILENAME).l $(FILENAME).tab.h
	$(LEX) $(FILENAME).l
	
%.tab.c %.tab.h: %.y
	$(YACC) $< -d
