%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>
#include "RI.tab.h"
unsigned short line = 1;
unsigned short column = 1;
unsigned short errors = 0;
extern YYSTYPE yylval;
extern void insert(char * entity, char * domain, char * question_class, int current_document);
char title[150] = "";
int inTitle = 0;
int inParagraph = 0;
char question[200] = "";
int wh1 = 0;
int wh2 = 0;
int how_diff = 0;
int questions_count = 0;
char * domain;
char * class;
extern int current_document;
%}
DOCTYPE "<!DOCTYPE HTML>"
HTML_OPEN "<"[ \t]*"HTML"[ \t]*">"
HTML_CLOSE "<"[ \t]*"/"[ \t]*"HTML"[ \t]*">"
HEAD_OPEN "<"[ \t]*"HEAD"[ \t]*">"
HEAD_CLOSE "<"[ \t]*"/"[ \t]*"HEAD"[ \t]*">"
BODY_OPEN "<"[ \t]*"BODY"[ \t]*">"
BODY_CLOSE "<"[ \t]*"/"[ \t]*"BODY"[ \t]*">"
TITLE_OPEN "<"[ \t]*"TITLE"[ \t]*">"
TITLE_CLOSE "<"[ \t]*"/TITLE"[ \t]*">"
MOT_CLE "<"[ \t]*"MOTS-CLE"[ \t]*"value"[ \t]*"="[ \t]*["']([a-zA-Z\-\ ]{1,50}\|)*[a-zA-Z\-\ ]{1,50}["'][ \t]*"/"[ \t]*">"
COMMENT "<!--".*"-->"
DIV_OPEN "<"[ \t]*"DIV"[ \t]*">"
DIV_CLOSE "<"[ \t]*"/"[ \t]*"DIV"[ \t]*">"
TG_OPEN "<"[ \t]*"TG"[ \t]*">"
TG_CLOSE "<"[ \t]*"/"[ \t]*"TG"[ \t]*">"
Bloc_par_OPEN "<"[ \t]*"Bloc_par"[ \t]*">"
Bloc_par_CLOSE "<"[ \t]*"/"[ \t]*"Bloc_par"[ \t]*">"
H1_OPEN "<"[ \t]*"h1"[ \t]*">"
H1_CLOSE "<"[ \t]*"/"[ \t]*"h1"[ \t]*">"
P_OPEN "<"[ \t]*"p"[ \t]*">"
P_CLOSE "<"[ \t]*"/"[ \t]*"p"[ \t]*">"
MOT [a-zA-Z0-9\']{1,10}
SPECIAL [\&\@\#\$]+
NOM [A-Z][a-z]+
META "<"[ \t]*"META"[ \t]*"auteur"s?[ \t]*"="[ \t]*["'](({NOM}[ ])+{NOM}[ ]?,[ ]?)*({NOM}[ ])+{NOM}["'][ \t]*"domaine"[ \t]*"="[ \t]*["']([a-zA-Z0-9\-]+[ ]){0,2}[a-zA-Z0-9\-]+["'][ \t]*"/"[ \t]*">"
QUESTION_MARK "?"
EXCLAMATION_MARK "!"
DOT "."
SEMICOLON ";"
COMMA ","
ERROR [a-zA-Z0-9]+|.
%%
{DOCTYPE} {
    column += yyleng;
    yylval = yytext;
    return DOCTYPE;
}
{HTML_OPEN} {
    column += yyleng;
    yylval = yytext;
    return HTML_OPEN;
}
{HTML_CLOSE} {
    column += yyleng;
    yylval = yytext;
    return HTML_CLOSE;
}
{HEAD_OPEN} {
    column += yyleng;
    yylval = yytext;
    return HEAD_OPEN;
}
{HEAD_CLOSE} {
    column += yyleng;
    yylval = yytext;
    return HEAD_CLOSE;
}
{BODY_OPEN} {
    column += yyleng;
    yylval = yytext;
    return BODY_OPEN;
}
{BODY_CLOSE} {
    column += yyleng;
    yylval = yytext;
    return BODY_CLOSE;
}
{TITLE_OPEN} {
    column += yyleng;
    yylval = yytext;
    inTitle = 1;
    title[0] = '\0';
    return TITLE_OPEN;
}
{TITLE_CLOSE} {
    column += yyleng;
    yylval = yytext;
    inTitle = 0;
    return TITLE_CLOSE;
}
{MOT_CLE} {
    column += yyleng;
    yylval = yytext;
    return MOT_CLE;
}
{META} {
    regex_t re;
    regcomp(&re, "domaine[ \t]*=[ \t]*[\"\'](.+)[\"\']", REG_EXTENDED);
    regmatch_t results[2];
    regexec(&re, yytext, 2, results, 0);
    domain = strndup(yytext+results[1].rm_so, (results[1].rm_eo - results[1].rm_so));
    column += yyleng;
    return META;
}
{DIV_OPEN} {
    column += yyleng;
    return DIV_OPEN;
}
{DIV_CLOSE} {
    column += yyleng;
    return DIV_CLOSE;
}
{TG_OPEN} {
    column += yyleng;
    return TG_OPEN;
}
{TG_CLOSE} {
    column += yyleng;
    return TG_CLOSE;
}
{Bloc_par_OPEN} {
    column += yyleng;
    return Bloc_par_OPEN;
}
{Bloc_par_CLOSE} {
    column += yyleng;
    return Bloc_par_CLOSE;
}
{H1_OPEN} {
    column += yyleng;
    return H1_OPEN;
}
{H1_CLOSE} {
    column += yyleng;
    return H1_CLOSE;
}
{P_OPEN} {
    column += yyleng;
    inParagraph = 1;
    return P_OPEN;
}
{P_CLOSE} {
    column += yyleng;
    inParagraph = 0;
    return P_CLOSE;
}
{COMMENT} {
    column += yyleng;
}
\n {
    line++;
    column = 1;
}
" "|\t {
    column++;
}
{MOT} {
    column += yyleng;
    yylval = yytext;
    if(inTitle) { strcat(title, yylval); strcat(title, " "); }
    else if(inParagraph) {
        if(!strcmp(yylval, "Who") || !strcmp(yylval, "Where") || !strcmp(yylval, "When")){
            strcat(question, yylval);
            strcat(question, " ");
            wh1 = wh2 = 1;
            class = strdup(yylval);
        } else if(!strcmp(yylval, "How")){
            strcat(question, yylval);
            strcat(question, " ");
            wh1 = 1;
            how_diff = 0;
        } else if (wh1 && !strcmp(yylval, "many")){
            if(how_diff == 1){
                strcat(question, yylval);
                strcat(question, " ");
                wh2 = 1;
                class = "How many";
            } else {
                question[0] = '\0';
            }
        } else if(wh1 && wh2){
            strcat(question, yylval);
            strcat(question, " ");
        }
        how_diff++;
    }
    return MOT;
}
{SPECIAL} {
    column += yyleng;
    yylval = yytext;
    if(wh1 && wh2){
        strcat(question, yylval);
        strcat(question, " ");
    }
    return SPECIAL;
}
{DOT} {
    column += yyleng;
    return DOT;
}
{SEMICOLON} {
    column += yyleng;
    return SEMICOLON;
}
{COMMA} {
    column += yyleng;
    return COMMA;
}
{QUESTION_MARK} {
    column += yyleng;
    if(wh1 && wh2){
        strcat(question, "?");
        questions_count++;
        insert(question, domain, class, current_document);
        question[0] = '\0';
        wh1 = 0;
        wh2 = 0;
    }
    return QUESTION_MARK;
}
{EXCLAMATION_MARK} {
    column += yyleng;
    return EXCLAMATION_MARK;
}
{ERROR} {
    errors++;
    fprintf(stderr, "Erreur : Entitée non reconnue - Document %s, ligne %d, colonne %d : %s\n", title, line, column, yytext);
    column += yyleng;
}
%%
int yywrap(){ return 1; }
