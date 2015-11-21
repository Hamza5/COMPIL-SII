%{
#include <stdio.h>
#include <stdlib.h>
unsigned short line = 1;
unsigned short column = 1;
unsigned short errors = 0;
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
    printf("%s détecté\n", yytext);
}
{HTML_OPEN} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{HTML_CLOSE} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{HEAD_OPEN} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{HEAD_CLOSE} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{BODY_OPEN} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{BODY_CLOSE} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{TITLE_OPEN} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{TITLE_CLOSE} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{META} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{DIV_OPEN} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{DIV_CLOSE} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{TG_OPEN} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{TG_CLOSE} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{Bloc_par_OPEN} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{Bloc_par_CLOSE} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{H1_OPEN} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{H1_CLOSE} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{P_OPEN} {
    column += yyleng;
    printf("%s détecté\n", yytext);
}
{P_CLOSE} {
    column += yyleng;
    printf("%s détecté\n", yytext);
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
int main(){
    yylex();
    return 0;
}