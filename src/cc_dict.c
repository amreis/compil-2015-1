#include "cc_dict.h"
#include <stdlib.h>

trie_dict_item* new_trie_dict_item()
{
	int i;
	trie_dict_item* resp = (trie_dict_item*)malloc(sizeof(trie_dict_item));
	resp->val = NULL;
	for(i=0;i<TRIE_CHILDREN_SZ;++i)
		resp->children[i]=NULL;
	return resp;
}

void insert_trie(trie_dict_item* t, char* s, struct comp_dict_item_t* c)
{
	t->val=c; //stub
}

struct comp_dict_item_t* query_trie(trie_dict_item* t, char* s)
{
	return t->val; //stub
}
