%{


#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string.h>
//#include <stdbool.h>


extern char* yytext;
extern int yylex();
extern line_number;
extern char_number;
extern FILE* yyin;
extern FILE* yyout;
int errors = 0;

FILE* pOutputFile = NULL;


struct symbol_record {
	char *name;
	char *type;
	char *value;
	struct symbol_record * next;
};

typedef struct symbol_record symbol_record;

symbol_record * symbols_table = (symbol_record *)0;
symbol_record *put_symbol_with_value();
symbol_record *put_symbol_without_value();
symbol_record *get_symbol();






#define YYDEBUG 1
add_symbol_record_with_value(char *symbol_name , char* symbol_type , char* symbol_value){
	symbol_record* s;
	s = get_symbol(symbol_name);
	if(s==0){
		s = put_symbol_with_value(symbol_name,symbol_type,symbol_value);
	}else{
		errors++;
		yyerror("This variable already exists\n");
	}
	print_symbols_table();
}

add_symbol_record_without_value(char *symbol_name , char* symbol_type){
	symbol_record* s;
	s = get_symbol(symbol_name);
	if(s==0){
		s = put_symbol_without_value(symbol_name,symbol_type);
	}else{
		errors++;
		yyerror("This variable already exists\n");
	}
	print_symbols_table();
}


update_symbol_record_value(char *symbol_name , char *symbol_value){
	symbol_record* s;
	s = get_symbol(symbol_name);
	if(s==0){
		errors++;
		yyerror("This variable dosn't exists\n");  
	}else{
		strcpy(s->value,symbol_value);
	}
	print_symbols_table();
}


increment_symbol_record_value(char *symbol_name){
	symbol_record* s;
	s = get_symbol(symbol_name);
	if(s==0){
		errors++;
		yyerror("This variable dosn't exists\n");  
	}else{
		strcpy(s->value,atoi(s->value)+1);
	}
	print_symbols_table();
}

print(char *symbol_name, int choix){
	if(choix==1){
		symbol_record* s;
		s = get_symbol(symbol_name);
		printf("\n\n+--------------------------------+\n");
		printf("|%12s  = %10s      |\n",s->name,s->value);
		printf("+--------------------------------+\n");
	}

}


minus(char*op1 , char* op2){
	printf("\n>>>>>    %d\n",atoi(op1)-atoi(op2));
	return atoi(op1)-atoi(op2);
}


addition(char*op1 , char* op2){
	char *ret;
	printf("\n>>>>>    %d\n",atoi(op1)+atoi(op2));
	return ret;
}

multiplication(char*op1 , char* op2){
	printf("\n>>>>>    %d\n",atoi(op1)*atoi(op2));
	return atoi(op1)*atoi(op2);
}


division(char*op1 , char* op2){
	printf("\n>>>>>    %d\n",atoi(op1)/atoi(op2));
	return atoi(op1)/atoi(op2);
}

moduls(char*op1 , char* op2){
	printf("\n>>>>>    %d\n",atoi(op1)%atoi(op2));
	return atoi(op1)%atoi(op2);
}


context_check(char *symbol_name){
	if(get_symbol(symbol_name)==0){
		errors++;
		yyerror("This record dosn't exist\n");
	}
}


%}



%union{
	int integer;
	float real;
	char* id;
	char* string;
	//bool boolean;
}

%token<string> INTEGER
%token<string> FLOAT
%token<string> STRING
%token<string> BOOLEAN
%token WHILE_START 
%token IF_START IF_ELSE 


%token<string> HAS AS ASSIGNED RETURN
%token COMMENT EOL
%token READ SHOW CONSTANT
%token<string> AND OR NOT
%token GREATER_THAN GREATER_OR_EQUAL LESS_THAN LESS_OR_EQUAL DIFFIRENT EQUAL
%token<string> ID
%token<string> INTEGER_TYPE FLOAT_TYPE STRING_TYPE BOOLEAN_TYPE 
%token<string> COMMA DOT OPEN_PARANTHESIS CLOSE_PARANTHESIS;
%token PLUS MULTIPLICATION MINUS DIVISION MOD;
%token FUNCTION PARAMETERS
%token TYPE_DEFINITION
%token BREAK
%token FOR_START
%token<string> INCREMENT DECREMENT


