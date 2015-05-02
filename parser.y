    /*
  Galatasaralister

  Alister Machado dos Reis
  Daniel dos Santos Bossle
  Eduardo Faccin Vernier
*/
%{
#include <stdio.h>
#include "main.h"
#include "cc_ast.h"
#include "cc_dict.h"
#include "cc_stack.h"
#include "cc_param_list.h"
#include "cc_semantic.h"
#include <stdlib.h>
#include <string.h>
comp_tree_t* final_ast;

extern comp_stack_t* sym_stack;

// Since we don't allow functions to be declared inside functions, a single
// pointer does the trick, so that we know which function we are in.
comp_dict_item_t* current_function = NULL;
%}

%union {
    struct _comp_dict_item_t* valor_simbolo_lexico;
    struct _comp_tree_t* ast;
    int type;
    struct _comp_dict_item_t* dict_entry;
    struct _comp_param_list_t* param_list;
    struct _comp_param_list_item_t* param_list_item;
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
%left '<' '>' TK_OC_LE TK_OC_GE TK_OC_EQ TK_OC_NE TK_OC_OR
%left '+' '-' TK_OC_AND
%left '*' '/'
%left '!' INVERSION

%type<ast> literal expression_leaf expression simple_expression flow_control 
%type<ast> do_while while if_then if_else command_no_then  while_no_then if_else_no_then command simple_command command_block command_list
%type<ast> return_statement assignment input_statement output_statement
%type<ast> func_call args_list output_list program full_program gen_func_decl static_func_decl simple_func_decl

%type<type> type
%type<dict_entry> simple_var_decl vector_var_decl simple_local_var static_local_var gen_local_var init_literal
%type<param_list> params_list nonempty_params_list
%type<param_list_item> param
%error-verbose

%%
/* Regras (e ações) da gramática */


full_program: program
                {
                  $$ = new_tree_0(AST_PROGRAMA);
                  set_list_child_tree($$,0,$1);
                  final_ast = $$;
                  return first_error;
                } ;

/* A program is a sequence of global variable declarations and function
   declarations. It may also be empty. */
program : program global_var_decl ';' { $$ = $1; }
        | program gen_func_decl { $$ = append_next_tree($1, NEXT_FUNCTION, $2); }
        | { $$ = NULL; }
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
vector_var_decl : simple_var_decl '[' TK_LIT_INT ']' { $1->type.is_vector = 1; $$ = $1; } ;

/* A simple declaration needs only the type and the identifier. */
simple_var_decl : type TK_IDENTIFICADOR
                    {
                      if ($2->type.base != AMA_INVALID)
                          report_error(IKS_ERROR_DECLARED, $2->lex);
                      $2->type.base = $1;
                      $$ = $2;
                    };

/** FUNCTIONS */
/* A function can be static or not. */
gen_func_decl : static_func_decl { $$ = $1; }
              | simple_func_decl { $$ = $1; }
              ;

/* If it's static, its declaration is preceded by the keyword 'static' */
static_func_decl: TK_PR_STATIC simple_func_decl { $$ = $2; } ;

/* A function declaration needs a return type, an identifier and an (possibly
   empty) parameter list, followed by the function body surrounded by braces */
simple_func_decl: type TK_IDENTIFICADOR '(' params_list ')' 
                    {
                      if ($2->type.base != AMA_INVALID)
                          report_error(IKS_ERROR_DECLARED, $2->lex);
                      
                      $2->type.base = $1;
                      $2->type.is_function = 1;
                      $2->type.n_args = ($4 == NULL) ? 0 : $4->length;

                      $2->type.arg_types = param_list_to_ary($4);
                      current_function = $2;
                      sym_stack = push_new_dict(sym_stack);
                    }
                    '{' command_list '}'
                    {
                      sym_stack = pop_stack(sym_stack);
                      current_function = NULL;
                      
                      $$ = new_tree_valued(AST_FUNCAO, $2);
                      set_list_child_tree($$,0,$8);
                    } ;

/* The argument list may be empty or not */
params_list          : nonempty_params_list { $$ = $1; }
                     | { $$ = NULL; };

/* A list of parameters that is not empty is either a single parameter or a parameter 
   preceded by another non-empty list of arguments and a comma */
nonempty_params_list : param { $$ = new_param_list(); append_param_list_item($$, $1); } 
                     | nonempty_params_list ',' param { append_param_list_item($1, $3); $$ = $1; };

/* A parameter is like a variable declaration, but it might be const */
param                : TK_PR_CONST simple_var_decl { $$ = new_param_list_item(); $$->param_type = $2->type.base; }
                     | simple_var_decl { $$ = new_param_list_item(); $$->param_type = $1->type.base; } ;

command_block   : '{' { sym_stack = push_new_dict(sym_stack); } command_list '}' { sym_stack = pop_stack(sym_stack); } { $$ = new_tree_0(AST_BLOCO); set_list_child_tree($$,0,$3); } //TODO: format this better
                ;

command_list    : command { $$ = $1; }
                | command_list ';' command { $$ = append_next_tree($1, NEXT_COMMAND, $3); }
                ;

command         : flow_control      { $$ = $1; }
                | simple_command    { $$ = $1; }
                | invalid_stmt      { $$ = NULL; }
                ;

simple_command  : local_var_decl    { $$ = NULL; }
                | assignment        { $$ = $1; }
                | input_statement   { $$ = $1; }
                | output_statement  { $$ = $1; }
                | return_statement  { $$ = $1; }
                | command_block     { $$ = $1; }
                | /*empty*/         { $$ = NULL; }
                | func_call         { $$ = $1; }
                ;

invalid_stmt    : gen_func_decl { yyerror("Illegal function declaration ending"); return SINTATICA_ERRO; }
                | TK_PR_RETURN  { yyerror("Return with no value"); return SINTATICA_ERRO; }
                | TK_PR_OUTPUT  { yyerror("Output without values"); return SINTATICA_ERRO; }
                ;
// DECLARAÇÃO DE VARIÁVEL LOCAL
local_var_decl : gen_local_var
               | gen_local_var TK_OC_LE TK_IDENTIFICADOR
                   {
                     char lex[256];
                     strcpy(lex, $3->lex);
                     if ($3->type.base == AMA_INVALID)
                         $3 = query_stack_id(sym_stack->next, $3->lex);
                     if ($3 == NULL || $3->type.base == AMA_INVALID)
                         report_error(IKS_ERROR_UNDECLARED, lex);
                     else if ($3->type.is_vector)
                         report_error(IKS_ERROR_VECTOR, lex);
                     else if ($3->type.is_function)
                         report_error(IKS_ERROR_FUNCTION, lex);
                     coerce_dict_entry($3, $1->type.base);
                   }
               | gen_local_var TK_OC_LE init_literal
                   {
                     coerce_dict_entry($3, $1->type.base);
                   }
               ;

gen_local_var    : simple_local_var { $$ = $1; } | static_local_var { $$ = $1; } ;

simple_local_var : type TK_IDENTIFICADOR 
                     {
                       if ($2->type.base != AMA_INVALID)
                           report_error(IKS_ERROR_DECLARED, $2->lex);
                       $2->type.base = $1;
                       $$ = $2;
                     }
                 | TK_PR_CONST type TK_IDENTIFICADOR
                     {
                       if ($3->type.base != AMA_INVALID)
                           report_error(IKS_ERROR_DECLARED, $3->lex);
                       $3->type.base = $2;
                       $$ = $3;
                     }
                 ;
static_local_var : TK_PR_STATIC simple_local_var { $$ = $2; }
                 ;
// ATRIBUIÇÃO
assignment : TK_IDENTIFICADOR '=' expression
               {
                 $$ = new_tree_2(AST_ATRIBUICAO, new_tree_valued(AST_IDENTIFICADOR, $1), $3);
                 char lex[256];
                 strcpy(lex, $1->lex);
                 if ($1->type.base == AMA_INVALID)
                 {
                     $1 = query_stack_id(sym_stack->next, $1->lex);
                 }
                 if ($1 == NULL || $1->type.base == AMA_INVALID)
                     report_error(IKS_ERROR_UNDECLARED, lex);
                 else if ($1->type.is_vector)
                     report_error(IKS_ERROR_VECTOR, lex);
                 else if ($1->type.is_function)
                     report_error(IKS_ERROR_FUNCTION, lex);
                 else coerce($3, $1->type.base);
               }
           | TK_IDENTIFICADOR '[' expression ']' '=' expression
               {
                 $$ = new_tree_2(AST_ATRIBUICAO,new_tree_2(AST_VETOR_INDEXADO, new_tree_valued(AST_IDENTIFICADOR, $1), $3), $6);
                 char lex[256];
                 strcpy(lex, $1->lex);
                 if ($1->type.base == AMA_INVALID)
                     $1 = query_stack_id(sym_stack->next, $1->lex);
                 if ($1 == NULL || $1->type.base == AMA_INVALID)
                     report_error(IKS_ERROR_UNDECLARED, lex);
                 else if ($1->type.is_function)
                     report_error(IKS_ERROR_FUNCTION, lex);
                 else if (!$1->type.is_vector)
                     report_error(IKS_ERROR_VARIABLE, lex);
                 else {
                     // Check type of the expression between brackets.
                     coerce($3, AMA_INT);
                     // Check type of the assignment expression
                     coerce($6, $1->type.base);
                 }
               }
               ;
// ENTRADA
input_statement : TK_PR_INPUT expression '=' '>' expression
                    {
                       $$ = new_tree_2(AST_INPUT, $2, $5);
                       if ($5->value == NULL || $5->value->token_type != SIMBOLO_IDENTIFICADOR)
                           report_error(IKS_ERROR_WRONG_PAR_INPUT);
                    }
                ; /* bug: you can have whitespace between '=' and '>' */
// SAÍDA
output_statement: TK_PR_OUTPUT output_list
                  {
                    $$ = new_tree_0(AST_OUTPUT); set_list_child_tree($$,0,$2);
                    comp_tree_t* list = $2->first;
                    int count = 0;
                    while (list != NULL)
                    {
                        if (list->value == NULL || list->value->token_type != SIMBOLO_LITERAL_STRING)
                            try_to_coerce(list, AMA_INT, IKS_ERROR_WRONG_PAR_OUTPUT, count);
                        if (list->next_type == NEXT_OUTPUT)
                            count++, list = list->next;
                        else break;
                    }
                  }
                ;
output_list     : expression { $$ = $1; }
                | output_list ',' expression { $$ = append_next_tree($1, NEXT_OUTPUT, $3); }
                ;

// RETORNO
return_statement: TK_PR_RETURN expression
                    {
                      $$ = new_tree_1(AST_RETURN, $2);
                      try_to_coerce($2, current_function->type.base, IKS_ERROR_WRONG_PAR_RETURN, current_function->lex);
                    }
                ;

// CHAMADA DE FUNÇÃO
func_call        : TK_IDENTIFICADOR '(' ')'
                    {
                        $$ = new_tree_1(AST_CHAMADA_DE_FUNCAO, new_tree_valued(AST_IDENTIFICADOR, $1));
                        char lex[256];
                        strcpy(lex, $1->lex);
                        if ($1->type.base == AMA_INVALID)
                            $1 = query_stack_id(sym_stack->next, $1->lex);
                        if ($1 == NULL || $1->type.base == AMA_INVALID)
                            report_error(IKS_ERROR_UNDECLARED, lex);
                        else if ($1->type.is_vector)
                            report_error(IKS_ERROR_VECTOR, lex);
                        else if (!$1->type.is_function)
                            report_error(IKS_ERROR_VARIABLE, lex);
                        else if ($1->type.n_args != 0)
                            report_error(IKS_ERROR_MISSING_ARGS, lex, $1->type.n_args, 0);
                        else
                        {
                            $$->semantic_type = $1->type.base;
                        }
                    }
                | TK_IDENTIFICADOR '(' args_list ')' 
                    {
                        $$ = new_tree_1(AST_CHAMADA_DE_FUNCAO, new_tree_valued(AST_IDENTIFICADOR, $1)); set_list_child_tree($$,1,$3);
                        char lex[strlen($1->lex)+1];
                        strcpy(lex, $1->lex);
                        if ($1->type.base == AMA_INVALID)
                            $1 = query_stack_id(sym_stack->next, $1->lex);
                        if ($1 == NULL || $1->type.base == AMA_INVALID)
                            report_error(IKS_ERROR_UNDECLARED, lex);
                        else if ($1->type.is_vector)
                            report_error(IKS_ERROR_VECTOR, lex);
                        else if (!$1->type.is_function)
                            report_error(IKS_ERROR_VECTOR, lex);
                        else
                        {
                            int n = 0;
                            comp_tree_t* args = $3->first;
                            while (args != NULL)
                            {
                                n++;
                                if (args->next_type == NEXT_ARGUMENT)
                                    args = args->next;
                                else break;
                            }
                            if (n < $1->type.n_args)
                                report_error(IKS_ERROR_MISSING_ARGS, $1->lex, $1->type.n_args, n);
                            else if (n > $1->type.n_args)
                                report_error(IKS_ERROR_EXCESS_ARGS, lex, $1->type.n_args, n);
                            else {
                                args = $3->first;
                                n = 0;
                                while (args != NULL)
                                {
                                    try_to_coerce(args, $1->type.arg_types[n], IKS_ERROR_WRONG_TYPE_ARGS, $1->lex, n);

                                    if (args->next_type != NEXT_ARGUMENT)
                                        break;
                                    n++; args = args->next;
                                }
                            }
                        }
                        $$->semantic_type = $1->type.base;
                    }
                ;
args_list       : expression { $$ = $1; }
                | args_list ',' expression { $$ = append_next_tree($1, NEXT_ARGUMENT, $3); }
                ;


/** EXPRESSÕES LÓGICAS E ARITMÉTICAS **/
expression : simple_expression { $$ = $1;}
           | expression '+' expression
               {
                 $$ = new_tree_2(AST_ARIM_SOMA, $1, $3);
                 if ($1->semantic_type == AMA_FLOAT || $3->semantic_type == AMA_FLOAT)
                     $$->semantic_type = AMA_FLOAT;
                 else
                     $$->semantic_type = AMA_INT;
                 coerce($1, $$->semantic_type);
                 coerce($3, $$->semantic_type);
               }
           | expression '-' expression
               {
                 $$ = new_tree_2(AST_ARIM_SUBTRACAO, $1, $3);
                 if ($1->semantic_type == AMA_FLOAT || $3->semantic_type == AMA_FLOAT)
                     $$->semantic_type = AMA_FLOAT;
                 else
                     $$->semantic_type = AMA_INT;
                 coerce($1, $$->semantic_type);
                 coerce($3, $$->semantic_type);
               }
           | expression '*' expression
               {
                 $$ = new_tree_2(AST_ARIM_MULTIPLICACAO, $1, $3);
                 if ($1->semantic_type == AMA_FLOAT || $3->semantic_type == AMA_FLOAT)
                     $$->semantic_type = AMA_FLOAT;
                 else
                     $$->semantic_type = AMA_INT;
                 coerce($1, $$->semantic_type);
                 coerce($3, $$->semantic_type);
               }
           | expression '/' expression
               {
                  $$ = new_tree_2(AST_ARIM_DIVISAO, $1, $3);
                  if ($1->semantic_type == AMA_FLOAT || $3->semantic_type == AMA_FLOAT)
                     $$->semantic_type = AMA_FLOAT;
                 else
                     $$->semantic_type = AMA_INT;
                 coerce($1, $$->semantic_type);
                 coerce($3, $$->semantic_type);
               }
           | expression '<' expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_L, $1, $3);
                 int coerced_type;
                 if ($1->semantic_type == AMA_FLOAT || $3->semantic_type == AMA_FLOAT)
                     coerced_type = AMA_FLOAT;
                 else
                     coerced_type = AMA_INT;
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
               }
           | expression '>' expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_G, $1, $3);
                 int coerced_type;
                 if ($1->semantic_type == AMA_FLOAT || $3->semantic_type == AMA_FLOAT)
                     coerced_type = AMA_FLOAT;
                 else
                     coerced_type = AMA_INT;
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
               }
           | expression TK_OC_LE expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_LE, $1, $3);
                 int coerced_type;
                 if ($1->semantic_type == AMA_FLOAT || $3->semantic_type == AMA_FLOAT)
                     coerced_type = AMA_FLOAT;
                 else
                     coerced_type = AMA_INT;
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
               }
           | expression TK_OC_GE expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_GE, $1, $3);
                        int coerced_type;
                 if ($1->semantic_type == AMA_FLOAT || $3->semantic_type == AMA_FLOAT)
                     coerced_type = AMA_FLOAT;
                 else
                     coerced_type = AMA_INT;
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
               }
           | expression TK_OC_EQ expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_IGUAL, $1, $3);
                 int coerced_type;
                 if ($1->semantic_type == AMA_FLOAT || $3->semantic_type == AMA_FLOAT)
                     coerced_type = AMA_FLOAT;
                 else
                     coerced_type = AMA_INT;
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
               }
           | expression TK_OC_NE expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_DIF, $1, $3);
                 int coerced_type;
                 if ($1->semantic_type == AMA_FLOAT || $3->semantic_type == AMA_FLOAT)
                     coerced_type = AMA_FLOAT;
                 else
                     coerced_type = AMA_INT;
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
               }
           | expression TK_OC_AND expression
               {
                 $$ = new_tree_2(AST_LOGICO_E, $1, $3);
                 $$->semantic_type = AMA_BOOL;
                 coerce($1, AMA_BOOL);
                 coerce($3, AMA_BOOL);
               }
           | expression TK_OC_OR expression
               {
                 $$ = new_tree_2(AST_LOGICO_OU, $1, $3);
                 $$->semantic_type = AMA_BOOL;
                 coerce($1, AMA_BOOL);
                 coerce($3, AMA_BOOL);
               }
           | '-' simple_expression %prec INVERSION
               {
                 $$ = new_tree_1(AST_ARIM_INVERSAO, $2);
                 if ($2->semantic_type != AMA_INT && $2->semantic_type != AMA_FLOAT)
                     report_error(IKS_ERROR_WRONG_TYPE);
                 $$->semantic_type = $2->semantic_type;
               }
           | '!' simple_expression
               {
                 $$ = new_tree_1(AST_LOGICO_COMP_NEGACAO, $2);
                 if ($2->semantic_type != AMA_BOOL)
                     report_error(IKS_ERROR_WRONG_TYPE);
                 $$->semantic_type = AMA_BOOL;
               }
           ;
