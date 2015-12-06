%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "RI.tab.h"
unsigned short line = 1;
unsigned short column = 1;
unsigned short errors = 0;
extern YYSTYPE yylval;
extern void insert(char * entity);
char title[150] = "";
int inTitle = 0;
int inParagraph = 0;
char question[200] = "";
int wh1 = 0;
int wh2 = 0;
int questions_count = 0;
%}
DOCTYPE "<!DOCTYPE HTML>"
HTML_OPEN "<HTML>"
HTML_CLOSE "</HTML>"
HEAD_OPEN "<HEAD>"
HEAD_CLOSE "</HEAD>"
BODY_OPEN "<BODY>"
BODY_CLOSE "</BODY>"
TITLE_OPEN "<TITLE>"
TITLE_CLOSE "</TITLE>"
MOT_CLE "<MOTS-CLE value="["']([a-zA-Z\-\ ]{1,50}\|)*[a-zA-Z\-\ ]{1,50}["']"/>"
COMMENT "<!--".*"-->"
DIV_OPEN "<DIV>"
DIV_CLOSE "</DIV>"
TG_OPEN "<TG>"
TG_CLOSE "</TG>"
Bloc_par_OPEN "<Bloc_par>"
Bloc_par_CLOSE "</Bloc_par>"
H1_OPEN "<h1>"
H1_CLOSE "</h1>"
P_OPEN "<p>"
P_CLOSE "</p>"
MOT [a-zA-Z0-9]{1,10}
SPECIAL [\&\@\%µ\$éèêâîù_ç\/\#\~\-]+
NOM [A-Z][a-z]+
META "<META auteurs="["'](({NOM}[ ])+{NOM}[ ]?,[ ]?)*({NOM}[ ])+{NOM}["']" domaine="["']([a-zA-Z0-9\-]+[ ]){0,2}[a-zA-Z0-9\-]+["']"/>"
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
        } else if(!strcmp(yylval, "How")){
            strcat(question, yylval);
            strcat(question, " ");
            wh1 = 1;
        } else if (wh1 && !strcmp(yylval, "many")){
            strcat(question, yylval);
            strcat(question, " ");
            wh2 = 1;
        } else if(wh1 && wh2){
            strcat(question, yylval);
            strcat(question, " ");
        }
    }
    return MOT;
}
{SPECIAL} {
    column += yyleng;
    yylval = yytext;
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
        insert(question);
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
