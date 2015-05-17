#include "cc_dim_list.h"

dim_list_t* new_dim_list()
{
    dim_list_t* list = (dim_list_t*) malloc(sizeof(dim_list_t));
    list->start = list->end = NULL;
    list->length = 0;
    return list;
}
dim_list_t* append_dim(dim_list_t* l, dim_list_item_t* dim)
{
    if (l == NULL)
        return NULL;
    if (l->start == NULL)
    {
        l->start = l->end = dim;
        dim->next = NULL;
    }
    else
    {
        l->end->next = dim;
        dim->next = NULL;
        l->end = dim;
    }
    l->length++;
    return l;
}

void free_dim_list_items(dim_list_item_t* i)
{
    if (i == NULL) return;
    free_dim_list_items(i->next);
    free(i);
}
void free_dim_list(dim_list_t* l)
{
    if (l == NULL) return;
    if (l->start != NULL)
        free_dim_list_items(l->start);
    free(l);
}

dim_list_item_t* new_dim_list_item()
{
    dim_list_item_t* item = (dim_list_item_t*) malloc(sizeof(dim_list_item_t));
    item->next = NULL;
    item->dim_size = -1;
    return item;
}

int* dim_list_to_ary(dim_list_t* l)
{
    if (l == NULL) return NULL;
    int* array = (int*)malloc(l->length*sizeof(int));
    int i;
    dim_list_item_t* s;
    for (i = 0, s = l->start; i < l->length; ++i, s = s->next)
    {
        array[i] = s->dim_size;
    }
    free_dim_list(l);
    return array;
}