simple_expression : expression_leaf { $$ = $1;}
                  | '(' expression ')' { $$ = $2;} 
                  ;
expression_leaf   : TK_IDENTIFICADOR
                      {
                        $$ = new_tree_valued(AST_IDENTIFICADOR, $1);
                        char lex[256];
                        strcpy(lex, $1->lex);
                        if ($1->type.base == AMA_INVALID)
                            $1 = query_stack_id(sym_stack->next, $1->lex);
                        if ($1 == NULL || $1->type.base == AMA_INVALID)
                            report_error(IKS_ERROR_UNDECLARED, lex);
                        if($1 == NULL)
                            $$->semantic_type = AMA_INVALID;
                        else
                            $$->semantic_type = $1->type.base;
                      }
                  | TK_IDENTIFICADOR '[' expression ']'
                      {
                        char lex[256];
                        strcpy(lex, $1->lex);
                        if ($1->type.base == AMA_INVALID)
                            $1 = query_stack_id(sym_stack->next, $1->lex);
                        if ($1 == NULL || $1->type.base == AMA_INVALID)
                            report_error(IKS_ERROR_UNDECLARED, lex);
                        else
                            coerce($3, AMA_INT);
                        $$ = new_tree_2(AST_VETOR_INDEXADO, new_tree_valued(AST_IDENTIFICADOR, $1), $3);
                        if($1 == NULL)
                            $$->semantic_type = AMA_INVALID;
                        else
                            $$->semantic_type = $1->type.base;
                      }
                  | literal { $$ = $1; }
                  | func_call { $$ = $1; }
                  ;

