#ifndef __MISC_H
#define __MISC_H
#include <stdio.h>
#include "cc_dict.h"

int getLineNumber (void);
void yyerror (char const *mensagem);
void main_init (int argc, char **argv);
void main_finalize (void);
void coercion (comp_dict_item_t* arg1, comp_dict_item_t* arg2);

#endif
