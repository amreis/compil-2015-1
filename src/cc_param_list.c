#include "cc_param_list.h"
#include <stdlib.h>

comp_param_list_t* new_param_list()
{
    comp_param_list_t* l = (comp_param_list_t*) malloc(sizeof(comp_param_list_t));
    l->end = l->start = NULL;
    l->length = 0;
    return l;
}

comp_param_list_t* append_param_list(comp_param_list_t* l, int param_type)
{
    comp_param_list_item_t* n = (comp_param_list_item_t*) malloc(sizeof(comp_param_list_item_t));
    n->param_type = param_type;
    n->next = NULL;
    if (l->end == NULL)
    {
        l->start = l->end = n;
    }
    else {
        l->end->next = n;
        l->end = n;
    }
    l->length++;
    return l;
}

void free_param_list(comp_param_list_t *l)
{
	if (l == NULL) return;
    comp_param_list_item_t* s = l->start;
    if (s == NULL) return;
    
    while (s->next != NULL)
    {
        comp_param_list_item_t* next = s->next;
        free(s);
        s = next;
    }
    free(s);
}

comp_param_list_item_t* new_param_list_item()
{
    comp_param_list_item_t* item = (comp_param_list_item_t*) malloc(sizeof(comp_param_list_item_t));
    item->next = NULL;
    item->param_type = -1;
    return item;
}

int* param_list_to_ary(comp_param_list_t* list)
{
	if (list == NULL) return NULL;
    int* array = (int*) malloc(list->length * sizeof(int));
    comp_param_list_item_t* start;
    int i = 0;
    for (start = list->start ; start != NULL; start = start->next, i++)
    {
        array[i] = start->param_type;
    }
    free_param_list(list);
    return array;
}
