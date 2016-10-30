#ifndef AST_H
#define AST_H

typedef enum
{
    PROGRAM_NODE,
    STMT_SEQUENCE_NODE,
    STMT_NODE,
    IF_STMT_NODE,
    REPEAT_STMT_NODE,
    ASSIGN_STMT_NODE,
    READ_STMT_NODE,
    WRITE_STMT_NODE,
    EXPR_NODE,
    LPAREN_NODE,
    RPAREN_NODE,
    IF_NODE,
    THEN_NODE,
    ELSE_NODE,
    END_NODE,
    REPEAT_NODE,
    UNTIL_NODE,
    READ_NODE,
    WRITE_NODE,
    EQ_NODE,
    LT_NODE,
    ASSIGN_NODE,
    SEMI_NODE,
    IDENTIFIER_NODE,
    NUMBER_NODE,
    PLUS_NODE,
    MINUS_NODE,
    TIMES_NODE,
    OVER_NODE
} NodeKind;

// const char* STRING_NODEKIND[] =
// {
//     "PROGRAM_NODE",
//     "STMT_SEQUENCE_NODE",
//     "STMT_NODE",
//     "IF_STMT_NODE",
//     "REPEAT_STMT_NODE",
//     "ASSIGN_STMT_NODE",
//     "READ_STMT_NODE",
//     "WRITE_STMT_NODE",
//     "EXPR_NODE",
//     "LPAREN_NODE",
//     "RPAREN_NODE",
//     "IF_NODE",
//     "THEN_NODE",
//     "ELSE_NODE",
//     "END_NODE",
//     "REPEAT_NODE",
//     "UNTIL_NODE",
//     "READ_NODE",
//     "WRITE_NODE",
//     "EQ_NODE",
//     "LT_NODE",
//     "ASSIGN_NODE",
//     "SEMI_NODE",
//     "IDENTIFIER_NODE",
//     "NUMBER_NODE",
//     "PLUS_NODE",
//     "MINUS_NODE",
//     "TIMES_NODE",
//     "OVER_NODE"
// };

struct node; // Opaque structure to ensure encapsulation.

typedef struct node AST;

AST* create_node(const char* data);
void add_leaf(AST *node, AST *leaf);
AST* new_subtree(const char* data, int cnt_nodes, ...);

void print_node(AST *node, int level);
void print_AST(AST *tree);

void free_tree(AST *tree);

int print_node_dot(AST *node);
void print_dot(AST *tree);

#endif //END_AST_NODE