%nonassoc LESS_THAN LESS_OR_EQUAL GREATER_THAN GREATER_OR_THAN
%right OR
%right AND
%right NOT
%right EQUAL
%nonassoc DIFFIRENT
%left PLUS MINUS
%left MULTIPLICATION DIVISION MOD 
%type<string> EXPRESSION EXPRESSIONS
%type<string> TYPE CALL ASSIGN_EXPRESSION LOGICAL_EXPRESSION RELATIONAL_EXPRESSION
%type<string> ARITHMETIC_EXPRESSION EQUALITY_EXPRESSION POSTFIX_EXPRESSION


%%


LINES :	LINE LINES
|	LINE 
|	LINE EOL
;


LINE :	COMMENT 
|	VARIABLE_DECLARATION 
|	CONSTANT_DECLARATION 
|	FUNCTION_DECLARATION 
|	STRUCTURE_DECLARATION 
|	STATEMENT  
|	EOL
|
;


WHILE_STATEMENT : WHILE_START OPEN_PARANTHESIS EXPRESSION CLOSE_PARANTHESIS OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	WHILE_START OPEN_PARANTHESIS EXPRESSION CLOSE_PARANTHESIS OPEN_PARANTHESIS EOL LINES CLOSE_PARANTHESIS
;

VARIABLE_DECLARATION : INTEGER_VAR_DECLARATION
|	FLOAT_VAR_DECLARATION
|	STRING_VAR_DECLARATION
|	BOOLEAN_VAR_DECLARATION
|	ID {yyerror(printf("You can't define variable '%s' without specify type of this variable , you have to give it a type from [integer | float | string | boolean] like %s as string",$1,$1));}
|	ID AS {yyerror("You can't define variable '%s' without specify type of this variable , you have to give it a type from [integer | float | string | boolean] like %s as string\n",$1,$1);}
|	ID AS ID {yyerror("Undefined type '%s' of variable or , you have to give it a type from [integer | float | string | boolean] like %s as string\n",$3,$1);}
|	ID AS TYPE ASSIGNED {yyerror("Undefined value to assign You can't define variable '%s' with assign and not specify value, you have to give it a value from '%s' type\n",$1,$3);}
;



CONSTANT_DECLARATION : CONSTANT INTEGER_CONST_DECLARATION
|	CONSTANT FLOAT_CONST_DECLARATION
|	CONSTANT STRING_CONST_DECLARATION
|	CONSTANT BOOLEAN_CONST_DECLARATION
;

INTEGER_CONST_DECLARATION :ID AS INTEGER_TYPE ASSIGNED INTEGER  {add_symbol_record_with_value($1,$3,$5);}
|	ID AS INTEGER_TYPE ASSIGNED FLOAT {yyerror("You can't declare %s as integer and then assign a float value, you have to assign integer value\n",$1);}
|	ID AS INTEGER_TYPE ASSIGNED STRING {yyerror("You can't declare %s as integer and then assign a string value, you have to assign integer value\n",$1);}
|	ID AS INTEGER_TYPE ASSIGNED BOOLEAN {yyerror("You can't declare %s as integer and then assign a boolean value, you have to assign integer value\n",$1);}
;


FLOAT_CONST_DECLARATION :ID AS FLOAT_TYPE ASSIGNED FLOAT {add_symbol_record_with_value($1,$3,$5);}
|	ID AS FLOAT_TYPE ASSIGNED INTEGER {yyerror("You can't declare %s as float and then assign a float value, you have to assign float value\n",$1);}
|	ID AS FLOAT_TYPE ASSIGNED STRING {yyerror("You can't declare %s as float and then assign a string value, you have to assign float value\n",$1);}
|	ID AS FLOAT_TYPE ASSIGNED BOOLEAN {yyerror("You can't declare %s as float and then assign a boolean value, you have to assign float value\n",$1);}
;


