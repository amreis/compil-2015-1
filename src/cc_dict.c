#include "cc_dict.h"
#include <stdlib.h>
#include <stdio.h>

/**
    The implemented dictionary is a TRIE, a recursive structure that uses the strings'
    characters to "go down a tree", with the data stored at the leaf node.
    This dictionary is being used to represent the symbol table
*/

/**
 * Function to create a new dictionary, and since it's a recursive structure, its children too.
 */
struct comp_dict_t* new_dict()
{
	int i;
	struct comp_dict_t* resp = (struct comp_dict_t*)malloc(sizeof(struct comp_dict_t));
	resp->val = NULL;
	for(i=0;i<TRIE_CHILDREN_SZ;++i)
		resp->children[i]=NULL;
	return resp;
}

/**
 * Destructor of the dictionary structure.
 */
void free_dict(struct comp_dict_t* t)
{
	int i;
	for(i=0;i<TRIE_CHILDREN_SZ;++i)
		if(t->children[i] != NULL)
			free_dict(t->children[i]);
	free(t->val);
	free(t);
}

/**
 * Function that retrieves a dictionary entry, or allocates one in case it
 * does not exist yet. Returns a pointer to the entry, so that its attributes
 * might be changed by another function.
 */
struct comp_dict_item_t* query_dict(struct comp_dict_t* t, const char* s)
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

/**
 * Insertion function: given the dictionary, the key and the value, inserts it in the tree
 * or replaces its old value in case the key was already present in the dictionary.
 */
void insert_in_dict(struct comp_dict_t* t, const char* s, struct comp_dict_item_t item)
{
	*query_dict(t, s) = item;
}

/**
 * Function to abstract the creation of a dictionary value type, in case it gets more complex.
 */
struct comp_dict_item_t create_dict_item(int last_line, int token_type)
{
	struct comp_dict_item_t item;
	item.last_line = last_line;
	item.token_type = token_type;
	return item;
}
