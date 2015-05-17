#ifndef DIM_LIST_H
#define DIM_LIST_H
#include <stdlib.h>

// This is sooooo redundant with param_list but I didn't wanna use param_list
// due to semantic reasons.

typedef struct _dim_list_item_t {
	int dim_size;
	struct _dim_list_item_t* next;
} dim_list_item_t;

typedef struct _dim_list_t {
	dim_list_item_t* start;
	dim_list_item_t* end;
	int length;
} dim_list_t;

dim_list_t* new_dim_list();
dim_list_t* append_dim(dim_list_t* l, dim_list_item_t* dim);
void free_dim_list(dim_list_t* l);

dim_list_item_t* new_dim_list_item();

int* dim_list_to_ary(dim_list_t* l);

#endif
