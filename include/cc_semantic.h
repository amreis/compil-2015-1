#ifndef __SEMANTIC_H
#define __SEMANTIC_H

#include "cc_tree.h"
#include "cc_stack.h"
#include <stdarg.h>


#define IKS_SUCCESS            0 //caso não houver nenhum tipo de erro

/* Verificação de declarações */
#define IKS_ERROR_UNDECLARED  1 //identificador não declarado
#define IKS_ERROR_DECLARED    2 //identificador já declarado

/* Uso correto de identificadores */
#define IKS_ERROR_VARIABLE    3 //identificador deve ser utilizado como variável
#define IKS_ERROR_VECTOR      4 //identificador deve ser utilizado como vetor
#define IKS_ERROR_FUNCTION    5 //identificador deve ser utilizado como função

/* Tipos e tamanho de dados */
#define IKS_ERROR_WRONG_TYPE  6 //tipos incompatíveis
#define IKS_ERROR_STRING_TO_X 7 //coerção impossível do tipo string
#define IKS_ERROR_CHAR_TO_X   8 //coerção impossível do tipo char

/* Argumentos e parâmetros */
#define IKS_ERROR_MISSING_ARGS    9  //faltam argumentos 
#define IKS_ERROR_EXCESS_ARGS     10 //sobram argumentos 
#define IKS_ERROR_WRONG_TYPE_ARGS 11 //argumentos incompatíveis

/* Verificação de tipos em comandos */
#define IKS_ERROR_WRONG_PAR_INPUT  12 //parâmetro não é identificador
#define IKS_ERROR_WRONG_PAR_OUTPUT 13 //parâmetro não é literal string ou expressão
#define IKS_ERROR_WRONG_PAR_RETURN 14 //parâmetro não é expressão compatível com tipo do retorno

#define IKS_ERROR_MISSING_DIMS 15
#define IKS_ERROR_EXCESS_DIMS 16
#define IKS_ERROR_WRONG_TYPE_DIMS 17

int first_error;

int getLineNumber (void);
void yyerror (char const *mensagem);
void report_error(int errcode, ...);

int infer_type(int type1, int type2);
int infer_numeric_type(int type1, int type2);
void coerce(comp_tree_t *arg, int to_type);
void try_to_coerce(comp_tree_t *arg, int to_type, int wrong_type_error, ...);
void coerce_dict_entry(comp_dict_item_t *arg, int to_type);

comp_dict_item_t* query_stack_var(comp_stack_t* stack, const char* key);
comp_dict_item_t* query_stack_vector(comp_stack_t* stack, const char* key);
comp_dict_item_t* query_stack_function(comp_stack_t* stack, const char* key);

int size_of(int type);

#endif
