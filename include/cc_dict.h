#ifndef __CC_DICT_H__
#define __CC_DICT_H__

struct comp_dict_item_t
{
	int last_line;
};

#define TRIE_CHILDREN_SZ 256
typedef struct trie_dict_item_t {
	struct comp_dict_item_t* val; //NULL se não for folha
	struct trie_dict_item_t* children[256];
} trie_dict_item;

trie_dict_item* new_trie_dict_item();
struct comp_dict_item_t* query_trie(trie_dict_item* t, char* s);

#endif
