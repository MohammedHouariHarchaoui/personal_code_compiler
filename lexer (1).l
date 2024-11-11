%option noyywrap

%{

#include "parser.tab.h"
#include <string.h>

extern char* yytext;
int line_number=1;
int char_number = 0;
void yyerror(char* s);

%}

COMMENT <<([^>]|[\r\n]|(>([^>]|[\r\n])))*>>

OPEN_PARANTHESIS \(

CLOSE_PARANTHESIS \)

ID [_a-zA-Z][a-zA-Z0-9_]*

FUNCTION (?i:function)
WHILE_START (?i:while) 
FOR_START ?i:for


IF_START ?i:if
IF_ELSE ?i:otherwise



CONSTANT ?i:constant


HAS ?i:has 

AS ?i:as
COMMA \, 

DOT \.

EOL \n

ASSIGNED ?i:assigned
RETURN ?i:return



READ ?i:read
SHOW ?i:show 

AND ?i:and
OR ?i:or

GREATER_THAN ?i:greater[[:space:]]*than
GREATER_OR_EQUAL ?i:greater[[:space:]]*or[[:space:]]*equals 

LESS_THAN ?i:less[[:space:]]*than
LESS_OR_EQUAL ?i:less[[:space:]]*or[[:space:]]*equals

DIFFIRENT ?i:different[[:space:]]*than
EQUAL ?i:equals

INCREMENT ?i:increment
DECREMENT ?i:decrement

PLUS \+
MINUS \-
MULTIPLICATION \* 
DIVISION \/
MOD \%

BOOLEAN_TYPE ?i:boolean
INTEGER_TYPE ?i:integer
STRING_TYPE ?i:string
FLOAT_TYPE ?i:float
 
INTEGER -?[0-9]+  
FLOAT -?[0-9]+?\.[0-9]+
DOUBLE_QUOTE_STRING ["]([^"\\\n]|\\(.|\n))*["]
SINGLE_QUOTE_STRING [']([^'\\\n]|\\(.|\n))*[']
STRING {SINGLE_QUOTE_STRING}|{DOUBLE_QUOTE_STRING} 
BOOLEAN ?i:true|false 

PARAMETERS ?i:uses

TYPE_DEFINITION ?i:define
BREAK ?i:break
NOT ?i:not

WHITE_SPACE [ \t\r]+


%%
{COMMENT} {/*char_number+=strlen(yytext);*/return COMMENT;}

{WHILE_START} {char_number+=strlen(yytext);return WHILE_START;}

{IF_START} {char_number+=strlen(yytext);return IF_START;}
{IF_ELSE} {char_number+=strlen(yytext);return IF_ELSE;}



{HAS} {char_number+=strlen(yytext);return HAS;}

{AS} {yylval.string = yytext; char_number+=strlen(yytext);return AS;}

{COMMA} {char_number+=strlen(yytext);return COMMA;}

{DOT} {char_number+=strlen(yytext);return DOT;}

{EOL} {line_number++; char_number=0;return EOL;}

{ASSIGNED} {char_number+=strlen(yytext); return ASSIGNED;}
{RETURN} {char_number+=strlen(yytext);return RETURN;}

{READ} {char_number+=strlen(yytext);return READ;}
{SHOW} {char_number+=strlen(yytext);return SHOW;}

{AND} {char_number+=strlen(yytext);return AND;}
{OR} {char_number+=strlen(yytext);return OR;}

{GREATER_THAN} {char_number+=strlen(yytext);return GREATER_THAN;}
{GREATER_OR_EQUAL} {char_number+=strlen(yytext);return GREATER_OR_EQUAL;}

{LESS_THAN} {char_number+=strlen(yytext);return LESS_THAN;}
{LESS_OR_EQUAL} {char_number+=strlen(yytext);return LESS_OR_EQUAL;}

{DIFFIRENT} {char_number+=strlen(yytext);return DIFFIRENT;}
{EQUAL} {char_number+=strlen(yytext);return EQUAL;}
{CONSTANT} {char_number+=strlen(yytext);return CONSTANT;}

{PLUS} {char_number+=strlen(yytext);return PLUS;}
{MINUS} {char_number+=strlen(yytext);return MINUS;}
{MULTIPLICATION} {char_number+=strlen(yytext);return MULTIPLICATION;}
{DIVISION} {char_number+=strlen(yytext);return DIVISION;}
{MOD} {char_number+=strlen(yytext);return MOD;}



{BOOLEAN_TYPE} {char_number+=strlen(yytext); yylval.string =(char *)strdup(yytext); return BOOLEAN_TYPE;}
{INTEGER_TYPE} {char_number+=strlen(yytext); yylval.string =(char *)strdup(yytext); return INTEGER_TYPE;}
{STRING_TYPE} {char_number+=strlen(yytext); yylval.string =(char *)strdup(yytext); return STRING_TYPE;}
{FLOAT_TYPE} {char_number+=strlen(yytext); yylval.string =(char *)strdup(yytext); return FLOAT_TYPE;}

{FUNCTION} {char_number+=strlen(yytext); return FUNCTION;}
{PARAMETERS} {char_number+=strlen(yytext); return PARAMETERS;}

{TYPE_DEFINITION} {char_number+=strlen(yytext); return TYPE_DEFINITION;}
{NOT} {char_number+=strlen(yytext); return NOT;}

{FOR_START} {char_number+=strlen(yytext); return FOR_START;}

{INCREMENT} {char_number+=strlen(yytext); return INCREMENT;}
{DECREMENT} {char_number+=strlen(yytext); return DECREMENT;}

{BOOLEAN} {char_number+=strlen(yytext); yylval.string =(char *)strdup(yytext); return BOOLEAN;}



{OPEN_PARANTHESIS} {char_number+=strlen(yytext); return OPEN_PARANTHESIS;}
{CLOSE_PARANTHESIS} {char_number+=strlen(yytext); return CLOSE_PARANTHESIS;}


{INTEGER}  {char_number+=strlen(yytext); yylval.string =(char *)strdup(yytext); return INTEGER;}
{FLOAT} {char_number+=strlen(yytext); yylval.string =(char *)strdup(yytext); return FLOAT;}

{STRING} {char_number+=strlen(yytext); yylval.string =(char *)strdup(yytext); return STRING;}

{ID}  {char_number+=strlen(yytext); yylval.string =(char *)strdup(yytext); return ID;}

{WHITE_SPACE} {char_number+=strlen(yytext);}

%%

