#ifndef __CC_TREE_H__
#define __CC_TREE_H__

#define NEXT_INVALID 0
#define NEXT_COMMAND 1
#define NEXT_ARGUMENT 2
#define NEXT_OUTPUT 3

struct comp_tree_t {
	int type;
	struct comp_dict_item_t* value;
	
	struct comp_tree_t* child[3];
	int next_type;
	struct comp_tree_t* next;
};

struct comp_tree_t* new_tree(int type);
struct comp_tree_t* new_tree_0(int type, struct comp_dict_item_t* value);
struct comp_tree_t* new_tree_1(int type, struct comp_tree_t* child0);
struct comp_tree_t* new_tree_2(int type, struct comp_tree_t* child0, struct comp_tree_t* child1);
struct comp_tree_t* new_tree_3(int type, struct comp_tree_t* child0, struct comp_tree_t* child1, struct comp_tree_t* child2);
struct comp_tree_t* new_tree_02(int type, struct comp_dict_item_t* value, struct comp_tree_t* child0, struct comp_tree_t* child1);
void free_tree(struct comp_tree_t* t);

#endif
