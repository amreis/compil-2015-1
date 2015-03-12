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
[a-zA-Z]+	return TK_IDENTIFICADOR;

%%
