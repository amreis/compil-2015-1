#ifndef PARAM_LIST_H
#define PARAM_LIST_H

typedef struct _comp_param_list_item_t {
    int param_type;
    struct _comp_param_list_item_t* next;
} comp_param_list_item_t;

typedef struct _comp_param_list_t {
    comp_param_list_item_t* end;
    comp_param_list_item_t* start;
    int length;
} comp_param_list_t;

comp_param_list_t* new_param_list();
comp_param_list_t* append_param_list_item(comp_param_list_t* l, comp_param_list_item_t* i);
void free_param_list(comp_param_list_t* l);

comp_param_list_item_t* new_param_list_item();

int* param_list_to_ary(comp_param_list_t* list);

#endif
