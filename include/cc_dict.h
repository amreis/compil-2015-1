#ifndef __CC_DICT_H__
#define __CC_DICT_H__

#define SIMBOLO_LITERAL_INT   	1
#define SIMBOLO_LITERAL_FLOAT 	2
#define SIMBOLO_LITERAL_CHAR  	3
#define SIMBOLO_LITERAL_STRING	4
#define SIMBOLO_LITERAL_BOOL  	5
#define SIMBOLO_IDENTIFICADOR 	6

#define AMA_INVALID -1
#define AMA_INT 1
#define AMA_FLOAT 2
#define AMA_CHAR 3
#define AMA_STRING 4
#define AMA_BOOL 5

#define SIMBOLO_INVALIDO   	0
#define NUMBER_SYMBOL_TYPES 6

typedef struct _comp_dict_item_t
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
    char *lex;
    struct {
        int base_type;
        char isVector;
    } type;
} comp_dict_item_t;

#define TRIE_CHILDREN_SZ 256
typedef struct _comp_dict_t {
	comp_dict_item_t* val; //NULL se não for folha
	struct _comp_dict_t* children[TRIE_CHILDREN_SZ];
} comp_dict_t ;

comp_dict_t* new_full_dict();
comp_dict_t* new_dict();
void free_dict(comp_dict_t* t);
comp_dict_item_t* query_dict(comp_dict_t* t, const char* s);
comp_dict_item_t* query_dict_noncreate(comp_dict_t* t, const char* s);
void insert_in_dict(comp_dict_t* t, const char* s, comp_dict_item_t item);
comp_dict_item_t create_dict_item(int last_line, int token_type);
void free_dict_item(comp_dict_item_t* item);
#endif
