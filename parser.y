/*
  Galatasaralister

  Alister Machado dos Reis
  Daniel dos Santos Bossle
  Eduardo Faccin Vernier
*/
%{
#include <stdio.h>
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
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_IDENTIFICADOR
%token TOKEN_ERRO

%%
/* Regras (e ações) da gramática */

program  		: program global_var_decl ';'
		      	|
		      	;
global_var_decl : static_var_decl
                | normal_var_decl
                | vector_var_decl
                ;
static_var_decl : TK_PR_STATIC normal_var_decl
                | TK_PR_STATIC vector_var_decl
                ;
vector_var_decl : normal_var_decl '[' TK_LIT_INT ']' ;
normal_var_decl : type TK_IDENTIFICADOR ;
type  : TK_PR_INT | TK_PR_FLOAT | TK_PR_BOOL | TK_PR_CHAR | TK_PR_STRING ;
literal			: TK_LIT_FALSE 
				| TK_LIT_TRUE
				| TK_LIT_CHAR
				| TK_LIT_STRING
				| TK_LIT_INT
				| TK_LIT_FLOAT
				;
local_var_decl	: gen_local_var ';'
				| gen_local_var '<''=' TK_IDENTIFICADOR ';'
				| gen_local_var '<''=' literal ';'
				;
gen_local_var	: simple_local_var | static_local_var ;
simple_local_var: type TK_IDENTIFICADOR 
				| TK_PR_CONST type TK_IDENTIFICADOR 				
				;
static_local_var: TK_PR_STATIC simple_local_var 
				;
assignment		: TK_IDENTIFICADOR '=' expression 
				| TK_IDENTIFICADOR'[' expression ']' '=' expression 
				;
expression	: ; 




%%
