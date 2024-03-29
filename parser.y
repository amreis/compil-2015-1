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
#include "cc_dim_list.h"
#include "cc_semantic.h"
#include <stdlib.h>
#include <string.h>
comp_tree_t* final_ast;

extern comp_stack_t* sym_stack;

// Since we don't allow functions to be declared inside functions, a single
// pointer does the trick, so that we know which function we are in.
comp_dict_item_t* current_function = NULL;

int current_offset = 0;
%}

%union {
    struct _comp_dict_item_t* valor_simbolo_lexico;
    struct _comp_tree_t* ast;
    int type;
    struct _comp_dict_item_t* dict_entry;
    struct _comp_param_list_t* param_list;
    struct _comp_param_list_item_t* param_list_item;
    struct _dim_list_t* dim_list;
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
%left '<' '>' TK_OC_LE TK_OC_GE TK_OC_EQ TK_OC_NE
%left '+' '-' TK_OC_OR
%left '*' '/' TK_OC_AND
%left '!' INVERSION

%nonassoc TK_PR_THEN
%nonassoc TK_PR_ELSE

%type<ast> literal expression_leaf expression simple_expression flow_control 
%type<ast> do_while while if_then if_else command command_block command_list
%type<ast> return_statement assignment input_statement output_statement
%type<ast> func_call args_list nonempty_args_list output_list program full_program gen_func_decl static_func_decl simple_func_decl
%type<dim_list> dim_list
%type<type> type
%type<dict_entry> simple_var_decl vector_var_decl simple_local_var static_local_var gen_local_var init_literal
%type<dict_entry> vector_local_var
%type<param_list> params_list nonempty_params_list
%type<param_list_item> param

%error-verbose

%%
/* Regras (e ações) da gramática */


full_program: program
                {
                  $$ = new_tree_0(AST_PROGRAMA);
                  set_list_child_tree($$,0,$1);
                  gen_code($$->child[0]);
                  $$->code = $$->child[0]->code;
                  print_code($$->code);
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
                {
                    $1->addr.offset = current_offset;
                    $1->addr.scope = SCOPE_GLOBAL;
                    current_offset+=size_of($1->type.base);
                }
                | vector_var_decl
                ;
/* A static variable is declared with the keyword 'static' in front of it. */
static_var_decl : TK_PR_STATIC simple_var_decl
                | TK_PR_STATIC vector_var_decl
                ;
/* A vector declaration has its identifier followed by [N], where N is the size. */
vector_var_decl : simple_var_decl '[' dim_list ']'
                {
                    $1->type.is_vector = 1;
                    $1->type.n_dims = $3->length;
                    $1->type.dim_sizes = dim_list_to_ary($3);
                    $$ = $1;
                };

dim_list        : TK_LIT_INT
                {
                    $$ = new_dim_list();
                    dim_list_item_t* aux = new_dim_list_item();
                    aux->dim_size = $1->token_val.int_val;
                    append_dim($$, aux);
                }
                | dim_list ',' TK_LIT_INT
                {
                    dim_list_item_t* aux = new_dim_list_item();
                    aux->dim_size = $3->token_val.int_val;
                    append_dim($$, aux);
                }
                ;

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
              | simple_func_decl { $$ = $1; gen_code($$); }
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

command_block   : '{' { sym_stack = push_new_dict(sym_stack); }
                    command_list '}'
                    {
                      sym_stack = pop_stack(sym_stack);
                      
                      $$ = new_tree_0(AST_BLOCO);
                      set_list_child_tree($$,0,$3);
                    }
                ;

command_list    : command { $$ = $1; }
                | command_list ';' command
                    {
                      $$ = append_next_tree($1, NEXT_COMMAND, $3);
                      if($3 != NULL)
                          $$->code = concat_list($1->code, $3->code);
                    }
                ;

command         : flow_control      { $$ = $1; }
                | local_var_decl    { $$ = NULL; }
                | assignment        { $$ = $1; }
                | input_statement   { $$ = $1; }
                | output_statement  { $$ = $1; }
                | return_statement  { $$ = $1; }
                | command_block     { $$ = $1; }
                | /*empty*/         { $$ = NULL; }
                | func_call         { $$ = $1; }
                | invalid_stmt      { $$ = NULL; }
                ;

invalid_stmt    : gen_func_decl { yyerror("Illegal function declaration ending"); return SINTATICA_ERRO; }
                | TK_PR_RETURN  { yyerror("Return with no value"); return SINTATICA_ERRO; }
                | TK_PR_OUTPUT  { yyerror("Output without values"); return SINTATICA_ERRO; }
                ;
// DECLARAÇÃO DE VARIÁVEL LOCAL
local_var_decl : gen_local_var
               | gen_local_var TK_OC_LE TK_IDENTIFICADOR
                   {
                     $3 = query_stack_var(sym_stack, $3->lex);
                     if ($3 != NULL)
                         coerce_dict_entry($3, $1->type.base);
                   }
               | gen_local_var TK_OC_LE init_literal
                   {
                     coerce_dict_entry($3, $1->type.base);
                   }
               | vector_local_var ;

gen_local_var    : simple_local_var { $$ = $1; } | static_local_var { $$ = $1; } ;

simple_local_var : type TK_IDENTIFICADOR 
                     {
                       if ($2->type.sealed || $2->type.base != AMA_INVALID)
                           report_error(IKS_ERROR_DECLARED, $2->lex);
                       $2->type.base = $1;
                       $$ = $2;
                     }
                 | TK_PR_CONST type TK_IDENTIFICADOR
                     {
                       if ($3->type.sealed || $3->type.base != AMA_INVALID)
                           report_error(IKS_ERROR_DECLARED, $3->lex);
                       $3->type.base = $2;
                       $$ = $3;
                     }
                 ;
static_local_var : TK_PR_STATIC simple_local_var { $$ = $2; }
                 ;
vector_local_var : simple_local_var '[' dim_list ']'
                 {
                    $1->type.is_vector = 1;
                    $1->type.n_dims = $3->length;
                    $1->type.dim_sizes = dim_list_to_ary($3);
                    $$ = $1;
                 } ;
// ATRIBUIÇÃO
assignment : TK_IDENTIFICADOR '=' expression
               {
                 $1 = query_stack_var(sym_stack, $1->lex);
                 if ($1 != NULL)
                 {
                     $$ = new_tree_2(AST_ATRIBUICAO, new_tree_valued(AST_IDENTIFICADOR, $1), $3);
                     coerce($3, $1->type.base);
                     gen_code($$);
                 }
               }
           | TK_IDENTIFICADOR '[' nonempty_args_list ']' '=' expression
               {
                 comp_tree_t* aux = new_tree_1(AST_VETOR_INDEXADO, new_tree_valued(AST_IDENTIFICADOR, $1)); set_list_child_tree(aux, 1, $3);
                 $$ = new_tree_2(AST_ATRIBUICAO, aux, $6);
                 $1 = query_stack_vector(sym_stack, $1->lex);
                 if ($1 != NULL)
                 {
                     // Check type of the expression between brackets.
                     int n = 0;
                     comp_tree_t* args = aux->child[1];
                     while (args != NULL)
                     {
                         n++;
                         args = args->next;
                     }
                     if (n < $1->type.n_dims)
                         report_error(IKS_ERROR_MISSING_DIMS, $1->lex, $1->type.n_dims, n);
                     else if (n > $1->type.n_dims)
                         report_error(IKS_ERROR_EXCESS_DIMS, $1->lex, $1->type.n_dims, n);
                     else {
                         args = aux->child[1];
                         n = 0;
                         while (args != NULL)
                         {
                             //try_to_coerce(args, AMA_INT, IKS_ERROR_WRONG_TYPE_DIMS, $1->lex, n);
                             coerce(args, AMA_INT);
                             args = args->next;
                         }
                     }
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
                        list = list->next;
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
func_call       : TK_IDENTIFICADOR '(' args_list ')' 
                    {
                        $$ = new_tree_1(AST_CHAMADA_DE_FUNCAO, new_tree_valued(AST_IDENTIFICADOR, $1)); set_list_child_tree($$,1,$3);
                        $1 = query_stack_function(sym_stack, $1->lex);
                        if ($1 != NULL)
                        {
                            int n = 0;
                            comp_tree_t* args = $$->child[1];
                            while (args != NULL)
                            {
                                n++;
                                args = args->next;
                            }
                            if (n < $1->type.n_args)
                                report_error(IKS_ERROR_MISSING_ARGS, $1->lex, $1->type.n_args, n);
                            else if (n > $1->type.n_args)
                                report_error(IKS_ERROR_EXCESS_ARGS, $1->lex, $1->type.n_args, n);
                            else {
                                args = $$->child[1];
                                n = 0;
                                while (args != NULL)
                                {
                                    try_to_coerce(args, $1->type.arg_types[n], IKS_ERROR_WRONG_TYPE_ARGS, $1->lex, n);
                                    args = args->next;
                                }
                            }
                            $$->semantic_type = $1->type.base;
                        }
                    }
                ;
args_list       : nonempty_args_list { $$ = $1; }
                | { $$ = NULL; }
                ;
nonempty_args_list : expression { $$ = $1; }
                | nonempty_args_list ',' expression { $$ = append_next_tree($1, NEXT_ARGUMENT, $3); }
                ;


/** EXPRESSÕES LÓGICAS E ARITMÉTICAS **/
expression : simple_expression { $$ = $1;}
           | expression '+' expression
               {
                 $$ = new_tree_2(AST_ARIM_SOMA, $1, $3);
                 $$->semantic_type = infer_numeric_type($1->semantic_type, $3->semantic_type);
                 coerce($1, $$->semantic_type);
                 coerce($3, $$->semantic_type);
                 gen_code($$);
               }
           | expression '-' expression
               {
                 $$ = new_tree_2(AST_ARIM_SUBTRACAO, $1, $3);
                 $$->semantic_type = infer_numeric_type($1->semantic_type, $3->semantic_type);
                 coerce($1, $$->semantic_type);
                 coerce($3, $$->semantic_type);
                 gen_code($$);
               }
           | expression '*' expression
               {
                 $$ = new_tree_2(AST_ARIM_MULTIPLICACAO, $1, $3);
                 $$->semantic_type = infer_numeric_type($1->semantic_type, $3->semantic_type);
                 coerce($1, $$->semantic_type);
                 coerce($3, $$->semantic_type);
                 gen_code($$);
               }
           | expression '/' expression
               {
                 $$ = new_tree_2(AST_ARIM_DIVISAO, $1, $3);
                 $$->semantic_type = infer_numeric_type($1->semantic_type, $3->semantic_type);
                 coerce($1, $$->semantic_type);
                 coerce($3, $$->semantic_type);
                 gen_code($$);
               }
           | expression '<' expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_L, $1, $3);
                 $$->semantic_type = AMA_BOOL;
                 int coerced_type = infer_numeric_type($1->semantic_type, $3->semantic_type);
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
                 gen_code($$);
               }
           | expression '>' expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_G, $1, $3);
                 $$->semantic_type = AMA_BOOL;
                 int coerced_type = infer_numeric_type($1->semantic_type, $3->semantic_type);
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
                 gen_code($$);
               }
           | expression TK_OC_LE expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_LE, $1, $3);
                 $$->semantic_type = AMA_BOOL;
                 int coerced_type = infer_numeric_type($1->semantic_type, $3->semantic_type);
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
                 gen_code($$);
               }
           | expression TK_OC_GE expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_GE, $1, $3);
                 $$->semantic_type = AMA_BOOL;
                 int coerced_type = infer_numeric_type($1->semantic_type, $3->semantic_type);
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
                 gen_code($$);
               }
           | expression TK_OC_EQ expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_IGUAL, $1, $3);
                 $$->semantic_type = AMA_BOOL;
                 int coerced_type = infer_type($1->semantic_type, $3->semantic_type);
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
                 gen_code($$);
               }
           | expression TK_OC_NE expression
               {
                 $$ = new_tree_2(AST_LOGICO_COMP_DIF, $1, $3);
                 $$->semantic_type = AMA_BOOL;
                 int coerced_type = infer_type($1->semantic_type, $3->semantic_type);
                 coerce($1, coerced_type);
                 coerce($3, coerced_type);
                 gen_code($$);
               }
           | expression TK_OC_AND expression
               {
                 $$ = new_tree_2(AST_LOGICO_E, $1, $3);
                 $$->semantic_type = AMA_BOOL;
                 coerce($1, AMA_BOOL);
                 coerce($3, AMA_BOOL);
                 gen_code($$);
               }
           | expression TK_OC_OR expression
               {
                 $$ = new_tree_2(AST_LOGICO_OU, $1, $3);
                 $$->semantic_type = AMA_BOOL;
                 coerce($1, AMA_BOOL);
                 coerce($3, AMA_BOOL);
                 gen_code($$);
               }
           | '-' simple_expression %prec INVERSION
               {
                 $$ = new_tree_1(AST_ARIM_INVERSAO, $2);
                 if ($2->semantic_type != AMA_INT && $2->semantic_type != AMA_FLOAT)
                     coerce($2, AMA_INT);
                 $$->semantic_type = $2->semantic_type;
               }
           | '!' simple_expression
               {
                 $$ = new_tree_1(AST_LOGICO_COMP_NEGACAO, $2);
                 $$->semantic_type = AMA_BOOL;
                 coerce($2, AMA_BOOL);
               }
           ;
