%{
#include <cstdio>
#include <iostream>
using namespace std;

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
 extern int line_num;
void yyerror(const char *s);

%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
	int ival;
	float fval;
	char *sval;
}

// define the constant-string tokens:
%token PROG
%token INT
%token FLOAT
%token IF
%token ELSE
%token VAR
%token PRINT
%token STRING
%token CHAR
%token FUNCTION
%token VOID
%token WHILE
%token DO
%token CASE
%token OF
%token READ



%token ID

%token DIFF

%token ENDL

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <ival> CTE_I
%token <fval> CTE_F
%token <sval> CTE_STRING
%token <cval> CTE_CHAR
%token <bval> CTE_BOOL

%start programa


%error-verbose
%%

programa:
	PROG ID ';' endl vars functions bloque { cout << "Fin del analisis del programa " << endl; }
	;

functions:
	functions FUNCTION ID '(' def_param ')' ':' tipo bloque ';'
	| FUNCTION ID '(' def_param ')' ':' tipo bloque ';'

def_param:
	def_param ID ':' tipo
	| ID ':' tipo

vars:
	VAR endl def_vars 
	|
	;

def_vars:
	def_vars def_id ':' tipo ';' endl 
	| def_id ':' tipo ';' endl
	;

def_id:
	def_id ',' ID 
	|  ID
	;

tipo:
	INT
	| FLOAT
	| STRING
	| CHAR
	| BOOL
	| VOID
	;

bloque:
	'{' endl def_estatuto '}' endl 
	;

def_estatuto:
	estatuto def_estatuto
	|
	;

estatuto:
	asignacion 
	| condicion 
	| escritura
	| casos
	| ciclo
	| lectura 
	;

asignacion:
	ID '=' expresion ';' endl
	;

condicion:
	IF '(' expresion ')' endl bloque def_else
	;

escritura:
	PRINT '(' mensaje ')' ';' endl
	;

casos:
	CASE ID OF endl '{' mas_expr ':' estatuto ';' end '}' ';' endl
	;

ciclo:
	WHILE '(' expresion ')' DO endl bloque ';' endl
	;

lectura:
	READ '(' ID ')' ';' endl
	;

def_else:
	ELSE endl bloque
	| 
	;

mensaje:
	mensaje ',' expresion  
	| mensaje ',' CTE_STRING
	| expresion
	| CTE_STRING 
	;

expresion:
	exp mas_expr 
	| exp
	;

mas_expr:
	'>' exp
	| '<' exp
	| DIFF exp
	| '=' exp
	;

exp:
	termino
	| exp '+' termino
	| exp '-' termino
	;

termino:
	factor
	| termino '*' factor
	| termino '/' factor
	;

factor:
	'(' expresion ')'
	| varcte
	| '+' varcte 
	| '-' varcte
	;

varcte:
	ID
	| CTE_I
	| CTE_F
	| CTE_STRING
	| CTE_CHAR
	| CTE_BOOL
	;

endl:
	ENDL endl
	|
	;
%%

main() {

	// open a file handle to a particular file:
	FILE *myfile = fopen("input.file", "r");
	// make sure it is valid:
	if (!myfile) {
		cout << "No se pudo abrir ningun archivo" << endl;
		return -1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));

}

void yyerror(const char *s) {
	cout << "Parse error on line " << line_num << "!  Message: " << s << endl;
	// might as well halt now:
	exit(-1);
}