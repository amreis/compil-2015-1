#include "cc_misc.h"
#include "cc_tree.h"
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

void coercion (comp_tree_t *arg1, comp_tree_t *arg2)
{
	if (arg1->semantic_type == AMA_FLOAT && arg2->semantic_type == AMA_INT)
	{
		arg2->needs_coercion = 1;
		arg2->coerced_type = AMA_FLOAT;
	}
	else if( arg1->semantic_type == AMA_INT && arg2->semantic_type == AMA_FLOAT)
	{
		arg1->needs_coercion = 1;
		arg1->coerced_type = AMA_FLOAT;
	}
	else if (arg1->semantic_type == AMA_BOOL && arg2->semantic_type == AMA_INT)
	{
		arg1->needs_coercion = 1;
		arg1->coerced_type = AMA_INT;
	}
	else if( arg1->semantic_type == AMA_INT && arg2->semantic_type == AMA_BOOL)
	{
		arg2->needs_coercion = 1;
		arg2->coerced_type = AMA_INT;
	}
	else if (arg1->semantic_type == AMA_BOOL && arg2->semantic_type == AMA_FLOAT)
	{
		arg1->needs_coercion = 1;
		arg1->coerced_type = AMA_FLOAT;
	}
	else if( arg1->semantic_type == AMA_FLOAT && arg2->semantic_type == AMA_BOOL)
	{
		arg2->needs_coercion = 1;
		arg2->coerced_type = AMA_FLOAT;
	}
}
