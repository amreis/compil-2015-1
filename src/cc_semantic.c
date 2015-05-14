#include "cc_semantic.h"
#include <stdio.h>

extern unsigned long int line_num;
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
    va_list a_list;
	va_start(a_list, errcode);
	if(first_error == IKS_SUCCESS)
		first_error = errcode;
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
	sprintf(buffer, "Wrong types in the expression");
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


int infer_type(int type1, int type2)
{
	if(type1 == AMA_FLOAT || type2 == AMA_FLOAT)
		return AMA_FLOAT;
	if(type1 == AMA_INT || type2 == AMA_INT)
		return AMA_INT;
	if(type1 == AMA_BOOL || type2 == AMA_BOOL)
		return AMA_BOOL;
	return type1;
}

int infer_numeric_type(int type1, int type2)
{
	if(type1 == AMA_FLOAT || type2 == AMA_FLOAT)
		return AMA_FLOAT;
	else
		return AMA_INT;
}

void coerce(comp_tree_t *arg, int to_type)
{
	int from_type = arg->semantic_type;
	if(from_type == to_type)
		arg->needs_coercion = 0;
	else {
		arg->needs_coercion = 1;
		if(from_type == AMA_CHAR)
			report_error(IKS_ERROR_CHAR_TO_X);
		else if(from_type == AMA_STRING)
			report_error(IKS_ERROR_STRING_TO_X);
		else if(to_type == AMA_CHAR || to_type == AMA_STRING) // TODO: get a more "correct" condition here
			report_error(IKS_ERROR_WRONG_TYPE);
	}
	arg->coerced_type = to_type;
}

void try_to_coerce(comp_tree_t *arg, int to_type, int wrong_type_error, ...)
{
	va_list a_list;
	va_start(a_list, wrong_type_error);
	int from_type = arg->semantic_type;
	if(from_type == to_type)
		arg->needs_coercion = 0;
	else {
		arg->needs_coercion = 1;
		if(from_type == AMA_CHAR)
			report_error(wrong_type_error, a_list);
		else if(from_type == AMA_STRING)
			report_error(wrong_type_error, a_list);
		else if(to_type == AMA_CHAR || to_type == AMA_STRING) // TODO: get a more "correct" condition here
			report_error(wrong_type_error, a_list);
	}
	arg->coerced_type = to_type;
}

void coerce_dict_entry(comp_dict_item_t *arg, int to_type)
{
	int from_type = arg->type.base;
	if(from_type != to_type)
	{
		if(from_type == AMA_CHAR)
			report_error(IKS_ERROR_CHAR_TO_X);
		else if(from_type == AMA_STRING)
			report_error(IKS_ERROR_STRING_TO_X);
		else if(to_type == AMA_CHAR || to_type == AMA_STRING) // TODO: get a more "correct" condition here
			report_error(IKS_ERROR_WRONG_TYPE);
	}
	// TODO: actually coerce, or mark for coercion
}


comp_dict_item_t* query_stack_var(comp_stack_t* stack, const char* key)
{
	comp_dict_item_t* ret = query_stack(stack, key, SIMBOLO_IDENTIFICADOR);
	if (ret == NULL || ret->type.base == AMA_INVALID)
		report_error(IKS_ERROR_UNDECLARED, key);
	else if (ret->type.is_vector)
		report_error(IKS_ERROR_VECTOR, key);
	else if (ret->type.is_function)
		report_error(IKS_ERROR_FUNCTION, key);
	else return ret;
	return NULL;
}

comp_dict_item_t* query_stack_vector(comp_stack_t* stack, const char* key)
{
	comp_dict_item_t* ret = query_stack(stack, key, SIMBOLO_IDENTIFICADOR);
	if (ret == NULL || ret->type.base == AMA_INVALID)
		report_error(IKS_ERROR_UNDECLARED, key);
	else if (!ret->type.is_vector)
		report_error(IKS_ERROR_VARIABLE, key);
	else if (ret->type.is_function)
		report_error(IKS_ERROR_FUNCTION, key);
	else return ret;
	return NULL;
}

comp_dict_item_t* query_stack_function(comp_stack_t* stack, const char* key)
{
	comp_dict_item_t* ret = query_stack(stack, key, SIMBOLO_IDENTIFICADOR);
	if (ret == NULL || ret->type.base == AMA_INVALID)
		report_error(IKS_ERROR_UNDECLARED, key);
	else if (ret->type.is_vector)
		report_error(IKS_ERROR_VECTOR, key);
	else if (!ret->type.is_function)
		report_error(IKS_ERROR_VARIABLE, key);
	else return ret;
	return NULL;
}
