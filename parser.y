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

/* A program is a sequence of global variable declarations and function
   declarations. It may also be empty. */
programa  : programa global_var_decl ';'
          | programa gen_func_decl
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
static_func_decl: TK_PR_STATIC normal_func_decl ;

/* A function declaration needs a return type, an identifier and an (possibly
   empty) argument list, followed by the function body surrounded by braces */
simple_func_decl: type TK_IDENTIFICADOR '(' args_list ')' '{' command_block '}' ;

/* The argument list may be empty or not */
args_list       : nonempty_args_list
                | ;

/* A list of arguments that is not empty is either a single parameter or a parameter 
   preceded by another non-empty list of arguments and a comma */
nonempty_args_list: param | nonempty_args_list ',' param ;

/* A parameter is like a variable declaration, but it might be const */
param           : TK_PR_CONST normal_var_decl | normal_var_decl ;

command_block: ;

/** CONTROLE DE FLUXO **/

/** LOOPS */

do_while        : TOKEN_PR_DO command TOKEN_PR_WHILE '(' expression ')' ;
while           : TOKEN_PR_WHILE '(' expression ')' TOKEN_PR_DO command ;
type  : TK_PR_INT | TK_PR_FLOAT | TK_PR_BOOL | TK_PR_CHAR | TK_PR_STRING ;
%%
