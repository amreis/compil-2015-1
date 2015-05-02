#include "cc_misc.h"
#include "cc_tree.h"
#include "cc_stack.h"
#include "cc_semantic.h"

extern comp_stack_t* sym_stack;
extern comp_tree_t* final_ast;
extern int first_error;

void main_init (int argc, char **argv)
{
	first_error = IKS_SUCCESS;
	sym_stack = new_stack();
}

void main_finalize (void)
{
    if (final_ast != NULL)
        free_tree(final_ast);
    if (sym_stack != NULL)
        free_stack(sym_stack);
}
