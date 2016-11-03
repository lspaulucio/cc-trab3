AUTHOR=LeonardoPaulucio

all: bison flex gcc
	@echo "Done."

bison: parser.y
	bison -v parser.y

flex: scanner.l
	flex scanner.l

gcc: scanner.c parser.c
	gcc -Wall -o trab3 scanner.c parser.c ast.c -ly

test: all
	./test.sh

dot:
	dot -Tpdf saida.dot -o saida.pdf

tar: clean
	tar -cvzf $(AUTHOR).tar.gz Makefile parser.y scanner.l

clean:
	@rm -f *.o *.output scanner.c parser.h parser.c parser trab3
