# /* LAVINIA TUDOR 334CC */

all: tema

tema: tema.l
	flex tema.l
	g++ lex.yy.c -o tema -lfl

clean:
	rm -f *.cc tema
	rm -rf out