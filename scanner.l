/*
  Galatasaralister

  Alister Machado dos Reis
  Daniel dos Santos Bossle
  Eduardo Faccin Vernier
*/
%{
#include "parser.h" //arquivo automaticamente gerado pelo bison
#include "cc_dict.h"
#include "cc_stack.h"

unsigned long int line_num = 1;

comp_stack_t* sym_stack;

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
				comp_dict_item_t* item = query_dict(sym_stack->item->children[SIMBOLO_LITERAL_BOOL], "true");
				if (item->token_type == SIMBOLO_INVALIDO)
				    item->lex = (char*)malloc(yyleng+1);
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_BOOL;
				item->token_val.bool_val = 1;
                strcpy(item->lex, yytext);
				yylval.valor_simbolo_lexico = item;
				return TK_LIT_TRUE;
			}

false		{
				comp_dict_item_t* item = query_dict(sym_stack->item->children[SIMBOLO_LITERAL_BOOL], "false");
				if (item->token_type == SIMBOLO_INVALIDO)
				    item->lex = (char*)malloc(yyleng+1);
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_BOOL;
				item->token_val.bool_val = 0;
                strcpy(item->lex, yytext);
				yylval.valor_simbolo_lexico = item;
				return TK_LIT_FALSE;
			}

'.'			{
				char str[2] = "."; str[0] = yytext[1];
				comp_dict_item_t* item = query_dict(sym_stack->item->children[SIMBOLO_LITERAL_CHAR], str);
				if (item->token_type == SIMBOLO_INVALIDO)
				    item->lex = (char*)malloc(sizeof(str));
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_CHAR;
				item->token_val.char_val = yytext[1];
                strcpy(item->lex, str);
				yylval.valor_simbolo_lexico = item;
				return TK_LIT_CHAR;
			}

\"[^\"]*\" 		{
				char str[yyleng];
				strcpy(str, yytext+1); str[yyleng-2] = '\0';
				comp_dict_item_t* item = query_dict(sym_stack->item->children[SIMBOLO_LITERAL_STRING], str);
				if(item->token_type == SIMBOLO_INVALIDO)
				{
					item->token_val.string_val = (char*)malloc(yyleng);
					item->lex = (char*)malloc(yyleng);
				}
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_STRING;
				strcpy(item->token_val.string_val, str);
				strcpy(item->lex, str);
				yylval.valor_simbolo_lexico = item;
				return TK_LIT_STRING;
			}

{INTEGER} 	{
				comp_dict_item_t* item = query_dict(sym_stack->item->children[SIMBOLO_LITERAL_INT], yytext);
				if (item->token_type == SIMBOLO_INVALIDO)
				    item->lex = (char*)malloc(yyleng+1);
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_INT;
				item->token_val.int_val = atoi(yytext);
				strcpy(item->lex, yytext);
				yylval.valor_simbolo_lexico = item;
				return TK_LIT_INT;
			}

{INTEGER}(\.[[:digit:]]*) {
				comp_dict_item_t* item = query_dict(sym_stack->item->children[SIMBOLO_LITERAL_FLOAT], yytext);
				if (item->token_type == SIMBOLO_INVALIDO)
				    item->lex = (char*)malloc(yyleng+1);
				item->last_line = line_num;
				item->token_type = SIMBOLO_LITERAL_FLOAT;
				item->token_val.float_val = atof(yytext);
                strcpy(item->lex, yytext);
				yylval.valor_simbolo_lexico = item;
				return TK_LIT_FLOAT;
			}
{ALFABET}{ALFANUM}* {
				comp_dict_item_t* item;
				if ((item = query_stack_id(sym_stack, yytext)) == NULL)
					item = query_dict(sym_stack->item->children[SIMBOLO_IDENTIFICADOR], yytext);
				if(item->token_type == SIMBOLO_INVALIDO)
				{
					item->token_val.identificador_val = (char*)malloc(yyleng+1);
					item->lex = (char*)malloc(yyleng+1);
				}
				item->last_line = line_num;
				item->token_type = SIMBOLO_IDENTIFICADOR;
				strcpy(item->token_val.identificador_val, yytext);
				strcpy(item->lex, yytext);
				yylval.valor_simbolo_lexico = item;
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
