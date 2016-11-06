/* 3º Trabalho de compiladores */
/* Aluno: Leonardo Santos Paulucio */
/* Analisador Semantico para Linguagem C-Minus */

/* Options to bison */
// File name of generated parser.
%output "parser.c"
// Produces a 'parser.h'
%defines "parser.h"
// Give proper error messages when a syntax error is found.
%define parse.error verbose
// Enable LAC (lookahead correction) to improve syntax error handling.
%define parse.lac full

// Enable the trace option so that debugging is possible.
%define parse.trace

%{
#include <stdio.h>
#include "ast.h"
#include "tables.h"

int yylex(void);
void yyerror(char const *s);

extern int yylineno;

AST *tree = NULL;    //AST
LitTable *lt = NULL; //Literals Table
SymTable *st = NULL; //Symbols Table
SymTable *aux = NULL; 
SymTable *ft = NULL; //Functions table

%}

%define api.value.type {AST*} // Type of variable yylval;

%token ELSE IF INPUT INT OUTPUT RETURN VOID WHILE WRITE PLUS MINUS TIMES OVER LT LE GT GE EQ NEQ ASSIGN SEMI COMMA LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE NUM ID STRING
%left LT LE GT GE EQ NEQ
%left PLUS MINUS  /* Ops associativos a esquerda. */
%left TIMES OVER  /* Mais para baixo maior precedencia. */

//Start symbol for the gramar
%start program

%%

program: func_decl_list                                 {tree = $1;}
;

func_decl_list: func_decl_list func_decl                 {$$ = $1; add_leaf($1, $2);}
 			|	func_decl                                {$$ = new_subtree("func_list", 1, $1);}
;

func_decl: func_header func_body                         {$$ = new_subtree("func_decl", 2, $1, $2);}
;

func_header: ret_type ID LPAREN params RPAREN            {$$ = new_subtree("func_header", 3, $1, $2, $4);}
;

func_body: LBRACE opt_var_decl opt_stmt_list RBRACE      {$$ = new_subtree("func_body", 2, $2, $3);}
;

opt_var_decl:	%empty                                   {$$ = new_subtree("var_list", 0);}
			|	var_decl_list                            {$$ = $1;}
;

opt_stmt_list:	%empty                                   {$$ = new_subtree("block", 0);}
			|	stmt_list                                {$$ = $1;}
;

ret_type: 	INT                                          {$$ = $1;}
		|	VOID                                         {$$ = $1;}
;

params:	VOID                                             {$$ = $1;}
	|	param_list                                       {$$ = $1;}
;

param_list:	param_list COMMA param                       {$$ = $1; add_leaf($1, $3);}
		|	param                                        {$$ = new_subtree("param_list", 1, $1);}
;

param:	INT ID                                           {$$ = new_subtree("param", 2, $1, $2);}
	|	INT ID LBRACK RBRACK                             {$$ = new_subtree("param", 2, $1, $2);}
;

var_decl_list:	var_decl_list var_decl                   {$$ = $1; add_leaf($1, $2);}
			|	var_decl                                 {$$ = new_subtree("var_list", 1, $1);}
;

var_decl:	INT ID SEMI                                  {$$ = new_subtree("var_decl", 2, $1, $2);}
		|	INT ID LBRACK NUM RBRACK SEMI                {$$ = new_subtree("var_decl", 3, $1, $2, $4);}
;

stmt_list: 	stmt_list stmt                               {$$ = $1; add_leaf($1, $2);}
		|	stmt                                         {$$ = new_subtree("block", 1, $1);}
;

stmt:	assign_stmt                                      {$$ = $1;}
	|	if_stmt                                          {$$ = $1;}
	|	while_stmt                                       {$$ = $1;}
	|	return_stmt                                      {$$ = $1;}
	|	func_call SEMI                                   {$$ = $1;}
;

assign_stmt:	lval ASSIGN arith_expr SEMI              {$$ = new_subtree("=", 2, $1, $3);}
;

lval:	ID                                               {$$ = $1;}
	|	ID LBRACK NUM RBRACK                             {$$ = new_subtree("lval", 2, $1, $3);}
	|	ID LBRACK ID RBRACK                              {$$ = new_subtree("lval", 2, $1, $3);}
;

if_stmt:	IF LPAREN bool_expr RPAREN block             {$$ = new_subtree("if_stmt", 2, $3, $5);}
		|	IF LPAREN bool_expr RPAREN block ELSE block  {$$ = new_subtree("if_stmt", 3, $3, $5, $7);}
;

block:	LBRACE opt_stmt_list RBRACE                      {$$ = $2;}
;

while_stmt: WHILE LPAREN bool_expr RPAREN block          {$$ = new_subtree("while_stmt", 2, $3, $5);}
;

return_stmt:	RETURN SEMI                              {$$ = new_subtree("return_stmt", 0);}
			|	RETURN arith_expr SEMI                   {$$ = new_subtree("return_stmt", 1, $2);}
;

func_call:	output_call                                  {$$ = $1;}
		|	write_call                                   {$$ = $1;}
		|	user_func_call                               {$$ = $1;}
;

input_call: INPUT LPAREN RPAREN                          {$$ = $1;}
;

output_call: OUTPUT LPAREN arith_expr RPAREN             {$$ = $1; add_leaf($1, $3);}
;

write_call: WRITE LPAREN STRING RPAREN                   {$$ = new_subtree("write", 1, $3);}
;

user_func_call:	ID LPAREN opt_arg_list RPAREN            {$$ = new_subtree("user_func_call", 2, $1, $3);}
;

opt_arg_list:	%empty                                   {$$ = new_subtree("arg_list", 0);}
			|	arg_list                                 {$$ = $1;}
;

arg_list: 	arg_list COMMA arith_expr                    {$$ = new_subtree("arg_list", 2, $1, $3);}
		|	arith_expr                                   {$$ = new_subtree("arg_list", 1, $1);}
;

bool_expr:	arith_expr bool_op arith_expr                {$$ = $2; add_leaf($2, $1); add_leaf($2, $3);}
;

bool_op: 	LT                                           {$$ = $1;}
		|	LE                                           {$$ = $1;}
		|	GT                                           {$$ = $1;}
		|	GE                                           {$$ = $1;}
		|	EQ                                           {$$ = $1;}
		|	NEQ                                          {$$ = $1;}
;

arith_expr: LPAREN arith_expr RPAREN                     {$$ = $2;}
		|	lval                                         {$$ = $1;}
		|	input_call                                   {$$ = $1;}
		|	user_func_call                               {$$ = $1;}
        |   arith_expr PLUS arith_expr                   {$$ = $2; add_leaf($2, $1); add_leaf($2, $3);}
        |   arith_expr MINUS arith_expr                  {$$ = $2; add_leaf($2, $1); add_leaf($2, $3);}
        |   arith_expr TIMES arith_expr                  {$$ = $2; add_leaf($2, $1); add_leaf($2, $3);}
        |   arith_expr OVER arith_expr                   {$$ = $2; add_leaf($2, $1); add_leaf($2, $3);}
        |	NUM                                          {$$ = $1;}
;

%%

void yyerror (char const *s)
{
	printf("PARSE ERROR (%d): %s\n", yylineno, s);
}



int main()
{
    //yydebug = 1; // Enter debug mode.
    if(!yyparse())
        print_dot(tree);
  	     //printf("PARSE SUCESSFUL!\n");

    /*print_AST(tree);*/
    free_tree(tree);
    return 0;
}