/** CONTROLE DE FLUXO **/

flow_control    : do_while    { $$ = $1;}
                | while       { $$ = $1;}
                | if_then     { $$ = $1;}
                | if_else     { $$ = $1;}
                ;
do_while        : TK_PR_DO command ';'   TK_PR_WHILE '(' expression ')' { $$ = new_tree_2(AST_DO_WHILE, $2, $6);}
                | TK_PR_DO command_block TK_PR_WHILE '(' expression ')' { $$ = new_tree_2(AST_DO_WHILE, $2, $5);}
                ;
while           : TK_PR_WHILE '(' expression ')' TK_PR_DO command { $$ = new_tree_2(AST_WHILE_DO, $3, $6);}
                ; 
if_then         : TK_PR_IF '(' expression ')' TK_PR_THEN command { $$ = new_tree_2(AST_IF_ELSE, $3, $6);}
                ;
if_else         : TK_PR_IF '(' expression ')' TK_PR_THEN command_no_then TK_PR_ELSE command { $$ = new_tree_3(AST_IF_ELSE, $3, $6, $8);}
                ;
command_no_then : do_while          { $$ = $1;}
                | while_no_then     { $$ = $1;}
                | if_else_no_then   { $$ = $1;}
                | simple_command    { $$ = $1;}
                ;
