#ifndef STACK_H
#define STACK_H

#include "cc_dict.h"

typedef struct _stack {
    comp_dict_t* item;
    struct _stack *next;
} comp_stack_t;

comp_stack_t* new_stack();

comp_stack_t* push_stack(comp_stack_t* stack, comp_dict_t* item);
comp_stack_t* push_new_dict(comp_stack_t* stack);
comp_stack_t* pop_stack(comp_stack_t* stack);
comp_dict_item_t* query_stack(comp_stack_t* stack, const char* key, int sym_type);
comp_dict_item_t* query_stack_id(comp_stack_t* stack, const char* key);
void free_stack_item(comp_stack_t* stack);
void free_stack(comp_stack_t* stack);

#endif
