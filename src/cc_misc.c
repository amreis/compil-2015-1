#include "cc_misc.h"
#include "cc_dict.h"
extern unsigned long int line_num;
extern comp_dict_t* sym_table;
int getLineNumber (void)
{
  //implemente esta função
  return line_num;
}

void yyerror (char const *mensagem)
{
  fprintf (stderr, "%s at line %d\n", mensagem, getLineNumber());
}

void main_init (int argc, char **argv)
{
	sym_table = new_full_dict();
}

void main_finalize (void)
{
	free_dict(sym_table);
}
