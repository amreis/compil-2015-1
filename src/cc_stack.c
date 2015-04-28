#include "cc_stack.h"
#include <stdlib.h>

comp_stack_t* new_stack()
{
    comp_stack_t* stack = (comp_stack_t*) malloc(sizeof(comp_stack_t));
    stack->item = new_full_dict();
    stack->next = NULL;
    return stack;
}

comp_stack_t* push_stack(comp_stack_t* stack, comp_dict_t* item)
{
    comp_stack_t* top = (comp_stack_t*) malloc(sizeof(comp_stack_t));
    top->item = item;
    top->next = stack;
    return top;
}

comp_stack_t* push_new_dict(comp_stack_t* stack)
{
    return push_stack(stack, new_full_dict());
}

comp_stack_t* pop_stack(comp_stack_t* stack)
{
    if (stack == NULL) return NULL;
    comp_stack_t* top = stack;
    stack = stack->next;
    free_stack_item(top);
    return stack;
}

comp_dict_item_t* query_stack(comp_stack_t* stack, const char* s, int sym_type)
{
    if (!(sym_type >= SIMBOLO_LITERAL_INT && sym_type <= SIMBOLO_IDENTIFICADOR)) return NULL;
    while (stack != NULL)
    {

        comp_dict_item_t* item = query_dict_noncreate(stack->item->children[sym_type], s);

        if (item != NULL)
            return item;
        else stack = stack->next;
    }
    return NULL;
}

comp_dict_item_t* query_stack_id(comp_stack_t* stack, const char* key)
{
    return query_stack(stack, key, SIMBOLO_IDENTIFICADOR);
}

void free_stack_item(comp_stack_t* stack)
{
    if (stack == NULL) return;
    if (stack->item != NULL)
        free_dict(stack->item);
    free(stack);
}

void free_stack(comp_stack_t* stack)
{
    if (stack == NULL) return;
    while (stack != NULL)
    {
        comp_stack_t* n = stack->next;
        free_stack_item(stack);
        stack = n;
    }
}
