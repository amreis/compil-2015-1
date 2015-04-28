#ifndef STACK_H
#define STACK_H

#include "cc_dict.h"

typedef struct _stack {
    comp_dict_t* item;
    struct _stack *next;
} comp_stack_t;

comp_stack_t* new_stack();
comp_stack_t* push_stack(comp_stack_t* stack, comp_dict_t* item);
comp_dict_item_t* query_stack(comp_stack_t* stack, const char* key);

#endif
