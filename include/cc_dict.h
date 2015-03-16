#ifndef __CC_DICT_H__
#define __CC_DICT_H__

struct comp_dict_item_t
{
	int last_line;
};

#define TRIE_CHILDREN_SZ 256
struct comp_dict_t {
	struct comp_dict_item_t* val; //NULL se não for folha
	struct comp_dict_t* children[TRIE_CHILDREN_SZ];
};

struct comp_dict_t* new_dict();
struct comp_dict_item_t* query_dict(struct comp_dict_t* t, const char* s);
void insert_in_dict(struct comp_dict_t* t, const char* s, struct comp_dict_item_t item);
struct comp_dict_item_t create_dict_item(int last_line);
#endif
