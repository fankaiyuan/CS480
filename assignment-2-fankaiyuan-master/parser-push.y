%{
#include <iostream>
#include <map>

#include "parser-push.hpp"

std::map<std::string, float> symbols;

void yyerror(YYLTYPE* loc, const char* err);
extern int yylex();
bool _error = false;
std::string* programs;

%}

%union {
  float value;
  std::string* str;
  int token;
}

/* %define api.value.type { std::string* } */

%locations

%define api.pure full
%define api.push-pull push

%token <str> IDENTIFIER FLOAT

%token <token> EQ NEQ GT GTE LT LTE ASSIGN PLUS MINUS TIMES DIVIDEDBY
%token <token> AND BREAK ELIF ELSE IF NOT OR WHILE  TRUE FALSE LPAREN RPAREN NEWLINE COLON DEDENT INDENT

%type <str>  program statement  arguement else operation boolean

%left PLUS MINUS
%left TIMES DIVIDEDBY
/* %right */
/* %nonassoc */
/* %precedence */

%start program

%%

program
  : program statement{$$ = new std::string(*$1 + *$2); programs = $$;}
  | statement {$$ = new std::string(*$1); programs = $$;}
  ;

statement
  : IDENTIFIER ASSIGN operation NEWLINE { symbols[*$1] = 1; $$ = new std::string(*$1 + " = " + *$3 + ";" + "\n");}
  | IF arguement COLON NEWLINE INDENT program DEDENT else{ $$ = new std::string("if ( " + *$2 + " ) {\n" + *$6 + " }\n" + *$8);}
  | WHILE arguement COLON NEWLINE INDENT program DEDENT{$$ = new std::string("while ( " + *$2 + " ) {\n" + *$6 + "}\n");}
  | BREAK NEWLINE {$$ = new std::string("break;\n");}
  | error NEWLINE { std::cerr << "Invalid statement" << std::endl; _error = true; }
  ;

else
  : ELSE COLON NEWLINE INDENT program DEDENT {$$ = new std::string("else {\n" + *$5 + "}\n");}
  | ELIF arguement COLON NEWLINE INDENT program DEDENT else {$$ = new std::string("else if ( " + *$2 + ") {\n" + *$6 + "}\n");}
  | %empty {$$ = new std::string("");}
  ;

arguement
  : LPAREN arguement RPAREN {$$ = new std::string( " ( " + *$2 + " ) " );}
  | arguement EQ arguement {$$ = new std::string(*$1 + " == " + *$3);}
  | arguement NEQ arguement {$$ = new std::string(*$1 + " != " + *$3);}
  | arguement GT arguement {$$ = new std::string(*$1 + " > " + *$3);}
  | arguement GTE arguement {$$ = new std::string(*$1 + " >= " + *$3);}
  | arguement LT arguement {$$ = new std::string(*$1 + " < " + *$3);}
  | arguement LTE arguement {$$ = new std::string(*$1 + " <= " + *$3);}
  | arguement AND arguement {$$ = new std::string(*$1 + " && " + *$3);}
  | arguement OR arguement {$$ = new std::string(*$1 + " || " + *$3);}
  | NOT arguement {$$ = new std::string("! " + *$2);}
  | FLOAT {$$ = new std::string(*$1);}
  | IDENTIFIER {$$ = new std::string(*$1);}
  | boolean{$$ = new std::string(*$1);}
  ;


operation
  : LPAREN operation RPAREN { $$ = new std::string( " ( " + *$2 + " ) " ); }
  | operation PLUS operation { $$ = new std::string(*$1 + " + " + *$3); }
  | operation MINUS operation { $$ = new std::string(*$1 + " - " + *$3); }
  | operation TIMES operation { $$ = new std::string(*$1 + " * " + *$3); }
  | operation DIVIDEDBY operation { $$ = new std::string(*$1 + " / " + *$3); }
  | IDENTIFIER { $$ = new std::string(*$1); } 
  | FLOAT { $$ = new std::string(*$1); }
  | boolean
  ;

  boolean
  :  TRUE {$$ = new std::string("true");}
  | FALSE {$$ = new std::string("false");}

%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error: " << err << std::endl;
}
