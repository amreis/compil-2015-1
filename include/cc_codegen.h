#ifndef CODEGEN_H
#define CODEGEN_H

#include <stdlib.h>
#include <stdio.h>

#include "cc_tree.h"
#include "cc_ast.h"
#include "cc_list.h"

comp_list_t* gen_code(comp_tree_t* node);

#endif
