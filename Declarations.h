#ifndef DECLARATIONS
#define DECLARATIONS
#define HASH_DIFF_SIZE 60
#define HASH_POS_SIZE 10
#define HASH_TABLE_SIZE 5000
#define MAX_TEXT_SIZE 60
#define MAX_DOCUMENTS 100
typedef struct m {
    char file_name[MAX_TEXT_SIZE];
    char title[MAX_TEXT_SIZE];
} meta;
typedef struct d {
    char name[MAX_TEXT_SIZE];
    struct d * next;
} dmn;
typedef struct r {
    char text[MAX_TEXT_SIZE];
    int occurrences;
    dmn * domains;
    dmn * last_domain;
    char class[9];
    struct r * next;
} row;
row * symbols[MAX_DOCUMENTS][HASH_TABLE_SIZE];
void insert(char * entity, char * domain, char * question_class, int current_document);
int yyerror(char * message);
int yylex();
#endif