STRING_CONST_DECLARATION :ID AS STRING_TYPE ASSIGNED STRING {add_symbol_record_with_value($1,$3,$5);}
|	ID AS STRING_TYPE ASSIGNED INTEGER {yyerror("You can't declare %s as string and then assign a integer value, you have to assign string value\n",$1);}
|	ID AS STRING_TYPE ASSIGNED FLOAT {yyerror("You can't declare %s as string and then assign a float value, you have to assign string value\n",$1);}
|	ID AS STRING_TYPE ASSIGNED BOOLEAN {yyerror("You can't declare %s as string and then assign a boolean value, you have to assign string value\n",$1);}
;

BOOLEAN_CONST_DECLARATION :ID AS BOOLEAN_TYPE ASSIGNED BOOLEAN {add_symbol_record_with_value($1,$3,$5);}
|	ID AS BOOLEAN_TYPE ASSIGNED INTEGER {yyerror("You can't declare %s as boolean and then assign a integer value, you have to assign boolean value\n",$1);}
|	ID AS BOOLEAN_TYPE ASSIGNED FLOAT {yyerror("You can't declare %s as integer and then assign a float value, you have to assign boolean value\n",$1);}
|	ID AS BOOLEAN_TYPE ASSIGNED STRING {yyerror("You can't declare %s as integer and then assign a string value, you have to assign boolean value\n",$1);}
;



FUNCTION_DECLARATION : FUNCTION ID PARAMETERS OPEN_PARANTHESIS FORMALS CLOSE_PARANTHESIS RETURN TYPE OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	FUNCTION ID PARAMETERS OPEN_PARANTHESIS FORMALS CLOSE_PARANTHESIS RETURN TYPE EOL OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	FUNCTION ID PARAMETERS OPEN_PARANTHESIS FORMALS CLOSE_PARANTHESIS OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	FUNCTION ID PARAMETERS OPEN_PARANTHESIS FORMALS CLOSE_PARANTHESIS EOL OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
;


STRUCTURE_DECLARATION : TYPE_DEFINITION ID HAS OPEN_PARANTHESIS FORMALS CLOSE_PARANTHESIS {add_symbol_record_without_value($2,"STRUCTURE");}
;  



IF_STATEMENT : IF_START OPEN_PARANTHESIS EXPRESSION CLOSE_PARANTHESIS OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS IF_ELSE OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	IF_START OPEN_PARANTHESIS EXPRESSION CLOSE_PARANTHESIS EOL OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS IF_ELSE OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	IF_START OPEN_PARANTHESIS EXPRESSION CLOSE_PARANTHESIS OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS IF_ELSE EOL OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	IF_START OPEN_PARANTHESIS EXPRESSION CLOSE_PARANTHESIS EOL OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS IF_ELSE EOL OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	IF_START OPEN_PARANTHESIS EXPRESSION CLOSE_PARANTHESIS EOL OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	IF_START OPEN_PARANTHESIS EXPRESSION CLOSE_PARANTHESIS OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
;




STATEMENT :	EXPRESSION
|	IF_STATEMENT
|	WHILE_STATEMENT
|	FOR_STATEMENT
|	BREAK_STATEMENT
|	RETURN_STATEMENT
|	PRINT_STATEMENT
|	INPUT_STATEMENT
|	CALL_STATEMENT
|	ASSIGN_STATEMENT
;


CALL : ID OPEN_PARANTHESIS ACTUALS CLOSE_PARANTHESIS
;

CALL_STATEMENT : ID OPEN_PARANTHESIS ACTUALS CLOSE_PARANTHESIS EOL
|	ID OPEN_PARANTHESIS ACTUALS CLOSE_PARANTHESIS COMMA
;

ACTUALS : EXPRESSIONS
|
;



