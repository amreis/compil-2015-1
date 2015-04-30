#ifndef __MISC_H
#define __MISC_H
#include <stdio.h>
#include "cc_tree.h"

int getLineNumber (void);
void yyerror (char const *mensagem);
void main_init (int argc, char **argv);
void main_finalize (void);
void coercion (comp_tree_t *arg1, comp_tree_t *arg2);

#endif
