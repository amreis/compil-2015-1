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

true	{ insert_in_dict(sym_table[SIMBOLO_LITERAL_BOOL], "true", create_dict_item(line_num, SIMBOLO_LITERAL_BOOL)); return TK_LIT_TRUE; }
false	{ insert_in_dict(sym_table[SIMBOLO_LITERAL_BOOL], "false", create_dict_item(line_num, SIMBOLO_LITERAL_BOOL)); return TK_LIT_FALSE; }

'.'			{
				char str[2] = ".";
				str[0] = yytext[1];
				insert_in_dict(sym_table[SIMBOLO_LITERAL_CHAR], str, create_dict_item(line_num, SIMBOLO_LITERAL_CHAR));
				return TK_LIT_CHAR;
			}

\"[^\"]*\" 		{
				char str[yyleng];
				strcpy(str, yytext+1);
				str[yyleng-2] = '\0';
				insert_in_dict(sym_table[SIMBOLO_LITERAL_STRING], str, create_dict_item(line_num, SIMBOLO_LITERAL_STRING));
				return TK_LIT_STRING;
			}

{INTEGER} 	{
				insert_in_dict(sym_table[SIMBOLO_LITERAL_INT], yytext, create_dict_item(line_num, SIMBOLO_LITERAL_INT));
				return TK_LIT_INT;
			}

{INTEGER}(\.[[:digit:]]*) {
				insert_in_dict(sym_table[SIMBOLO_LITERAL_FLOAT], yytext, create_dict_item(line_num, SIMBOLO_LITERAL_FLOAT));
				return TK_LIT_FLOAT;
			}
{ALFABET}{ALFANUM}* {
				insert_in_dict(sym_table[SIMBOLO_IDENTIFICADOR], yytext, create_dict_item(line_num, SIMBOLO_IDENTIFICADOR));
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
