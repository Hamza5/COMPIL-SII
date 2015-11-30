%{
#include <stdio.h>
#include <string.h>
extern FILE * yyin;
extern unsigned short line, column;
extern unsigned short errors;
extern int yyleng;
int words_count = 0;
int questions_count = 0;
int wh1 = 0;
int wh2 = 0;
%}
%define api.value.type{char *}
%token DOCTYPE HTML_OPEN HTML_CLOSE HEAD_OPEN HEAD_CLOSE BODY_OPEN BODY_CLOSE META TITLE_OPEN TITLE_CLOSE MOT_CLE DIV_OPEN DIV_CLOSE TG_OPEN TG_CLOSE DOT MOT_SPECIAL H1_OPEN H1_CLOSE P_OPEN P_CLOSE SEMICOLON COMMA QUESTION_MARK EXCLAMATION_MARK Bloc_par_CLOSE Bloc_par_OPEN
%%
S : DOCTYPE HTML_OPEN head body HTML_CLOSE;
head : HEAD_OPEN head_content HEAD_CLOSE;
head_content : title MOT_CLE META | title META MOT_CLE | MOT_CLE META title | META MOT_CLE title |
                META title MOT_CLE | MOT_CLE title META; 
title : TITLE_OPEN title_content DOT TITLE_CLOSE;
title_content : MOT_SPECIAL { words_count++; } title_content | MOT_SPECIAL { if(words_count > 9){ errors++; fprintf(stderr, "Erreur : Plus de 10 mots dans le titre. ligne %d, colonne %d : %s\n", line, column - yyleng, yylval); } words_count = 0; };
body : BODY_OPEN body_content BODY_CLOSE;
body_content : div body_content | div;
div : DIV_OPEN tg bloc_par DIV_CLOSE;
tg : TG_OPEN mots_specials DOT TG_CLOSE { if(words_count > 10){ errors++; fprintf(stderr, "Erreur : Plus de 10 mots dans le titre. ligne %d, colonne %d : %s\n", line, column - yyleng, yylval); } words_count = 0; };
mots_specials : MOT_SPECIAL { words_count++; } mots_specials | MOT_SPECIAL { words_count++; };
bloc_par : Bloc_par_OPEN h1 paragraphs Bloc_par_CLOSE;
h1 : H1_OPEN mots_specials H1_CLOSE;
paragraphs : p paragraphs | p;
p : P_OPEN p_content P_CLOSE { if(words_count > 100){ errors++; fprintf(stderr, "Erreur : Plus de 100 mots dans le paragraphe. ligne %d, colonne %d : %s\n", line, column - yyleng, yylval); } words_count = 0; if(!questions_count){ errors++; fprintf(stderr, "Erreur : Paragraphe sans Wh questions. ligne %d, colonne %d : %s\n", line, column - yyleng, yylval); } questions_count = 0; };
p_content : MOT_SPECIAL { words_count++; if(!strcmp(yylval, "Who") || !strcmp(yylval, "Where") || !strcmp(yylval, "When")){ wh1 = wh2 = 1; } else if(!strcmp(yylval, "How")) wh1 = 1; else if(!strcmp(yylval, "many")) wh2 = 1; } p_content | ponctuation p_content | DOT;
ponctuation : COMMA | SEMICOLON | EXCLAMATION_MARK | QUESTION_MARK { if(wh1 && wh2){ questions_count++; wh1 = 0; wh2 = 0;} } | DOT;
%%
int yyerror(char * message){
	errors++;
	printf("Erreur : ligne %u colonne %u : %s\n", line, column - yyleng, yylval);
	return 1;
}
int main(int argc, char * argv[]){
    if(argc > 1){
        int i;
        for(i=1; i<argc; i++){
            printf("\nAnalyse du fichier %s\n", argv[i]);
            yyin = fopen(argv[i],"r");
            yyparse();
            if(!errors){
                printf("Analyse terminée. Aucune erreur n'est trouvée.\n");
            } else {
                char s = errors > 1 ? 's' : '\0';
                printf("Analyse échouée. %d erreur%c trouvée%c\n", errors, s, s);
            }
            printf("\n");
        }
    }
    else printf("Usage : %s <Chemin_du_fichier_1> [<Chemin_du_fichier_i> ...]\n", argv[0]);
    return 0;
}
