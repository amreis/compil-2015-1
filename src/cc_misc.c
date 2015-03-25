#include "cc_misc.h"
#include "cc_dict.h"
extern unsigned long int line_num;
extern struct comp_dict_t* sym_table[];
int getLineNumber (void)
{
  //implemente esta função
  return line_num;
}

void yyerror (char const *mensagem)
{
  fprintf (stderr, "%s - %d\n", mensagem, getLineNumber());
}

void main_init (int argc, char **argv)
{
	int i;
	for(i=1;i<=NUMBER_SYMBOL_TYPES;++i)
		sym_table[i] = new_dict();
}

void main_finalize (void)
{
	int i;
	for(i=1;i<=NUMBER_SYMBOL_TYPES;++i)
		free_dict(sym_table[i]);
}
