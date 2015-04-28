#ifndef __CC_TREE_H__
#define __CC_TREE_H__

#define NEXT_INVALID 0
#define NEXT_FUNCTION 1
#define NEXT_COMMAND 2
#define NEXT_ARGUMENT 3
#define NEXT_OUTPUT 4

struct comp_tree_t {
	int type;
	struct comp_dict_item_t* value;
	
	struct comp_tree_t* child[3];
	int next_type;
	struct comp_tree_t* next;
	struct comp_tree_t* first;
};

struct comp_tree_t* new_tree(int type);

struct comp_tree_t* new_tree_valued(int type, struct comp_dict_item_t* value);

struct comp_tree_t* new_tree_0(int type);
struct comp_tree_t* new_tree_1(int type, struct comp_tree_t* child0);
struct comp_tree_t* new_tree_2(int type, struct comp_tree_t* child0, struct comp_tree_t* child1);
struct comp_tree_t* new_tree_3(int type, struct comp_tree_t* child0, struct comp_tree_t* child1, struct comp_tree_t* child2);

void free_tree(struct comp_tree_t* t);

struct comp_tree_t* append_next_tree(struct comp_tree_t* t, int next_type, struct comp_tree_t* next);
void set_list_child_tree(struct comp_tree_t* t, int child_index, struct comp_tree_t* last_child);

#endif