FOR_STATEMENT : FOR_START OPEN_PARANTHESIS OPEN_PARANTHESIS INITIAL_EXPRESSION CLOSE_PARANTHESIS COMMA EXPRESSION COMMA OPEN_PARANTHESIS UPDATE_STATEMENT CLOSE_PARANTHESIS CLOSE_PARANTHESIS EOL OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	FOR_START OPEN_PARANTHESIS OPEN_PARANTHESIS INITIAL_EXPRESSION CLOSE_PARANTHESIS COMMA EXPRESSION COMMA OPEN_PARANTHESIS UPDATE_STATEMENT CLOSE_PARANTHESIS CLOSE_PARANTHESIS OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	FOR_START OPEN_PARANTHESIS INITIAL_EXPRESSION COMMA EXPRESSION COMMA OPEN_PARANTHESIS UPDATE_STATEMENT CLOSE_PARANTHESIS CLOSE_PARANTHESIS EOL OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	FOR_START OPEN_PARANTHESIS INITIAL_EXPRESSION COMMA EXPRESSION COMMA OPEN_PARANTHESIS UPDATE_STATEMENT CLOSE_PARANTHESIS CLOSE_PARANTHESIS OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	FOR_START OPEN_PARANTHESIS OPEN_PARANTHESIS INITIAL_EXPRESSION CLOSE_PARANTHESIS COMMA EXPRESSION COMMA UPDATE_STATEMENT CLOSE_PARANTHESIS EOL OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	FOR_START OPEN_PARANTHESIS OPEN_PARANTHESIS INITIAL_EXPRESSION CLOSE_PARANTHESIS COMMA EXPRESSION COMMA UPDATE_STATEMENT CLOSE_PARANTHESIS OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	FOR_START OPEN_PARANTHESIS INITIAL_EXPRESSION COMMA EXPRESSION COMMA UPDATE_STATEMENT CLOSE_PARANTHESIS EOL OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
|	FOR_START OPEN_PARANTHESIS INITIAL_EXPRESSION COMMA EXPRESSION COMMA UPDATE_STATEMENT CLOSE_PARANTHESIS OPEN_PARANTHESIS LINES CLOSE_PARANTHESIS
;

RETURN_STATEMENT : RETURN EXPRESSION
;

BREAK_STATEMENT : BREAK
;

PRINT_STATEMENT : SHOW OPEN_PARANTHESIS EXPRESSIONS CLOSE_PARANTHESIS {print($3,1);}
|	SHOW EXPRESSIONS {print($2,1);}
;

INPUT_STATEMENT : READ OPEN_PARANTHESIS ID CLOSE_PARANTHESIS
|	READ ID 
;
 

INITIAL_EXPRESSION : ID AS INTEGER_TYPE ASSIGNED INTEGER  COMMA INITIAL_EXPRESSION
|	ID ASSIGNED INTEGER COMMA INITIAL_EXPRESSION 
|	ID AS INTEGER_TYPE ASSIGNED INTEGER
|	ID ASSIGNED INTEGER
|
;

UPDATE_STATEMENT : UPDATE_STATEMENT COMMA UPDATE_STATEMENT
|	POSTFIX_EXPRESSION
|	ASSIGN_EXPRESSION
|
; 

ASSIGN_STATEMENT : ID ASSIGNED INTEGER  {update_symbol_record_value($1,$3);}
|	ID ASSIGNED FLOAT {update_symbol_record_value($1,$3);}
|	ID ASSIGNED STRING {update_symbol_record_value($1,$3);}
|	ID ASSIGNED BOOLEAN {update_symbol_record_value($1,$3);}
|	ID ASSIGNED EXPRESSION {update_symbol_record_value($1,$3);}
|	INCREMENT ID 
|	DECREMENT ID 
;




EXPRESSION : CALL
|	OPEN_PARANTHESIS EXPRESSION CLOSE_PARANTHESIS
|	ARITHMETIC_EXPRESSION
|	EQUALITY_EXPRESSION
|	RELATIONAL_EXPRESSION
|	LOGICAL_EXPRESSION
|	POSTFIX_EXPRESSION
|	ID
|	INTEGER
|	BOOLEAN	
|	FLOAT
|	STRING
;

EXPRESSIONS : EXPRESSION COMMA EXPRESSIONS
|	EXPRESSION 
;


