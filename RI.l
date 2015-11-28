%{
#include <stdio.h>
#include <stdlib.h>
#include "RI.tab.h"
unsigned short line = 1;
unsigned short column = 1;
unsigned short errors = 0;
extern YYSTYPE yylval;
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
MOT_SPECIAL [a-zA-Z0-9&@%µ$éèêâîù_ç/#~\-]+
NOM [A-Z][a-z]+
META "<META auteurs="["'](({NOM}[ ])+{NOM}[ ]?,[ ]?)*({NOM}[ ])+{NOM}["']" domaine="["']({MOT_SPECIAL}[ ]){0,2}{MOT_SPECIAL}["']"/>"
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
    return TITLE_OPEN;
}
{TITLE_CLOSE} {
    column += yyleng;
    yylval = yytext;
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
    return P_OPEN;
}
{P_CLOSE} {
    column += yyleng;
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
    return MOT;
}
{MOT_SPECIAL} {
    column += yyleng;
    yylval = yytext;
    return MOT_SPECIAL;
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
    return QUESTION_MARK;
}
{EXCLAMATION_MARK} {
    column += yyleng;
    return EXCLAMATION_MARK;
}
{ERROR} {
    errors++;
    fprintf(stderr, "Erreur lexical : ligne %d, colonne %d : %s\n", line, column, yytext);
    column += yyleng;
}
%%
int yywrap(){ return 1; }
