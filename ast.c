#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "ast.h"

struct node
{
    char* data_text;
    int num_nodes;
    int alocated_nodes;
    struct node **nodes;
};

AST* create_node(const char* data)
{
    AST* node = (AST*) malloc(sizeof(struct node));

    node->data_text = (char*) malloc(strlen(data) + 1);
    strcpy(node->data_text, data);

    node->num_nodes = 0;
    node->alocated_nodes = 0;
    node->nodes = NULL;
    return node;
}

void add_leaf(AST *node, AST *leaf)
{
	if(node->num_nodes >= node->alocated_nodes)
	{
      	node->nodes = realloc(node->nodes, sizeof(AST*) * ++(node->alocated_nodes));
      	node->nodes[node->num_nodes++] = leaf;
	}
    	else
		node->nodes[node->num_nodes++] = leaf;
}

AST* new_subtree(const char* data, int cnt_nodes, ...)
{
    int i;
    va_list nodes_list;

    AST *node = create_node(data);

    //Aloca memoria para os n nodes passados como parametros
    node->nodes = (AST**) malloc(sizeof(AST*) * cnt_nodes);

    node->alocated_nodes = cnt_nodes;

    va_start(nodes_list, cnt_nodes);

    for(i = 0; i < cnt_nodes; i++)
        add_leaf(node, va_arg(nodes_list, AST*));

    va_end(nodes_list);

    return node;
}

void print_node(AST *node, int level)
{
    int i;

    printf("%d: Node -- Addr: %p -- Text: %s -- Count: %d\n", level, node, node->data_text, node->num_nodes);

    for(i = 0; i < node->alocated_nodes; i++)
        print_node(node->nodes[i], level + 1);

}

void print_AST(AST *tree)
{
    print_node(tree, 0);
}

void free_tree(AST *tree)
{
    int i;

    if (tree != NULL)
    {
        for(i=0; i < tree->alocated_nodes; i++)
        {
            free_tree(tree->nodes[i]);
        }
        free(tree->data_text);
        free(tree->nodes);
        free(tree);
    }
}

// Dot output.

int nr;

int print_node_dot(AST *node)
{
    int my_nr = nr++;
    int i;

    printf("node%d[label=\"%s\"];\n", my_nr, node->data_text);

    for (i = 0; i < node->alocated_nodes; i++)
    {
        int child_nr = print_node_dot(node->nodes[i]);
        printf("node%d -> node%d;\n", my_nr, child_nr);
    }

    return my_nr;
}

void print_dot(AST *tree)
{
    nr = 0;
    printf("digraph {\ngraph [ordering=\"out\"];\n");
    print_node_dot(tree);
    printf("}\n");
}

// void node2str(DT *node, char *s)
// {
//     switch(node->kind)
//     {
//         case NUMBER_NODE: sprintf(s, "%d", node->data); break;
//         case PLUS_NODE:   sprintf(s, "%s", "+"); break;
//         case MINUS_NODE:  sprintf(s, "%s", "-"); break;
//         case TIMES_NODE:  sprintf(s, "%s", "*"); break;
//         case OVER_NODE:   sprintf(s, "%s", "/"); break;
//         default: printf("Invalid node kind: %d!\n", node->kind);
//     }
// }
