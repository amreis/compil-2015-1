#include "cc_tree.h"
#include "cc_ast.h"
#include "cc_gv.h"
#include "cc_dict.h"
#include <stdlib.h>

struct comp_tree_t* new_tree(int type)
{
	struct comp_tree_t* resp = (struct comp_tree_t*)malloc(sizeof(struct comp_tree_t));
	resp->type = type;
	resp->value = NULL;
	resp->child[0] = NULL;
	resp->child[1] = NULL;
	resp->child[2] = NULL;
	resp->next_type = NEXT_INVALID;
	resp->next = NULL;
	resp->first = resp;
	return resp;
}

struct comp_tree_t* new_tree_0(int type, struct comp_dict_item_t* value)
{
	struct comp_tree_t* resp = new_tree(type);
	resp->value = value;
    gv_declare(type, resp, value->lex);
	return resp;
}

struct comp_tree_t* new_tree_1(int type, struct comp_tree_t* child0)
{
	struct comp_tree_t* resp = new_tree(type);
	resp->child[0] = child0;
    gv_declare(type, resp, NULL);
    gv_connect(resp, child0);
	return resp;
}

struct comp_tree_t* new_tree_2(int type, struct comp_tree_t* child0, struct comp_tree_t* child1)
{
	struct comp_tree_t* resp = new_tree(type);
	resp->child[0] = child0;
	resp->child[1] = child1;
    gv_declare(type, resp, NULL);
    gv_connect(resp, child0);
    gv_connect(resp, child1);
	return resp;
}

struct comp_tree_t* new_tree_3(int type, struct comp_tree_t* child0, struct comp_tree_t* child1, struct comp_tree_t* child2)
{
	struct comp_tree_t* resp = new_tree(type);
	resp->child[0] = child0;
	resp->child[1] = child1;
	resp->child[2] = child2;
    gv_declare(type, resp, NULL);
    gv_connect(resp, child0);
    gv_connect(resp, child1);
    gv_connect(resp, child2);
	return resp;
}

struct comp_tree_t* new_tree_02(int type, struct comp_dict_item_t* value, struct comp_tree_t* child0, struct comp_tree_t* child1)
{
	struct comp_tree_t* resp = new_tree(type);
	resp->value = value;
	resp->child[0] = child0;
	resp->child[1] = child1;
    gv_declare(type, resp, value->lex);
    gv_connect(resp, child0);
    gv_connect(resp, child1);
	return resp;
}

void free_tree(struct comp_tree_t* t)
{
	int i;
	for(i=0;i<3;++i)
		if(t->child[i]!=NULL)
			free_tree(t->child[i]);
	if(t->next!=NULL)
		free_tree(t->next);
	free(t);
}

void set_next_tree(struct comp_tree_t* t, int next_type, struct comp_tree_t* next)
{
	t->next_type = next_type;
	t->next = next;
	next->first = t->first;
    gv_connect(t, next);
}
