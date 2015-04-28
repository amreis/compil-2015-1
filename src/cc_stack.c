#include "cc_stack.h"
#include <stdlib.h>

comp_stack_t* new_stack()
{
    comp_stack_t* stack = (comp_stack_t*) malloc(sizeof(comp_stack_t));
    stack->item = new_full_dict();
    stack->next = NULL;
    return stack;
}

comp_stack_t* push_stack(comp_stack_t* stack, struct comp_dict_t* item)
{
    comp_stack_t* top = (comp_stack_t*) malloc(sizeof(comp_stack_t));
    top->item = item;
    top->next = stack;
    return top;
}

struct comp_dict_item_t* query_stack(comp_stack_t* stack, const char* s)
{
    while (stack != NULL)
    {
        struct comp_dict_item_t* item = query_dict_noncreate(stack->item, s);
        if (item != NULL)
            return item;
        else stack = stack->next;
    }
    return NULL;
}
