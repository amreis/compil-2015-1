#include "cc_list.h"

comp_list_t* new_list()
{
    comp_list_t* l = (comp_list_t*) malloc(sizeof(comp_list_t));
    l->start = l->end = NULL;
    return l;
}

comp_list_t* append_instr(comp_list_t* l, comp_list_item_t* item)
{
    if (l == NULL) return NULL;
    if (l->start == NULL)
    {
        l->start = l->end = item;
    }
    else
    {
        l->end->next = item;
        l->end = item;
    }
    return l;
}

comp_list_t* concat_list(comp_list_t* head, comp_list_t* tail)
{
    if (head == NULL)
        return tail;
    if (tail == NULL)
        return head;
    head->end->next = tail->start;
    head->end = tail->end;
}

comp_list_item_t* new_list_item()
{
    comp_list_item_t* i = (comp_list_item_t*) malloc(sizeof(comp_list_item_t));
    i->instr = NULL;
    i->next  = NULL;
    return i;
}

comp_list_item_t* new_list_item_valued(const char* instr)
{
    comp_list_item_t* i = new_list_item();
    i->instr = strdup(instr);
    return i;
}

void free_list_item(comp_list_item_t* item)
{
    if (item == NULL) return;
    free_list_item(item->next);
    free(item->instr);
    free(item);
}

void free_list(comp_list_t* l)
{
    if (l == NULL) return;
    free_list_item(l->start);
    free(l);
}
