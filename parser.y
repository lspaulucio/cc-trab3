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

AST *tree = NULL;

%}

%define api.value.type {AST*} // Type of variable yylval;

%token ELSE IF INPUT INT OUTPUT RETURN VOID WHILE WRITE PLUS MINUS TIMES OVER LT LE GT GE EQ NEQ ASSIGN SEMI COMMA LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE NUM ID STRING
%left LT LE GT GE EQ NEQ
%left PLUS MINUS  /* Ops associativos a esquerda. */
%left TIMES OVER  /* Mais para baixo maior precedencia. */

//Start symbol for the gramar
%start program

%%

program: func_decl_list                                  {tree = new_subtree("program", 1, $1);}
;

func_decl_list: func_decl_list func_decl                 {$$ = new_subtree("func_decl_list", 2, $1, $2);}
 			|	func_decl                                {$$ = new_subtree("func_decl_list", 1, $1);}
;

func_decl: func_header func_body                         {$$ = new_subtree("func_decl", 2, $1, $2);}
;

func_header: ret_type ID LPAREN params RPAREN            {$$ = new_subtree("func_header", 5, $1, $2, $3, $4, $5);}
;

func_body: LBRACE opt_var_decl opt_stmt_list RBRACE      {$$ = new_subtree("func_body", 4, $1, $2, $3, $4);}
;

opt_var_decl:	%empty                                   {$$ = new_subtree("opt_var_decl", 0);}
			|	var_decl_list                            {$$ = new_subtree("opt_var_decl", 1, $1);}
;

opt_stmt_list:	%empty                                   {$$ = new_subtree("opt_stmt_list", 0);}
			|	stmt_list                                {$$ = new_subtree("opt_stmt_list", 1, $1);}
;

ret_type: 	INT                                          {$$ = new_subtree("ret_type", 1, $1);}
		|	VOID                                         {$$ = new_subtree("ret_type", 1, $1);}
;

params:	VOID                                             {$$ = new_subtree("params", 1, $1);}
	|	param_list                                       {$$ = new_subtree("params", 1, $1);}
;

param_list:	param_list COMMA param                       {$$ = new_subtree("param_list", 3, $1, $2, $3);}
		|	param                                        {$$ = new_subtree("param_list", 1, $1);}
;

param:	INT ID                                           {$$ = new_subtree("param", 2, $1, $2);}
	|	INT ID LBRACK RBRACK                             {$$ = new_subtree("param", 2, $1, $2);}
;

var_decl_list:	var_decl_list var_decl                   {$$ = new_subtree("var_decl_list", 2, $1, $2);}
			|	var_decl                                 {$$ = new_subtree("var_decl_list", 1, $1);}
;

var_decl:	INT ID SEMI                                  {$$ = new_subtree("var_decl", 3, $1, $2, $3);}
		|	INT ID LBRACK NUM RBRACK SEMI                {$$ = new_subtree("var_decl", 6, $1, $2, $3, $4, $5, $6);}
;

stmt_list: 	stmt_list stmt                               {$$ = new_subtree("stmt_list", 2, $1, $2);}
		|	stmt                                         {$$ = new_subtree("stmt_list", 1, $1);}
;

stmt:	assign_stmt                                      {$$ = new_subtree("stmt", 1, $1);}
	|	if_stmt                                          {$$ = new_subtree("stmt", 1, $1);}
	|	while_stmt                                       {$$ = new_subtree("stmt", 1, $1);}
	|	return_stmt                                      {$$ = new_subtree("stmt", 1, $1);}
	|	func_call SEMI                                   {$$ = new_subtree("stmt", 2, $1, $2);}
;

assign_stmt:	lval ASSIGN arith_expr SEMI              {$$ = new_subtree("assign_stmt", 4, $1, $2, $3, $4);}
;

lval:	ID                                               {$$ = new_subtree("lval", 1, $1);}
	|	ID LBRACK NUM RBRACK                             {$$ = new_subtree("lval", 4, $1, $2, $3, $4);}
	|	ID LBRACK ID RBRACK                              {$$ = new_subtree("lval", 4, $1, $2, $3, $4);}
