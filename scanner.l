/*
  Galatasaralister

  Alister Machado dos Reis
  Daniel dos Santos Bossle
  Eduardo Faccin Vernier
*/
%{
#include "parser.h" //arquivo automaticamente gerado pelo bison
#include "cc_dict.h"

unsigned long int line_num = 1;
struct comp_dict_t* sym_table[NUMBER_SYMBOL_TYPES+1];
%}

INTEGER [[:digit:]]+
ALFABET [[:alpha:]_]
ALFANUM {ALFABET}|[[:digit:]]

%x MULTILINE_COMMENT
%%
[ \t]+ 	{ }
\n		{ line_num++; }
int		return TK_PR_INT;
float	return TK_PR_FLOAT;
bool	return TK_PR_BOOL;
char	return TK_PR_CHAR;
string	return TK_PR_STRING;
if		return TK_PR_IF;
then	return TK_PR_THEN;
else	return TK_PR_ELSE;
while	return TK_PR_WHILE;
do		return TK_PR_DO;
input	return TK_PR_INPUT;
output	return TK_PR_OUTPUT;
return	return TK_PR_RETURN;
static	return TK_PR_STATIC;
const	return TK_PR_CONST;
"<="	return TK_OC_LE;
">="	return TK_OC_GE;
"=="	return TK_OC_EQ;
"!="	return TK_OC_NE;
"&&"	return TK_OC_AND;
"||"	return TK_OC_OR;
","|";"|":"|"("|")"|"["|"]"|"{"|"}"|"+"|"-"|"*"|"/"|"<"|">"|"="|"!"|"&"|"$"	{ return yytext[0]; }

true		{
				struct comp_dict_item_t* item = query_dict(sym_table[SIMBOLO_LITERAL_BOOL], "true");
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_BOOL;
				item->token_val.bool_val = 1;
				return TK_LIT_TRUE;
			}

false		{
				struct comp_dict_item_t* item = query_dict(sym_table[SIMBOLO_LITERAL_BOOL], "false");
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_BOOL;
				item->token_val.bool_val = 0;
				return TK_LIT_FALSE;
			}

'.'			{
				char str[2] = "."; str[0] = yytext[1];
				struct comp_dict_item_t* item = query_dict(sym_table[SIMBOLO_LITERAL_CHAR], str);
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_CHAR;
				item->token_val.char_val = yytext[1];
				return TK_LIT_CHAR;
			}

\"[^\"]*\" 		{
				char* str = (char*)malloc(yyleng);
				strcpy(str, yytext+1); str[yyleng-2] = '\0';
				struct comp_dict_item_t* item = query_dict(sym_table[SIMBOLO_LITERAL_STRING], str);
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_STRING;
				item->token_val.string_val = str;
				return TK_LIT_STRING;
			}

{INTEGER} 	{
				struct comp_dict_item_t* item = query_dict(sym_table[SIMBOLO_LITERAL_INT], yytext);
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_INT;
				item->token_val.int_val = atoi(yytext);
				return TK_LIT_INT;
			}

{INTEGER}(\.[[:digit:]]*) {
				struct comp_dict_item_t* item = query_dict(sym_table[SIMBOLO_LITERAL_FLOAT], yytext);
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_FLOAT;
				item->token_val.float_val = atof(yytext);
				return TK_LIT_FLOAT;
			}
{ALFABET}{ALFANUM}* {
				struct comp_dict_item_t* item = query_dict(sym_table[SIMBOLO_IDENTIFICADOR], yytext);
				item->last_line = line_num;
				item->token_type = SIMBOLO_IDENTIFICADOR;
				item->token_val.identificador_val = (char*)malloc(yyleng+1);
				return TK_IDENTIFICADOR;
			}

\/\/.*\n	{ line_num++; }

\/\*		{ BEGIN(MULTILINE_COMMENT); }
<MULTILINE_COMMENT>[^\*\/\n]*\n { line_num++; }
<MULTILINE_COMMENT>[^\*\/\n] { }
<MULTILINE_COMMENT>(\*|\/) { }
<MULTILINE_COMMENT>\*\/	{ BEGIN(INITIAL); }
. { return TOKEN_ERRO; }
%%
