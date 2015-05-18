#include "cc_codegen.h"

unsigned int next_reg = 0;

void gera_reg(char* out)
{
    sprintf(out, "r%d", next_reg++);
    return;
}

comp_list_t* gen_literal(comp_tree_t* node)
{
    char reg[20], instr[100];
    gera_reg(reg);
    comp_list_t* list = new_list();

    if (node->value->token_type == SIMBOLO_LITERAL_INT ||
        node->value->token_type == SIMBOLO_LITERAL_FLOAT)
    {
        sprintf(instr, "loadI %d => %s", node->value->token_val.int_val, reg);
    }
    else if (node->value->token_type == SIMBOLO_LITERAL_BOOL)
    {
        sprintf(instr, "loadI %d => %s", node->value->token_val.bool_val, reg);
    }
    else
    {
        return NULL;
    }
    fprintf(stderr, "%s\n", instr);
    comp_list_item_t* i = new_list_item_valued(instr);
    list = append_instr(list, i);
    node->code = list;
    node->reg_result = strdup(reg);
    return list;
}

comp_list_t* gen_arim_binaria(comp_tree_t* node)
{
    char reg[20], instr[100];
    if (node->child[0] == NULL || node->child[1] == NULL)
        return NULL;
    strcpy(reg, node->child[0]->reg_result);
    char *reg_dir = node->child[1]->reg_result;
    switch (node->type)
    {
        case AST_ARIM_SOMA:
        sprintf(instr, "add %s, %s => %s", reg, reg_dir, reg);
        break;
        case AST_ARIM_SUBTRACAO:
        sprintf(instr, "sub %s, %s => %s", reg, reg_dir, reg);
        break;
        case AST_ARIM_MULTIPLICACAO:
        sprintf(instr, "mul %s, %s => %s", reg, reg_dir, reg);
        break;
        case AST_ARIM_DIVISAO:
        sprintf(instr, "div %s, %s => %s", reg, reg_dir, reg);
    }
    concat_list(node->child[0]->code, node->child[1]->code);
    comp_list_item_t* i = new_list_item_valued(instr);
    node->code = node->child[0]->code;
    append_instr(node->code, i);
    node->reg_result = strdup(reg);
    fprintf(stderr, "%s\n", instr);
    return node->code;
}

comp_list_t* gen_atribuicao(comp_tree_t* node)
{
    if (node->child[0] == NULL || node->child[1] == NULL)
        return NULL;
    char instr[100];
    if (node->child[0]->value->addr.scope == SCOPE_GLOBAL)
        sprintf(instr, "storeAI %s => rbss, %d", node->child[1]->reg_result, node->child[0]->value->addr.offset);
    else {
        // TODO IMPLEMENT
    }
    append_instr(node->child[1]->code, new_list_item_valued(instr));
    node->code = node->child[1]->code;
    node->reg_result = NULL;
    fprintf(stderr, "%s\n", instr);
    return node->code;
}
comp_list_t* gen_identificador(comp_tree_t* node)
{
    char reg[20], instr[100];
    gera_reg(reg);
    if (node->value->addr.scope == SCOPE_GLOBAL)
    {
        sprintf(instr, "loadAI rbss, %d => %s", node->value->addr.offset, reg);
    } else {
        // TODO IMPLEMENT
    }
    fprintf(stderr, "%s\n", instr);
    comp_list_t* list = new_list();
    list = append_instr(list, new_list_item_valued(instr));
    node->code = list;
    node->reg_result = strdup(reg);
    return list;
}



comp_list_t* gen_code(comp_tree_t* node)
{
    switch(node->type)
    {
        case AST_LITERAL:
            return gen_literal(node);
        case AST_ARIM_SOMA:
        case AST_ARIM_SUBTRACAO:
        case AST_ARIM_MULTIPLICACAO:
        case AST_ARIM_DIVISAO:
            return gen_arim_binaria(node);
        case AST_ARIM_INVERSAO:
            // return gen_arim_unaria(node);
        case AST_LOGICO_COMP_DIF:
        case AST_LOGICO_COMP_IGUAL:
        case AST_LOGICO_COMP_LE:
        case AST_LOGICO_COMP_GE:
        case AST_LOGICO_COMP_L:
        case AST_LOGICO_COMP_G:
            //return gen_logic_comp(node);
        case AST_LOGICO_E:
        case AST_LOGICO_OU:
            //return gen_logic_binaria(node);
        case AST_LOGICO_COMP_NEGACAO:
            //return gen_logic_unaria(node);
        case AST_IDENTIFICADOR:
            return gen_identificador(node);
        case AST_ATRIBUICAO:
            return gen_atribuicao(node);
        default:
            return NULL;
    }
}