;

if_stmt:	IF LPAREN bool_expr RPAREN block             {$$ = new_subtree("if_stmt", 5, $1, $2, $3, $4, $5);}
		|	IF LPAREN bool_expr RPAREN block ELSE block  {$$ = new_subtree("if_stmt", 7, $1, $2, $3, $4, $5, $6, $7);}
;

block:	LBRACE opt_stmt_list RBRACE                      {$$ = new_subtree("block", 3, $1, $2, $3);}
;

while_stmt: WHILE LPAREN bool_expr RPAREN block          {$$ = new_subtree("while_stmt", 5, $1, $2, $3, $4, $5);}
;

return_stmt:	RETURN SEMI                              {$$ = new_subtree("return_stmt", 2, $1, $2);}
			|	RETURN arith_expr SEMI                   {$$ = new_subtree("return_stmt", 3, $1, $2, $3);}
;

func_call:	output_call                                  {$$ = new_subtree("func_call", 1, $1);}
		|	write_call                                   {$$ = new_subtree("func_call", 1, $1);}
		|	user_func_call                               {$$ = new_subtree("func_call", 1, $1);}
;

input_call: INPUT LPAREN RPAREN                          {$$ = new_subtree("input_call", 3, $1, $2, $3);}
;

output_call: OUTPUT LPAREN arith_expr RPAREN             {$$ = new_subtree("output_call", 4, $1, $2, $3, $4);}
;

write_call: WRITE LPAREN STRING RPAREN                   {$$ = new_subtree("write_call", 4, $1, $2, $3, $4);}
;

user_func_call:	ID LPAREN opt_arg_list RPAREN            {$$ = new_subtree("user_func_call", 4, $1, $2, $3, $4);}
;

opt_arg_list:	%empty                                   {$$ = new_subtree("opt_arg_list", 0);}
			|	arg_list                                 {$$ = new_subtree("opt_arg_list", 1, $1);}
;

arg_list: 	arg_list COMMA arith_expr                    {$$ = new_subtree("arg_list", 3, $1, $2, $3);}
		|	arith_expr                                   {$$ = new_subtree("arg_list", 1, $1);}
;

bool_expr:	arith_expr bool_op arith_expr                {$$ = new_subtree("bool_expr", 3, $1, $2, $3);}
;

bool_op: 	LT                                           {$$ = new_subtree("bool_op", 1, $1);}
		|	LE                                           {$$ = new_subtree("bool_op", 1, $1);}
		|	GT                                           {$$ = new_subtree("bool_op", 1, $1);}
		|	GE                                           {$$ = new_subtree("bool_op", 1, $1);}
		|	EQ                                           {$$ = new_subtree("bool_op", 1, $1);}
		|	NEQ                                          {$$ = new_subtree("bool_op", 1, $1);}
;

arith_expr: LPAREN arith_expr RPAREN                     {$$ = new_subtree("arith_expr", 3, $1, $2, $3);}
		|	lval                                         {$$ = new_subtree("arith_expr", 1, $1);}
		|	input_call                                   {$$ = new_subtree("arith_expr", 1, $1);}
		|	user_func_call                               {$$ = new_subtree("arith_expr", 1, $1);}
        |   arith_expr PLUS arith_expr                   {$$ = new_subtree("arith_expr", 3, $1, $2, $3);}
        |   arith_expr MINUS arith_expr                  {$$ = new_subtree("arith_expr", 3, $1, $2, $3);}
        |   arith_expr TIMES arith_expr                  {$$ = new_subtree("arith_expr", 3, $1, $2, $3);}
        |   arith_expr OVER arith_expr                   {$$ = new_subtree("arith_expr", 3, $1, $2, $3);}
        |	NUM                                          {$$ = new_subtree("arith_expr", 1, $1);}
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
        //print_dot(tree);
  	     //printf("PARSE SUCESSFUL!\n");

    //print_AST(tree);
    free_tree(tree);
    return 0;
}
