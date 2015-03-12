/*
  Coloque aqui o identificador do grupo e dos seus membros
*/
%{
#include "parser.h" //arquivo automaticamente gerado pelo bison
unsigned long int line_num = 1;
%}
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
<=		return TK_OC_LE;
>=		return TK_OC_GE;
==		return TK_OC_EQ;
!=		return TK_OC_NE;
&&		return TK_OC_AND;
||		return TK_OC_OR;
[a-zA-Z]+	return TK_IDENTIFICADOR;

%%
