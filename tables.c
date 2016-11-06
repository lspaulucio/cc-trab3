#include "tables.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

////////////////////////////// LITERALS TABLE //////////////////////////////////

struct lit_table
{
    char *lit_name;
    struct lit_table *next;
};

LitTable* create_lit_table()
{
    LitTable *lit = (LitTable*) malloc(sizeof(struct lit_table));
    lit->lit_name = NULL;
    lit->next = NULL;
    return lit;
}

// Adds the given string to the table without repetitions.
// String 's' is copied internally.
// Returns the index of the string in the table.
int add_literal(LitTable* lt, char* s)
{
    int i = 0;

    if(lt->lit_name == NULL)
    {
        lt->lit_name = malloc(sizeof(s) + 1);
        strcpy(lt->lit_name, s);
        return i;
    }

    while(lt->next != NULL)
    {
        if(strcmp(lt->lit_name, s) == 0)
            return i;

        i++;
        lt = lt->next;
    }

    i++;
    lt->next = create_lit_table();
    lt = lt->next;
    lt->lit_name = malloc(sizeof(s) + 1);
    strcpy(lt->lit_name, s);
    return i;
}

// Returns a pointer to the string stored at index 'i'.
char* get_literal(LitTable* lt, int i)
{
    int pos = 0;

    while(pos++ != i || lt != NULL)
    {
        lt = lt->next;
    }

    return lt->lit_name;
}

// Prints the given table to stdout.
void print_lit_table(LitTable* lt)
{
    int i = 0;
    printf("Literal Table:\n");
    while(lt != NULL)
    {
        printf("%s: %d\n", lt->lit_name, i++);
        lt = lt->next;
    }
}

// Clear the allocated structure.
void free_lit_table(LitTable* lt)
{
    LitTable *n;

    while(lt != NULL)
    {
        n = lt->next;
        free(lt->lit_name);
        free(lt);
        lt = n;
    }
}

///////////////////////////////// SYMBOLS TABLE ////////////////////////////////

// This table only stores the variable name and the declaration line.
struct sym_table
{
    char* sym_name;
    int line;
    struct sym_table *next;
};

// Creates an empty symbol table.
SymTable* create_sym_table()
{
    SymTable *sym = (SymTable*) malloc(sizeof(struct sym_table));
    sym->sym_name = NULL;
    sym->next = NULL;
    sym->line = -1;

    return sym;
}

// Adds a fresh var to the table.
// No check is made by this function, so make sure to call 'lookup_var' first.
// Returns the index where the variable was inserted.
int add_var(SymTable* st, char* s, int line)
{
    int i = 0;

    if(st->sym_name == NULL)
    {
        st->sym_name = malloc(sizeof(s) + 1);
        strcpy(st->sym_name, s);
        st->line = line;
        return i;
    }

    while(st->next != NULL)
    {
        if(strcmp(st->sym_name, s) == 0)
            return i;

        i++;
        st = st->next;
    }

    i++;
    st->next = create_sym_table();
    st = st->next;
    st->sym_name = malloc(sizeof(s) + 1);
    strcpy(st->sym_name, s);
    st->line = line;
    return i;
}

// Returns the index where the given variable is stored or -1 otherwise.
int lookup_var(SymTable* st, char* s)
{
    int i = 0;

    while(st != NULL)
    {
        if(strcmp(st->sym_name, s) == 0)
        {
            return i;
        }

        i++;
        st = st->next;
    }

    return -1;
}

// Returns the variable name stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
char* get_name(SymTable* st, int i)
{
    int pos = 0;

    while(pos++ != i || st != NULL)
    {
        st = st->next;
    }

    return st->sym_name;
}

// Returns the declaration line of the variable stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_line(SymTable* st, int i)
{
    int pos = 0;

    while(pos++ != i || st != NULL)
    {
        st = st->next;
    }

    return st->line;
}

// Prints the given table to stdout.
void print_sym_table(SymTable* st)
{
    printf("Symbols Table:\n");
    while(st != NULL)
    {
        printf("%s: %d\n", st->sym_name, st->line);
        st = st->next;
    }
}

// Clear the allocated structure.
void free_sym_table(SymTable* st)
{
    SymTable *n;

    while(st != NULL)
    {
        n = st->next;
        free(st->sym_name);
        free(st);
        st = n;
    }
}
