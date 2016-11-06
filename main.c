#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

int main()
{
    AST *tree = new_subtree("Pai", 6, new_subtree(("teste"), 2, create_node("t1"), create_node("t2")), create_node("f1"), create_node("f2"), create_node("f3"), create_node("f4"), create_node("f5"));

    print_AST(tree);

    printf("%lu\n", strlen("trabalho"));
    free_tree(tree);

    return 0;

}
