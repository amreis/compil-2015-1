#ifndef __CC_TREE_H__
#define __CC_TREE_H__

#define NEXT_INVALID 0
#define NEXT_FUNCTION 1
#define NEXT_COMMAND 2
#define NEXT_ARGUMENT 3
#define NEXT_OUTPUT 4

#include "cc_dict.h"

typedef struct _comp_tree_t {
	int type;
	comp_dict_item_t* value;
	
	struct _comp_tree_t* child[3];
	int next_type;
	struct _comp_tree_t* next;
	struct _comp_tree_t* first;
} comp_tree_t;

comp_tree_t* new_tree(int type);

comp_tree_t* new_tree_valued(int type, comp_dict_item_t* value);

comp_tree_t* new_tree_0(int type);
comp_tree_t* new_tree_1(int type, comp_tree_t* child0);
comp_tree_t* new_tree_2(int type, comp_tree_t* child0, comp_tree_t* child1);
comp_tree_t* new_tree_3(int type, comp_tree_t* child0, comp_tree_t* child1, comp_tree_t* child2);

void free_tree(comp_tree_t* t);

comp_tree_t* append_next_tree(comp_tree_t* t, int next_type, comp_tree_t* next);
void set_list_child_tree(comp_tree_t* t, int child_index, comp_tree_t* last_child);

#endif
