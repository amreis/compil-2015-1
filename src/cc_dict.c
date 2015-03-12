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

struct comp_dict_item_t* query_trie(trie_dict_item* t, char* s)
{
	int cur_char;
	for(cur_char=0; s[cur_char]; ++cur_char)
	{
		if(t->children[s[cur_char]] == NULL)
			t->children[s[cur_char]] = new_trie_dict_item();
		t = t->children[s[cur_char]];
	}
	
	if(t->val == NULL)
		t->val = (struct comp_dict_item_t*)malloc(sizeof(struct comp_dict_item_t));
	
	return t->val;
}
