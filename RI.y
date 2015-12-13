%{
#include <stdio.h>
#include<stdlib.h>
#include <string.h>
#include "Declarations.h"
extern FILE * yyin;
extern unsigned short line;
extern unsigned short column;
extern unsigned short errors;
extern int yyleng;
int words_count = 0;
extern char title[150];
extern int questions_count;
extern char * domain;
int current_document;
dmn * search_domain(dmn * domains, char * domain){
    while(domains != NULL){
        if(!strcmp(domain, domains->name)) return domains;
        domains = domains->next;
    }
    return NULL;
}
int hash_small(char * text){
    int idf = 0;
    int i;
    for(i=0; i<strlen(text); i++){
        idf += text[i]%HASH_DIFF_SIZE * (i%HASH_POS_SIZE+1);
    }
    return idf%HASH_TABLE_SIZE;
}
int search(char * entity, int current_document){
    int r = hash_small(entity);
    if(r < HASH_TABLE_SIZE){
        row * question;
        for(question = symbols[current_document][r]; question != NULL; question = question->next){
            if(!strcmp(entity, question->text)){ return r;}
        }
    }
    return -1;
}
int occurrences(char * question){
    int c = 0;
    int i;
    for(i=0; i<MAX_DOCUMENTS; i++){
        if(symbols[i] != NULL){
            int j;
            for(j=0; j<HASH_TABLE_SIZE; j++){
                row * k;
                for(k=symbols[i][j]; k!=NULL; k=k->next){
                    if(!strcmp(question, symbols[i][j]->text)) c++;
                }
            }
        }
    }
    return c;
}
dmn * all_domains(char * question){
    dmn * domains = NULL;
    dmn * last_domain = domains;
    int i;
    for(i=0; i<MAX_DOCUMENTS; i++){
        if(symbols[i] != NULL){
            int j;
            for(j=0; j<HASH_TABLE_SIZE; j++){
                row * k;
                for(k=symbols[i][j]; k!=NULL; k=k->next){
                    if(!strcmp(question, k->text)){
                        if(domains == NULL){ // Cas de la tête des domaines
                            domains = malloc(sizeof(dmn)); // Traitement de la tête des domaines de chaque question
                            strcpy(domains->name, k->domains->name);
                            domains->next = NULL;
                            last_domain = domains;
                            dmn * current_domain;
                            for(current_domain=k->domains->next; current_domain!=NULL; current_domain=current_domain->next){ // Traitement de tous le reste
                                last_domain->next = malloc(sizeof(dmn));
                                last_domain = last_domain->next;
                                strcpy(last_domain->name, current_domain->name);
                                last_domain->next = NULL;
                            }
                        } else {
                            dmn * current_domain;
                            for(current_domain=k->domains; current_domain!=NULL; current_domain=current_domain->next)
                                if(search_domain(domains, current_domain->name) == NULL){
                                    last_domain->next = malloc(sizeof(dmn));
                                    last_domain = last_domain->next;
                                    strcpy(last_domain->name, current_domain->name);
                                    last_domain->next = NULL;
                                }
                        }
                    }
                }
            }
        }
    }
    return domains;
}
void insert(char * entity, char * domain, char * question_class, int current_document){
    int r = hash_small(entity);
    if(r >= HASH_TABLE_SIZE) fprintf(stderr, "Erreur : la taille de la table de hashage est insuffisante pour insérer l'entitée '%s' !\n",entity);
    else if(symbols[current_document][r] == NULL){
        symbols[current_document][r] = malloc(sizeof(row));
        strcpy(symbols[current_document][r]->text, entity);
        symbols[current_document][r]->occurrences = 1;
        symbols[current_document][r]->domains = malloc(sizeof(dmn));
        strcpy(symbols[current_document][r]->domains->name, domain);
        symbols[current_document][r]->domains->next = NULL;
        symbols[current_document][r]->last_domain = symbols[current_document][r]->domains;
        strcpy(symbols[current_document][r]->class, question_class);
        symbols[current_document][r]->next = NULL;
    } else {
        if(strcmp(symbols[current_document][r]->text, entity)){
            symbols[current_document][r]->occurrences++;
            if(search_domain(symbols[current_document][r]->domains, domain) == NULL){
                symbols[current_document][r]->last_domain->next = malloc(sizeof(dmn));
                symbols[current_document][r]->last_domain = symbols[current_document][r]->last_domain->next;
                strcpy(symbols[current_document][r]->last_domain->name, domain);
                symbols[current_document][r]->last_domain->next = NULL;
            }
        } else {
            row * question = symbols[current_document][r];
            while(question->next != NULL){
                if(!strcmp(question->text, entity)){
                    break;
                }
                question = question->next;
            }
            if(!strcmp(question->text, entity)) question->occurrences++;
            if(search_domain(question->domains, domain) == NULL){
                question->last_domain->next = malloc(sizeof(dmn));
                question->last_domain = question->last_domain->next;
                strcpy(question->last_domain->name, domain);
                question->last_domain->next = NULL;
            }
        }
    }
}
int empty(int document){
    int i;
    for(i=0; i<HASH_TABLE_SIZE; i++){
        if(symbols[document][i] != NULL){
            row * question;
            row * p;
            for(question = symbols[document][i]; question != NULL; p = question, question = question->next, free(p)){
                dmn * j;
                dmn * q;
                for(j=question->domains; j!=NULL; q = j, j=j->next, free(q));
            }
            symbols[document][i] = NULL;
        }
    }
}
void show(int current_document){
    if(symbols[current_document] != NULL){
        printf("\n");
        int i;
        for(i=0; i<(4+1+8+1+2*MAX_TEXT_SIZE+2+11+1); i++) printf("-");
        printf("\n%-4s|%-60s|%-8s|%-60s|%s|\n", "ID", "Question", "Classe", "Domaines", "Occurrences");
        int k;
        for(k=0; k<(4+1+8+1+2*MAX_TEXT_SIZE+2+11+1); k++) printf("-");
        printf("\n");
        for(i=0; i<HASH_TABLE_SIZE; i++){
            if(symbols[current_document][i] != NULL){
                row * question;
                for(question = symbols[current_document][i]; question != NULL; question = question->next){
                    char domains_buffer[MAX_TEXT_SIZE] = "";
                    dmn * j;
                    for(j=question->domains; j!=NULL; j=j->next){
                        strcat(domains_buffer, j->name);
                        strcat(domains_buffer, ",");
                    }
                    domains_buffer[strlen(domains_buffer)-1] = '.';
                    printf("%04d|%-60s|%-8s|%-60s|%11d|\n", i, question->text, question->class, domains_buffer, question->occurrences);
                    for(k=0; k<(4+1+8+1+2*MAX_TEXT_SIZE+2+11+1); k++) printf("-");
                    printf("\n");
                }
            }
        }
    }
}
void write(char * filename){
    FILE * index = fopen(filename,"w");
    int j;
    for(j=0; j<MAX_DOCUMENTS; j++){
        int i;
        if(symbols[j] != NULL)
            for(i=0; i<HASH_TABLE_SIZE; i++){
                if(symbols[j][i] != NULL){
                    row * question;
                    for(question = symbols[j][i]; question != NULL; question = question->next){
                        char domains_buffer[MAX_TEXT_SIZE] = "";
                        dmn * j;
                        for(j=all_domains(question->text); j!=NULL; j=j->next){
                            strcat(domains_buffer, j->name);
                            strcat(domains_buffer, ",");
                        }
                        domains_buffer[strlen(domains_buffer)-1] = '\0';
                        fprintf(index, "%s|%s|%s|%d|\n", question->text, question->class, domains_buffer, occurrences(question->text));
                    }
                }
            }
    }
    fclose(index);
}
void read(char * filename, int document){
    FILE * index = fopen(filename,"r");
    char * line = NULL;
    size_t length = 0;
    empty(document);
    while(getline(&line, &length, index) > 0){
        char * question = strtok(line, "|");
        char * class = strtok(NULL, "|");
        char * domain = strtok(NULL, "|");
        insert(question, domain, class, document);
    }
    fclose(index);
}
int yyerror(char * message);
int yylex();
%}
%define api.value.type{char *}
%token DOCTYPE HTML_OPEN HTML_CLOSE HEAD_OPEN HEAD_CLOSE BODY_OPEN BODY_CLOSE META TITLE_OPEN TITLE_CLOSE MOT_CLE DIV_OPEN DIV_CLOSE TG_OPEN TG_CLOSE DOT SPECIAL H1_OPEN H1_CLOSE P_OPEN P_CLOSE SEMICOLON COMMA QUESTION_MARK EXCLAMATION_MARK Bloc_par_CLOSE Bloc_par_OPEN MOT
%%
S : DOCTYPE HTML_OPEN head body HTML_CLOSE;
head : HEAD_OPEN head_content HEAD_CLOSE;
head_content : title MOT_CLE META | title META MOT_CLE | MOT_CLE META title | META MOT_CLE title |
                META title MOT_CLE | MOT_CLE title META; 