simple_expression : expression_leaf { $$ = $1;}
                  | '(' expression ')' { $$ = $2;} 
                  ;
expression_leaf   : TK_IDENTIFICADOR
                      {
                        comp_dict_item_t* old_s1 = $1;
                        $1 = query_stack_var(sym_stack, $1->lex);
                        if ($1 != NULL)
                        {
                            $$ = new_tree_valued(AST_IDENTIFICADOR, $1);
                            $$->semantic_type = $1->type.base;
                            gen_code($$);
                        } else $$ = new_tree_valued(AST_IDENTIFICADOR, old_s1);
                      }
                  | TK_IDENTIFICADOR '[' nonempty_args_list ']'
                      {
                        $$ = new_tree_1(AST_VETOR_INDEXADO, new_tree_valued(AST_IDENTIFICADOR, $1));
                        set_list_child_tree($$, 1, $3);
                        $1 = query_stack_vector(sym_stack, $1->lex);
                        if ($1 != NULL)
                        {
                            $$->semantic_type = $1->type.base;
                            // Check type of the expression between brackets.
                            int n = 0;
                            comp_tree_t* args = $$->child[1];
                            while (args != NULL)
                            {
                                n++;
                                args = args->next;
                            }
                            if (n < $1->type.n_dims)
                                report_error(IKS_ERROR_MISSING_DIMS, $1->lex, $1->type.n_dims, n);
                            else if (n > $1->type.n_dims)
                                report_error(IKS_ERROR_EXCESS_DIMS, $1->lex, $1->type.n_dims, n);
                            else {
                                args = $$->child[1];
                                n = 0;
                                while (args != NULL)
                                {
                                    //try_to_coerce(args, AMA_INT, IKS_ERROR_WRONG_TYPE_DIMS, $1->lex, n);
                                    coerce(args, AMA_INT);
                                    args = args->next;
                                }
                            }
                        }
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
do_while        : TK_PR_DO command ';'   TK_PR_WHILE '(' expression ')'
                    {
                      $$ = new_tree_2(AST_DO_WHILE, $2, $6);
                      coerce($6, AMA_BOOL);
                    }
                | TK_PR_DO command_block TK_PR_WHILE '(' expression ')'
                    {
                      $$ = new_tree_2(AST_DO_WHILE, $2, $5);
                      coerce($5, AMA_BOOL);
                    }
                ;
while           : TK_PR_WHILE '(' expression ')' TK_PR_DO command
                    {
                      $$ = new_tree_2(AST_WHILE_DO, $3, $6);
                      coerce($3, AMA_BOOL);
                    }
                ; 
if_then         : TK_PR_IF '(' expression ')' TK_PR_THEN command
                    {
                      $$ = new_tree_2(AST_IF_ELSE, $3, $6);
                      coerce($3, AMA_BOOL);
                    }
                ;
if_else         : TK_PR_IF '(' expression ')' TK_PR_THEN command TK_PR_ELSE command
                    {
                      $$ = new_tree_3(AST_IF_ELSE, $3, $6, $8);
                      coerce($3, AMA_BOOL);
                    }
                ;

/** TIPOS AUXILIARES **/

type  : TK_PR_INT    { $$ = AMA_INT; }
      | TK_PR_FLOAT  { $$ = AMA_FLOAT; }
      | TK_PR_BOOL   { $$ = AMA_BOOL; }
      | TK_PR_CHAR   { $$ = AMA_CHAR; }
      | TK_PR_STRING { $$ = AMA_STRING; };

literal         : TK_LIT_FALSE  { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_BOOL; gen_code($$); }
                | TK_LIT_TRUE   { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_BOOL; gen_code($$); }
                | TK_LIT_CHAR   { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_CHAR; }
                | TK_LIT_STRING { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_STRING; }
                | TK_LIT_INT    { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_INT; gen_code($$); }
                | TK_LIT_FLOAT  { $$ = new_tree_valued(AST_LITERAL, $1); $$->semantic_type = AMA_FLOAT; gen_code($$); }
                ;
init_literal    : TK_LIT_FALSE  { $$ = $1; }
                | TK_LIT_TRUE   { $$ = $1; }
                | TK_LIT_CHAR   { $$ = $1; }
                | TK_LIT_STRING { $$ = $1; }
                | TK_LIT_INT    { $$ = $1; }
                | TK_LIT_FLOAT  { $$ = $1; }
                ;

%%
