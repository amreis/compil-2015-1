#include "cc_dict.h"
#include <stdlib.h>

comp_dict_t* new_dict()
{
	int i;
	comp_dict_t* resp = (comp_dict_t*)malloc(sizeof(comp_dict_t));
	resp->val = NULL;
	for(i=0;i<TRIE_CHILDREN_SZ;++i)
		resp->children[i]=NULL;
	return resp;
}

struct comp_dict_item_t* query_dict(comp_dict_t* t, char* s)
{
	int cur_char;
	for(cur_char=0; s[cur_char]; ++cur_char)
	{
		if(t->children[s[cur_char]] == NULL)
			t->children[s[cur_char]] = new_dict();
		t = t->children[s[cur_char]];
	}
	
	if(t->val == NULL)
		t->val = (struct comp_dict_item_t*)malloc(sizeof(struct comp_dict_item_t));
	
	return t->val;
}
