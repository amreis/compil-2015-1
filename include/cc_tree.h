#ifndef __CC_TREE_H__
#define __CC_TREE_H__

struct comp_tree_t {
	int type;
	struct comp_dict_item_t* value;
	struct comp_tree_t *first_child, *next_sibling;
}

struct comp_tree_t* new_tree(int type, struct comp_dict_item_t* value, struct comp_tree_t *first_child, struct comp_tree_t *next_sibling);
void free_tree(struct comp_tree_t* t);

#endif
