#include "cc_tree.h"
#include <stdlib.h>

struct comp_tree_t* new_tree(int type, struct comp_dict_item_t* value, struct comp_tree_t *first_child, struct comp_tree_t *next_sibling)
{
	struct comp_tree_t* resp = (struct comp_tree_t*)malloc(sizeof(struct comp_tree_t));
	resp->type = type;
	resp->value = value;
	resp->first_child = first_child;
	resp->next_sibling = next_sibling;
}

void free_tree(struct comp_tree_t* t)
{
	if(t->first_child != NULL)
		free_tree(t->first_child);
	if(t->next_sibling != NULL)
		free_tree(t->next_sibling);
	free(t);
}
