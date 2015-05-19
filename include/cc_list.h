#ifndef CC_LIST_H
#define CC_LIST_H

#include <stdlib.h>
#include <string.h>

typedef struct _comp_list_item_t {
    char* instr;
    struct _comp_list_item_t *next;
} comp_list_item_t;

typedef struct _comp_list_t {
    comp_list_item_t* start;
    comp_list_item_t* end;
} comp_list_t;

comp_list_t* new_list();

void append_instr(comp_list_t* l, comp_list_item_t* i);
comp_list_t* concat_list(comp_list_t* head, comp_list_t* tail); //head and tail become invalid

comp_list_item_t* new_list_item();
comp_list_item_t* new_list_item_valued(const char* instr);

void free_list(comp_list_t* l);
#endif
