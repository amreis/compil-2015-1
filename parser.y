/*
  Galatasaralister

  Alister Machado dos Reis
  Daniel dos Santos Bossle
  Eduardo Faccin Vernier
*/
%{
#include <stdio.h>
#include "main.h"
%}

%union {
	struct comp_dict_item_t* valor_simbolo_lexico;
}

/* Declaração dos tokens da linguagem */
%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_STRING
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_DO
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_STATIC
%token TK_PR_CONST
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token <valor_simbolo_lexico> TK_LIT_INT
%token <valor_simbolo_lexico> TK_LIT_FLOAT
%token <valor_simbolo_lexico> TK_LIT_FALSE
%token <valor_simbolo_lexico> TK_LIT_TRUE
%token <valor_simbolo_lexico> TK_LIT_CHAR
%token <valor_simbolo_lexico> TK_LIT_STRING
%token <valor_simbolo_lexico> TK_IDENTIFICADOR
%token TOKEN_ERRO

%left '&'
%left '<' '>' TK_OC_LE TK_OC_GE TK_OC_EQ TK_OC_NE TK_OC_AND TK_OC_OR
%left '+' '-'
%left '*' '/'
%left '!'

%error-verbose

%%
/* Regras (e ações) da gramática */


/* A program is a sequence of global variable declarations and function
   declarations. It may also be empty. */
program  : program global_var_decl ';'
          | program gen_func_decl
          |
          ;
/* A global var declaration may be static, or a vector. Or just a simple one. */
global_var_decl : static_var_decl
                | simple_var_decl
                | vector_var_decl
                ;
/* A static variable is declared with the keyword 'static' in front of it. */
static_var_decl : TK_PR_STATIC simple_var_decl
                | TK_PR_STATIC vector_var_decl
                ;
/* A vector declaration has its identifier followed by [N], where N is the size. */
vector_var_decl : simple_var_decl '[' TK_LIT_INT ']' ;

/* A simple declaration needs only the type and the identifier. */
simple_var_decl : type TK_IDENTIFICADOR ;

/** FUNCTIONS */
/* A function can be static or not. */
gen_func_decl   : static_func_decl
                | simple_func_decl ;

/* If it's static, its declaration is preceded by the keyword 'static' */
static_func_decl: TK_PR_STATIC simple_func_decl ;

/* A function declaration needs a return type, an identifier and an (possibly
   empty) parameter list, followed by the function body surrounded by braces */
simple_func_decl: type TK_IDENTIFICADOR '(' params_list ')' command_block ;

/* The argument list may be empty or not */
params_list     : nonempty_params_list
                | ;

/* A list of parameters that is not empty is either a single parameter or a parameter 
   preceded by another non-empty list of arguments and a comma */
nonempty_params_list: param | nonempty_params_list ',' param ;

/* A parameter is like a variable declaration, but it might be const */
param           : TK_PR_CONST simple_var_decl | simple_var_decl ;

command_block   : '{' command_list '}' ;
command_list	: command
                | command_list ';' command ;


command         : flow_control | simple_command | invalid_stmt ;
simple_command	: local_var_decl
                | assignment
                | input_statement
                | output_statement
                | return_statement
                | command_block
                | /*empty*/
                | func_call
                ;
invalid_stmt : gen_func_decl { yyerror("Illegal function declaration ending"); return SINTATICA_ERRO; }
             | TK_PR_RETURN { yyerror("Return with no value"); return SINTATICA_ERRO; }
             | TK_PR_OUTPUT { yyerror("Output without values"); return SINTATICA_ERRO; }
// DECLARAÇÃO DE VARIÁVEL LOCAL
local_var_decl	: gen_local_var
				| gen_local_var TK_OC_LE TK_IDENTIFICADOR
				| gen_local_var TK_OC_LE     literal
				;
gen_local_var	: simple_local_var | static_local_var ;
simple_local_var: type TK_IDENTIFICADOR 
				| TK_PR_CONST type TK_IDENTIFICADOR 				
				;
static_local_var: TK_PR_STATIC simple_local_var 
				;
// ATRIBUIÇÃO
assignment		: TK_IDENTIFICADOR '=' expression 
				| TK_IDENTIFICADOR '[' expression ']' '=' expression 
				;

// ENTRADA
input_statement	: TK_PR_INPUT expression '=' '>' expression ; /* bug: you can have whitespace between '=' and '>' */

// SAÍDA
output_statement : TK_PR_OUTPUT comma_expr_list ;
comma_expr_list	: expression | comma_expr_list ',' expression ;

// RETORNO
return_statement: TK_PR_RETURN expression ;

// CHAMADA DE FUNÇÃO
func_call		: TK_IDENTIFICADOR '(' args_list ')' ;
args_list		: nonempty_args_list | /* empty */;
nonempty_args_list: expression | nonempty_args_list ',' expression ;


/** EXPRESSÕES LÓGICAS E ARITMÉTICAS **/
expression		: simple_expression
				| expression '+' expression
				| expression '-' expression
				| expression '*' expression
				| expression '/' expression
				| expression '<' expression
				| expression '>' expression
				| expression TK_OC_LE expression
				| expression TK_OC_GE expression
				| expression TK_OC_EQ expression
				| expression TK_OC_NE expression
				| expression TK_OC_AND expression
				| expression TK_OC_OR expression
				| expression '&' expression
				;
simple_expression : unary_operator simple_expression
				| expression_leaf
				| '(' expression ')'
				;
expression_leaf : TK_IDENTIFICADOR
				| TK_IDENTIFICADOR '[' expression ']'
				| literal 
				| func_call
				;

/** CONTROLE DE FLUXO **/

flow_control	: do_while | while | if_then | if_else;

do_while        : TK_PR_DO command ';' TK_PR_WHILE '(' expression ')'
				| TK_PR_DO command_block TK_PR_WHILE '(' expression ')' ;

while           : TK_PR_WHILE '(' expression ')' TK_PR_DO command ;

if_then			: TK_PR_IF '(' expression ')' TK_PR_THEN command ; 

if_else			: TK_PR_IF '(' expression ')' TK_PR_THEN command_no_then TK_PR_ELSE command ;
command_no_then	: do_while | while_no_then | if_else_no_then
				| simple_command
                ;
while_no_then	: TK_PR_WHILE '(' expression ')' TK_PR_DO command_no_then ;
if_else_no_then	: TK_PR_IF '(' expression ')' TK_PR_THEN command_no_then TK_PR_ELSE command_no_then ;

/** TIPOS AUXILIARES **/

type  : TK_PR_INT | TK_PR_FLOAT | TK_PR_BOOL | TK_PR_CHAR | TK_PR_STRING ;

literal			: TK_LIT_FALSE 
				| TK_LIT_TRUE
				| TK_LIT_CHAR
				| TK_LIT_STRING
				| TK_LIT_INT
				| TK_LIT_FLOAT
				;
unary_operator	: '-' | '!' ;


%%