title : TITLE_OPEN title_content DOT TITLE_CLOSE;
title_content : MOT { words_count++; } title_content | MOT { if(words_count > 9){ errors++; fprintf(stderr, "Erreur : Plus de 10 mots dans le titre du document. Document %s, ligne %d, colonne %d : %s\n", title, line, column - yyleng, yylval); YYABORT; } words_count = 0; };
body : BODY_OPEN body_content BODY_CLOSE;
body_content : div body_content | div;
div : DIV_OPEN tg bloc_par DIV_CLOSE;
tg : TG_OPEN mots_specials DOT TG_CLOSE { if(words_count > 10){ errors++; fprintf(stderr, "Erreur : Plus de 10 mots dans le titre global. Document %s, ligne %d, colonne %d : %s\n", title, line, column - yyleng, yylval); YYABORT; } words_count = 0; };
mots_specials : MOT { words_count++; } mots_specials | MOT { words_count++; } | SPECIAL mots_specials | SPECIAL;
bloc_par : Bloc_par_OPEN h1 paragraphs Bloc_par_CLOSE;
h1 : H1_OPEN mots_specials H1_CLOSE;
paragraphs : p paragraphs | p;
p : P_OPEN p_content P_CLOSE { if(words_count > 100){ errors++; fprintf(stderr, "Erreur : Plus de 100 mots dans le paragraphe. Document %s ligne %d, colonne %d : %s\n", title, line, column - yyleng, yylval); YYABORT; } words_count = 0; if(!questions_count){ errors++; fprintf(stderr, "Erreur : Paragraphe sans Wh questions. Document %s ligne %d, colonne %d : %s\n", title, line, column - yyleng, yylval); YYABORT; } questions_count = 0; };
p_content : MOT { words_count++; } p_content | SPECIAL p_content | ponctuation p_content | DOT;
ponctuation : COMMA | SEMICOLON | EXCLAMATION_MARK | QUESTION_MARK | DOT;
%%
int yyerror(char * message){
	errors++;
	fprintf(stderr, "Erreur : Document '%s', ligne %u, colonne %u : %s\n", title, line, column - yyleng, yylval);
	return 1;
}
int main(int argc, char * argv[]){
    if(argc > 1){
        int i;
        for(i=0; i<MAX_DOCUMENTS; i++){
            int j;
            for(j=0; j<HASH_TABLE_SIZE; j++) symbols[i][j] = NULL; // Vider les tables de symbols
        }
        for(current_document=0; current_document<argc-1; current_document++){
            line = 1;
            column = 1;
            errors = 0;
            printf("\nAnalyse du fichier %s\n", argv[current_document+1]);
            yyin = fopen(argv[current_document+1],"r");
            yyparse();
            while(yylex());
            fclose(yyin);
            if(!errors){
                printf("Analyse terminée. Aucune erreur n'est trouvée dans le document '%s'\n", title);
                show(current_document);
            } else {
                char s = errors > 1 ? 's' : '\0';
                printf("Analyse échouée. %d erreur%c trouvée%c dans le document '%s'\n", errors, s, s, title);
                empty(current_document);
            }
            printf("\n");
        }
        write("index.txt");
        //read("index.txt", current_document);
    }
    else printf("Usage : %s <Chemin_du_fichier_1> [<Chemin_du_fichier_i> ...]\n", argv[0]);
    return 0;
}
