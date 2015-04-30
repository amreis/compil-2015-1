#include "cc_misc.h"
#include "cc_dict.h"
#include "cc_stack.h"
#include "cc_tree.h"

extern unsigned long int line_num;
extern comp_stack_t* sym_stack;
extern comp_tree_t* final_ast;
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
    if (final_ast != NULL)
        free_tree(final_ast);
    if (sym_stack != NULL)
        free_stack(sym_stack);
}
