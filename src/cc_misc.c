#include "cc_misc.h"
#include "cc_dict.h"
extern unsigned long int line_num;
extern struct comp_dict_t* sym_table;
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
	sym_table = new_dict();
}

void main_finalize (void)
{
  //implemente esta função com rotinas de inicialização, se necessário
  // TODO free stuff
	free_dict(sym_table);
}
