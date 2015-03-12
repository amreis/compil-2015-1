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
	int cur_char;
	for(cur_char=0; s[cur_char]; ++cur_char)
	{
		if(t->children[s[cur_char]] == NULL)
			t->children[s[cur_char]] = new_trie_dict_item();
		t = t->children[s[cur_char]];
	}
	t->val=c;
}

struct comp_dict_item_t* query_trie(trie_dict_item* t, char* s)
{
	int cur_char;
	for(cur_char=0; s[cur_char]; ++cur_char)
	{
		if(t->children[s[cur_char]] == NULL)
			return NULL;
		t = t->children[s[cur_char]];
	}
	return t->val;
}
