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
COMMENT "<!--".*"-->"
META "<META auteurs=\"".+"\" domaine=\"".+"\"/>"
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
QUESTION_MARK "?"
EXCLAMATION_MARK "!"
DOT "."
SEMICOLON ";"
COMMA ","
ERROR [a-zA-Z]+|.
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
}
{TITLE_CLOSE} {
    column += yyleng;
}
{META} {
    column += yyleng;
}
{DIV_OPEN} {
    column += yyleng;
}
{DIV_CLOSE} {
    column += yyleng;
}
{TG_OPEN} {
    column += yyleng;
}
{TG_CLOSE} {
    column += yyleng;
}
{Bloc_par_OPEN} {
    column += yyleng;
}
{Bloc_par_CLOSE} {
    column += yyleng;
}
{H1_OPEN} {
    column += yyleng;    
}
{H1_CLOSE} {
    column += yyleng;
}
{P_OPEN} {
    column += yyleng;
}
{P_CLOSE} {
    column += yyleng;
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
    printf("Mot détecté : %s\n", yytext);
}
{DOT}|{SEMICOLON}|{COMMA}|{QUESTION_MARK}|{EXCLAMATION_MARK} {
    column += yyleng;
    printf("Ponctiuation détecté : %s\n", yytext);
}
{ERROR} {
    errors++;
    fprintf(stderr, "Erreur lexical : ligne %d, colonne %d : %s\n", line, column, yytext);
    column += yyleng;
}
%%
int yywrap(){ return 1; }
