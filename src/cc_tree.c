#include "cc_tree.h"
#include "cc_ast.h"
#include "cc_gv.h"
#include "cc_dict.h"
#include <stdlib.h>

comp_tree_t* new_tree(int type)
{
	comp_tree_t* resp = (comp_tree_t*)malloc(sizeof(comp_tree_t));
	resp->type = type;
	resp->value = NULL;
	resp->semantic_type = AMA_INVALID;
	resp->needs_coercion = 0;
	resp->coerced_type = AMA_INVALID;
	resp->child[0] = NULL;
	resp->child[1] = NULL;
	resp->child[2] = NULL;
	resp->next_type = NEXT_INVALID;
	resp->next = NULL;
	resp->first = resp;
	resp->code = NULL;
	resp->reg_result = NULL;
	return resp;
}

comp_tree_t* new_tree_valued(int type, comp_dict_item_t* value)
{
	comp_tree_t* resp = new_tree(type);
	resp->value = value;
    #if AVALIACAO_ETAPA_3
    gv_declare(type, resp, value->lex);
    #endif
	return resp;
}

comp_tree_t* new_tree_0(int type)
{
	comp_tree_t* resp = new_tree(type);
    #if AVALIACAO_ETAPA_3
    gv_declare(type, resp, NULL);
    #endif
	return resp;
}

comp_tree_t* new_tree_1(int type, comp_tree_t* child0)
{
	comp_tree_t* resp = new_tree(type);
	resp->child[0] = child0;
    #if AVALIACAO_ETAPA_3
    gv_declare(type, resp, NULL);
    if(child0 != NULL) gv_connect(resp, child0);
    #endif
	return resp;
}

comp_tree_t* new_tree_2(int type, comp_tree_t* child0, comp_tree_t* child1)
{
	comp_tree_t* resp = new_tree(type);
	resp->child[0] = child0;
	resp->child[1] = child1;
    #if AVALIACAO_ETAPA_3
    gv_declare(type, resp, NULL);
    if(child0 != NULL) gv_connect(resp, child0);
    if(child1 != NULL) gv_connect(resp, child1);
    #endif
	return resp;
}

comp_tree_t* new_tree_3(int type, comp_tree_t* child0, comp_tree_t* child1, comp_tree_t* child2)
{
	comp_tree_t* resp = new_tree(type);
	resp->child[0] = child0;
	resp->child[1] = child1;
	resp->child[2] = child2;
    #if AVALIACAO_ETAPA_3
    gv_declare(type, resp, NULL);
    if(child0 != NULL) gv_connect(resp, child0);
    if(child1 != NULL) gv_connect(resp, child1);
    if(child2 != NULL) gv_connect(resp, child2);
    #endif
	return resp;
}

void free_tree(comp_tree_t* t)
{
	int i;
	for(i=0;i<3;++i)
		if(t->child[i]!=NULL)
			free_tree(t->child[i]);
	if(t->next!=NULL)
		free_tree(t->next);
	free(t->code);
	free(t->reg_result);
	free(t);
}

comp_tree_t* append_next_tree(comp_tree_t* t, int next_type, comp_tree_t* next)
{
	if(t == NULL)
		return next;
	else if(next != NULL)
	{
		t->next_type = next_type;
		t->next = next;
		next->first = t->first;
		#if AVALIACAO_ETAPA_3
		gv_connect(t, next);
		#endif
		return next;
	}
	else
		return t;
}

void set_list_child_tree(comp_tree_t* t, int child_index, comp_tree_t* last_child)
{
	if(last_child != NULL)
	{
		t->child[child_index] = last_child->first;
        #if AVALIACAO_ETAPA_3
		gv_connect(t, last_child->first);
        #endif
	}
}
