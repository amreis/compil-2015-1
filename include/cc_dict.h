#ifndef __CC_DICT_H__
#define __CC_DICT_H__

#define SIMBOLO_LITERAL_INT   	1
#define SIMBOLO_LITERAL_FLOAT 	2
#define SIMBOLO_LITERAL_CHAR  	3
#define SIMBOLO_LITERAL_STRING	4
#define SIMBOLO_LITERAL_BOOL  	5
#define SIMBOLO_IDENTIFICADOR 	6

#define NUMBER_SYMBOL_TYPES 6

struct comp_dict_item_t
{
	int last_line;
	int token_type;
	union {
		int int_val;
		float float_val;
		char char_val;
		char* string_val;
		int bool_val;
		char* identificador_val;
	} token_val;
};

#define TRIE_CHILDREN_SZ 256
struct comp_dict_t {
	struct comp_dict_item_t* val; //NULL se não for folha
	struct comp_dict_t* children[TRIE_CHILDREN_SZ];
};

struct comp_dict_t* new_dict();
struct comp_dict_item_t* query_dict(struct comp_dict_t* t, const char* s);
void insert_in_dict(struct comp_dict_t* t, const char* s, struct comp_dict_item_t item);
struct comp_dict_item_t create_dict_item(int last_line, int token_type);
#endif
