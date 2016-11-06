#ifndef AST_H
#define AST_H

typedef enum
{
    PROGRAM_NODE,
    FUNC_LIST_NODE,
    FUNC_DECL_NODE,
    FUNC_HEADER_NODE,
    FUNC_BODY_NODE,
    VAR_LIST_NODE,
    BLOCK_NODE,
    PARAM_LIST_NODE,
    PARAM_NODE,
    ASSIGN_NODE,
    IF_NODE,
    WHILE_NODE,
    RETURN_NODE,
    WRITE_NODE,
    FUNC_CALL_NODE,
    ARG_LIST_NODE,
    VAR_DECL_NODE,
    LVAL_NODE,
} NodeKind;

struct node; // Opaque structure to ensure encapsulation.

typedef struct node AST;

AST* create_node(const char* data);
void setPos_AST(AST *node, int p);

void setPos(AST* node, int pos);
int getPos(AST* node);
char* getName(AST* node);

void add_leaf(AST *node, AST *leaf);
AST* new_subtree(const char* data, int cnt_nodes, ...);

void print_node(AST *node, int level);
void print_AST(AST *tree);

void free_tree(AST *tree);

int print_node_dot(AST *node);
void print_dot(AST *tree);

#endif //END_AST_NODE