POSTFIX_EXPRESSION : INCREMENT ID
|	DECREMENT ID
;

ASSIGN_EXPRESSION : ID ASSIGNED EXPRESSION 
;

ARITHMETIC_EXPRESSION : EXPRESSION PLUS EXPRESSION {addition($1,$3);}
|	EXPRESSION MINUS EXPRESSION  {minus($1,$3);}
|	EXPRESSION MULTIPLICATION EXPRESSION  {multiplication($1,$3);}
|	EXPRESSION DIVISION EXPRESSION  {division($1,$3);}
|	EXPRESSION MOD EXPRESSION  {moduls($1,$3);}
;


EQUALITY_EXPRESSION : EXPRESSION EQUAL EXPRESSION
|	EXPRESSION DIFFIRENT EXPRESSION 
;

RELATIONAL_EXPRESSION : EXPRESSION GREATER_THAN EXPRESSION
|	EXPRESSION GREATER_OR_EQUAL EXPRESSION
|	EXPRESSION LESS_THAN EXPRESSION
|	EXPRESSION LESS_OR_EQUAL EXPRESSION
;


LOGICAL_EXPRESSION : EXPRESSION AND EXPRESSION
|	EXPRESSION OR EXPRESSION
|	NOT EXPRESSION
;

FORMALS : VARIABLES 
|
;


VARIABLES : ID AS TYPE COMMA VARIABLES 
|	ID AS TYPE 
;



TYPE : INTEGER_TYPE
|	FLOAT_TYPE
|	STRING_TYPE
|	BOOLEAN_TYPE
;

INTEGER_VAR_DECLARATION : ID AS INTEGER_TYPE {add_symbol_record_without_value($1,$3);}
|	ID AS INTEGER_TYPE ASSIGNED INTEGER {add_symbol_record_with_value($1,$3,$5);}
|	ID AS INTEGER_TYPE ASSIGNED FLOAT {yyerror("You can't declare %s as integer and then assign a float value, you have to assign integer value\n",$1);}
|	ID AS INTEGER_TYPE ASSIGNED STRING {yyerror("You can't declare %s as integer and then assign a string value, you have to assign integer value\n",$1);}
|	ID AS INTEGER_TYPE ASSIGNED BOOLEAN {yyerror("You can't declare %s as integer and then assign a boolean value, you have to assign integer value\n",$1);}
;


FLOAT_VAR_DECLARATION : ID AS FLOAT_TYPE {add_symbol_record_without_value($1,$3);}
|	ID AS FLOAT_TYPE ASSIGNED FLOAT {add_symbol_record_with_value($1,$3,$5);}
|	ID AS FLOAT_TYPE ASSIGNED INTEGER {yyerror("You can't declare %s as float and then assign a float value, you have to assign float value\n",$1);}
|	ID AS FLOAT_TYPE ASSIGNED STRING {yyerror("You can't declare %s as float and then assign a string value, you have to assign float value\n",$1);}
|	ID AS FLOAT_TYPE ASSIGNED BOOLEAN {yyerror("You can't declare %s as float and then assign a boolean value, you have to assign float value\n",$1);}
;


STRING_VAR_DECLARATION : ID AS STRING_TYPE {add_symbol_record_without_value($1,$3);}
|	ID AS STRING_TYPE ASSIGNED STRING {add_symbol_record_with_value($1,$3,$5);}
|	ID AS STRING_TYPE ASSIGNED INTEGER {yyerror("You can't declare %s as string and then assign a integer value, you have to assign string value\n",$1);}
|	ID AS STRING_TYPE ASSIGNED FLOAT {yyerror("You can't declare %s as string and then assign a float value, you have to assign string value\n",$1);}
|	ID AS STRING_TYPE ASSIGNED BOOLEAN {yyerror("You can't declare %s as string and then assign a boolean value, you have to assign string value\n",$1);}
;

