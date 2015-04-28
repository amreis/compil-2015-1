#include "cc_misc.h"
#include "cc_dict.h"
#include "cc_stack.h"

extern unsigned long int line_num;
extern comp_stack_t* sym_stack;
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
	sym_stack = new_stack();
}

void main_finalize (void)
{
    free_stack(sym_stack);
}
