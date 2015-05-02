#include "cc_misc.h"

int getLineNumber (void)
{
  //implemente esta função
  return line_num;
}

void yyerror (char const *mensagem)
{
  fprintf (stderr, "%s at line %d\n", mensagem, getLineNumber());
}

void report_error(int errcode, ...)
{
	if(first_error == IKS_SUCCESS)
		first_error = errcode;
    va_list a_list;
	va_start(a_list, errcode);
    char buffer[100];
    char* arg0;
    int arg1, arg2;
	switch (errcode)
	{
	case IKS_ERROR_UNDECLARED:
    arg0 = va_arg(a_list, char*);
	sprintf(buffer, "Undeclared identifier %s", arg0);
	break;
	case IKS_ERROR_DECLARED:
	arg0 = va_arg(a_list, char*);
	sprintf(buffer, "Double declaration of identifier %s", arg0);
	break;
	case IKS_ERROR_VARIABLE:
	arg0 = va_arg(a_list, char*);
	sprintf(buffer, "The identifier %s must be used as a variable", arg0);
	break;
	case IKS_ERROR_VECTOR:
	arg0 = va_arg(a_list, char*);
	sprintf(buffer, "The identifier %s must be used as a vector", arg0);
	break;
	case IKS_ERROR_FUNCTION:
	arg0 = va_arg(a_list, char*);
	sprintf(buffer, "The identifier %s must be used in a function call", arg0);
	break;
	case IKS_ERROR_WRONG_TYPE:
	arg0 = va_arg(a_list, char*);
	sprintf(buffer, "Wrong types in %s expression", arg0);
	break;
	case IKS_ERROR_STRING_TO_X:
	sprintf(buffer, "Invalid conversion from string");
	break;
	case IKS_ERROR_CHAR_TO_X:
	sprintf(buffer, "Invalid conversion from char");
	break;
	case IKS_ERROR_MISSING_ARGS:
	arg0 = va_arg(a_list, char*);
	arg1 = va_arg(a_list, int);
	arg2 = va_arg(a_list, int);
	sprintf(buffer, "Function %s called with too few arguments (needs %d, %d provided)", arg0, arg1, arg2);
	break;
	case IKS_ERROR_EXCESS_ARGS:
	arg0 = va_arg(a_list, char*);
	arg1 = va_arg(a_list, int);
	arg2 = va_arg(a_list, int);
	sprintf(buffer, "Function %s called with too many arguments (needs %d, %d provided)", arg0, arg1, arg2);
	break;
	case IKS_ERROR_WRONG_TYPE_ARGS:
	arg0 = va_arg(a_list, char*);
	arg1 = va_arg(a_list, int);
	sprintf(buffer, "Function %s call arg#%d has wrong type", arg0, arg1);
	break;
	case IKS_ERROR_WRONG_PAR_INPUT:
	sprintf(buffer, "Wrong input parameter");
	break;
	case IKS_ERROR_WRONG_PAR_OUTPUT:
	arg1 = va_arg(a_list, int);
	sprintf(buffer, "Wrong output parameter number %d", arg1);
	break;
	case IKS_ERROR_WRONG_PAR_RETURN:
	arg0 = va_arg(a_list, char*);
	sprintf(buffer, "Function %s return type incompatible with the provided type", arg0);
	break;
	}
	va_end(a_list);
	yyerror(buffer);
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

// Returns the final type
int coercion (comp_tree_t *arg1, comp_tree_t *arg2)
{
	if (arg1->semantic_type == arg2->semantic_type)
		return arg1->semantic_type;
	if (arg1->semantic_type == AMA_FLOAT && arg2->semantic_type == AMA_INT)
	{
		arg2->needs_coercion = 1;
		arg2->coerced_type = AMA_FLOAT;
		return AMA_FLOAT;
	}
	else if( arg1->semantic_type == AMA_INT && arg2->semantic_type == AMA_FLOAT)
	{
		arg1->needs_coercion = 1;
		arg1->coerced_type = AMA_FLOAT;
		return AMA_FLOAT;
	}
	else if (arg1->semantic_type == AMA_BOOL && arg2->semantic_type == AMA_INT)
	{
		arg1->needs_coercion = 1;
		arg1->coerced_type = AMA_INT;
		return AMA_INT;
	}
	else if( arg1->semantic_type == AMA_INT && arg2->semantic_type == AMA_BOOL)
	{
		arg2->needs_coercion = 1;
		arg2->coerced_type = AMA_INT;
		return AMA_INT;
	}
	else if (arg1->semantic_type == AMA_BOOL && arg2->semantic_type == AMA_FLOAT)
	{
		arg1->needs_coercion = 1;
		arg1->coerced_type = AMA_FLOAT;
		return AMA_FLOAT;
	}
	else if( arg1->semantic_type == AMA_FLOAT && arg2->semantic_type == AMA_BOOL)
	{
		arg2->needs_coercion = 1;
		arg2->coerced_type = AMA_FLOAT;
		return AMA_FLOAT;
	}
	return AMA_INVALID;
}

int is_compatible(int expr_type, int required_type)
{
	if (expr_type == required_type) return 1;
	if (expr_type == AMA_INT && (required_type == AMA_FLOAT || required_type == AMA_BOOL))
		return 1;
	if (expr_type == AMA_BOOL && (required_type == AMA_FLOAT || required_type == AMA_INT))
		return 1;
	if (expr_type == AMA_FLOAT && (required_type == AMA_INT || required_type == AMA_BOOL))
		return 1;
	return 0;
}