while_no_then   : TK_PR_WHILE '(' expression ')' TK_PR_DO command_no_then { $$ = new_tree_2(AST_WHILE_DO, $3, $6);}
                ;
if_else_no_then : TK_PR_IF '(' expression ')' TK_PR_THEN command_no_then TK_PR_ELSE command_no_then { $$ = new_tree_3(AST_IF_ELSE, $3, $6, $8);}
                ;

/** TIPOS AUXILIARES **/

type  : TK_PR_INT { $$ = AMA_INT; }
      | TK_PR_FLOAT { $$ = AMA_FLOAT; }
      | TK_PR_BOOL { $$ = AMA_BOOL; }
      | TK_PR_CHAR { $$ = AMA_CHAR; }
      | TK_PR_STRING { $$ = AMA_STRING; };

literal         : TK_LIT_FALSE  { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_BOOL; }
                | TK_LIT_TRUE   { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_BOOL; }
                | TK_LIT_CHAR   { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_CHAR; }
                | TK_LIT_STRING { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_STRING; }
                | TK_LIT_INT    { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_INT; }
                | TK_LIT_FLOAT  { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_FLOAT; }
                ;
init_literal    : TK_LIT_FALSE  { $$ = $1; }
                | TK_LIT_TRUE   { $$ = $1; }
                | TK_LIT_CHAR   { $$ = $1; }
                | TK_LIT_STRING { $$ = $1; }
                | TK_LIT_INT    { $$ = $1; }
                | TK_LIT_FLOAT  { $$ = $1; }
                ;

%%