BOOLEAN_VAR_DECLARATION : ID AS BOOLEAN_TYPE {add_symbol_record_without_value($1,$3);}
|	ID AS BOOLEAN_TYPE ASSIGNED BOOLEAN {add_symbol_record_with_value($1,$3,$5);}
|	ID AS BOOLEAN_TYPE ASSIGNED INTEGER {yyerror("You can't declare %s as boolean and then assign a integer value, you have to assign boolean value\n",$1);}
|	ID AS BOOLEAN_TYPE ASSIGNED FLOAT {yyerror("You can't declare %s as integer and then assign a float value, you have to assign boolean value\n",$1);}
|	ID AS BOOLEAN_TYPE ASSIGNED STRING {yyerror("You can't declare %s as integer and then assign a string value, you have to assign boolean value\n",$1);}
;




%%


char* itoa(int value, char* result, int base) {
    // check that the base if valid
    if (base < 2 || base > 36) { *result = '\0'; return result; }

    char* ptr = result, *ptr1 = result, tmp_char;
    int tmp_value;

    do {
        tmp_value = value;
        value /= base;
        *ptr++ = "zyxwvutsrqponmlkjihgfedcba9876543210123456789abcdefghijklmnopqrstuvwxyz" [35 + (tmp_value - value * base)];
    } while ( value );

    // Apply negative sign
    if (tmp_value < 0) *ptr++ = '-';
    *ptr-- = '\0';
    while(ptr1 < ptr) {
        tmp_char = *ptr;
        *ptr--= *ptr1;
        *ptr1++ = tmp_char;
    }
    return result;
}



int main(int argc , char **argv){
 /* #ifdef YYDEBUG
    yydebug = 1;
    #endif*/
	yyin=fopen("test","r");
	yyout = freopen("output","w",stdout);
	yyparse();
	fclose(yyin);
	fclose(yyout);
	return 0;
}

symbol_record* put_symbol_with_value(char *symbol_name , char *symbol_type , char *symbol_value){
	symbol_record * ptr;
	ptr = (symbol_record *)malloc(sizeof(symbol_record));
	ptr->name = (char *)malloc(strlen(symbol_name)+1);
	ptr->type = (char *)malloc(strlen(symbol_type)+1);
	ptr->value = (char *)malloc(strlen(symbol_value)+1);
	strcpy(ptr->name,symbol_name);
	strcpy(ptr->type,symbol_type);
	strcpy(ptr->value,symbol_value);
	ptr->next = (struct symbol_record *)symbols_table;
	symbols_table = ptr;
	return ptr;
}

symbol_record* put_symbol_without_value(char *symbol_name , char *symbol_type){
	symbol_record * ptr;
	ptr = (symbol_record *)malloc(sizeof(symbol_record));
	ptr->name = (char *)malloc(strlen(symbol_name)+1);
	ptr->type = (char *)malloc(strlen(symbol_type)+1);
	ptr->value = (char *)malloc(256);
	strcpy(ptr->name,symbol_name);
	strcpy(ptr->type,symbol_type);
	ptr->next = (struct symbol_record *)symbols_table;
	symbols_table = ptr;
	return ptr;
}



symbol_record *get_symbol(char *symbol_name){
	symbol_record* ptr;
	for(ptr=symbols_table ; ptr!=(symbol_record *)0 ; ptr = (symbol_record *)ptr->next){
		if(strcmp(ptr->name,symbol_name)==0){
			return ptr;
		}
	}
	return 0;
}



void print_symbols_table(){
	printf("\n\n+------------------------------------------------+\n");
	printf("|                  Symbols table                 |");
	printf("\n+------------------------------------------------+\n");
	symbol_record* ptr;
	ptr=symbols_table ;
	while( ptr!=NULL){
		printf("|%12s < %8s > ====> %10s      |\n",ptr->name,ptr->type,ptr->value);
		printf("+------------------------------------------------+\n");
		ptr = (symbol_record *)ptr->next;
	}
}




void yyerror(char const * s){
	char* error_type = "Syntaxique error";
	fprintf(stdout,"\n%s in line %d position %d\n",error_type , line_number,char_number);
	fprintf(stdout,"Suggession: %s\n",s);
	errors++;
	printf("Error : %s",s);
}