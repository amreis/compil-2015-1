#include "cc_dict.h"
#include <stdlib.h>
#include <stdio.h>
struct comp_dict_t* new_dict()
{
	int i;
	struct comp_dict_t* resp = (struct comp_dict_t*)malloc(sizeof(struct comp_dict_t));
	resp->val = NULL;
	for(i=0;i<TRIE_CHILDREN_SZ;++i)
		resp->children[i]=NULL;
	return resp;
}

void free_dict(struct comp_dict_t* t)
{
	int i;
	for(i=0;i<TRIE_CHILDREN_SZ;++i)
		if(t->children[i] != NULL)
			free_dict(t->children[i]);
	free(t);
}

struct comp_dict_item_t* query_dict(struct comp_dict_t* t, char* s)
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

void insert_in_dict(struct comp_dict_t* t, char* s, struct comp_dict_item_t item)
{
	*query_dict(t, s) = item;
	printf("Inserted key: %s, value: %d in symtab.\n", s, item.last_line);
}

struct comp_dict_item_t create_dict_item(int last_line)
{
	struct comp_dict_item_t item;
	item.last_line = last_line;
	return item;
}
