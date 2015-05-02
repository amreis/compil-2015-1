#ifndef __MISC_H
#define __MISC_H
#include "cc_tree.h"
#include "cc_stack.h"
#include "errors.h"
#include <stdarg.h>
#include <stdio.h>

extern unsigned long int line_num;
extern comp_stack_t* sym_stack;
extern comp_tree_t* final_ast;
extern int first_error;

int getLineNumber (void);
void yyerror (char const *mensagem);
void report_error(int errcode, ...);
void main_init (int argc, char **argv);
void main_finalize (void);
int coercion (comp_tree_t *arg1, comp_tree_t *arg2);
int is_compatible(int expr_type, int required_type);

#endif
