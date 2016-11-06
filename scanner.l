/* 1º Trabalho de compiladores */
/* Aluno: Leonardo Santos Paulucio */
/* Scanner para Linguagem C-Minus */

/* Opcoes flex */
%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "ast.h"
    #include "tables.h"
    #include "parser.h"

    #define process_token(type) yylval = create_node(yytext); return type

    void process(const char*);
	void process_error();

    extern LitTable *lt;
    extern SymTable *aux;
%}

/*Palavras Reservadas*/
ELSE "else"
IF "if"
INPUT "input"
INT "int"
OUTPUT "output"
RETURN "return"
VOID "void"
WHILE "while"
WRITE "write"
/*Operadores Aritmeticos e de comparacao*/
PLUS "+"
MINUS "-"
TIMES "*"
OVER "/"
LT "<"
LE "<="
GT ">"
GE ">="
EQ "=="
NEQ "!="
ASSIGN "="
/*Tokens*/
SEMI ";"
COMMA ","
LPAREN "("
RPAREN ")"
LBRACK "["
RBRACK "]"
LBRACE "{"
RBRACE "}"

ID [a-zA-Z]+[a-zA-Z0-9]*
NUM [0-9]+
STRING \".*\"

/* Comments are handled in the rules section. First we need to define a start condition. */
%x          L_COMMENT ML_COMMENT

%%
{ELSE} {return ELSE;}
{IF} {return IF;}
{INPUT} {process_token(INPUT);}
{INT} {process_token(INT);}
{OUTPUT} {process_token(OUTPUT);}
{RETURN} {process_token(RETURN);}
{VOID} {process_token(VOID);}
{WHILE} {return WHILE;}
{WRITE} {return WRITE;}

{PLUS} {process_token(PLUS);}
{MINUS} {process_token(MINUS);}
{TIMES} {process_token(TIMES);}
{OVER} {process_token(OVER);}
{LT} {process_token(LT);}
{LE} {process_token(LE);}
{GT} {process_token(GT);}
{GE} {process_token(GE);}
{EQ} {process_token(EQ);}
{NEQ} {process_token(NEQ);}
{ASSIGN} {return ASSIGN;}

{SEMI} {return SEMI;}
{COMMA} {return COMMA;}
{LPAREN} {return LPAREN;}
{RPAREN} {return RPAREN;}
{LBRACK} {return LBRACK;}
{RBRACK} {return RBRACK;}
{LBRACE} {return LBRACE;}
{RBRACE} {return RBRACE;}
{NUM} {process_token(NUM);}
{ID} {process_token(ID);}
{STRING} { yylval = create_node("string"); return STRING;}
"\n"            yylineno++; /* eat up a single line */

[ \t]+          /* eat up whitespace */

"//"                 BEGIN(L_COMMENT); /* line comments */
<L_COMMENT>[^\n]* /* eat anything that’s not a \n */
<L_COMMENT>"\n"    yylineno++; BEGIN(INITIAL);

"/*"                 BEGIN(ML_COMMENT); /* multi-line comments */
<ML_COMMENT>[^\n] /* eat anything that’s not a \n */
<ML_COMMENT>"\n"    yylineno++;
<ML_COMMENT>"*/"\n    BEGIN(INITIAL);

. {process_error();}

%%

void process(const char* token)
{
		printf("%d: %s -> %s\n",yylineno, yytext, token);
}

/*void processId()
{
    yylval = add_var(aux, yytext, yylineno);
}

void process_string()
{
    yylval = add_literal(lt, yytext);
}*/

void process_error()
{
    printf("SCANNING ERROR (%d): Unknown symbol %c\n", yylineno, yytext[0]);
    exit(1);
}

/*int main()
{
    yylex();
    return 0;
}*/
