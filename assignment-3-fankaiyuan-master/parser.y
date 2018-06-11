%{
#include <iostream>
#include <map>
#include <vector>

#include "parser.hpp"

std::map<std::string, float> symbols;

bool _error = false;

std::string* code;

int nodeID = 0;

struct AST {
	int ID;
	std::string* value;
	std::vector<struct AST*> child;
};

struct AST* root = new AST;

AST* newNode(std::string* value, int ID){
  AST* temp = new AST;
  temp->value = value;
  temp->ID = ID;
  return temp;
}

void addChild(struct AST *parent, struct AST *Child){
  parent->child.push_back(Child);
}


void yyerror(YYLTYPE* loc, const char* err);
extern int yylex();
%}

%union {
  float value;
  std::string* str;
  int token;
  struct AST* block;
}

/* %define api.value.type { std::string* } */
%locations

%define api.pure full
%define api.push-pull push

%token <str> IDENTIFIER FLOAT
%token <token> ASSIGN PLUS MINUS TIMES DIVIDEDBY
%token <token> NEWLINE LPAREN RPAREN COLON INDENT DEDENT
%token <token> EQ NEQ GT GTE LT LTE NOT AND OR
%token <token> IF ELSE ELIF TRUE FALSE BREAK WHILE

%type <block> expression statement program condition else goal


%left PLUS MINUS
%left TIMES DIVIDEDBY
/* %right */
/* %nonassoc */
/* %precedence */

%start goal

%%
goal
	: program {root = $1;}
	;

program
	: program statement {addChild($1, $2); $$ = $1;}
	| statement {$$ = newNode(new std::string("Block"),nodeID); addChild($$, $1); nodeID++;}
	;

statement
: IDENTIFIER ASSIGN expression NEWLINE { symbols[*$1] = 1.0; $$ = newNode(new std::string("Assignment"), nodeID); addChild($$, newNode(new std::string("Identifier: " + *$1),nodeID+1)); addChild($$, $3); nodeID = nodeID+2;}
| IF condition COLON NEWLINE INDENT program DEDENT else{ $$ = newNode(new std::string("IF"), nodeID); addChild($$, $2); addChild($$, $6); addChild($$, $8); nodeID++;}
| WHILE condition COLON NEWLINE INDENT program DEDENT{$$ = newNode(new std::string("WHILE"), nodeID); addChild($$, $2); addChild($$, $6); nodeID++;}
| BREAK NEWLINE {$$ = newNode(new std::string("BREAK"), nodeID); nodeID++;}
;


condition
: LPAREN condition RPAREN {$$ = newNode(new std::string(""), nodeID); addChild($$, $2);nodeID++;}
| condition EQ condition {$$ = newNode(new std::string("EQ"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++;}
| condition NEQ condition {$$ = newNode(new std::string("NEQ"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++;}
| condition GT condition {$$ = newNode(new std::string("GT"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++;}
| condition GTE condition {$$ = newNode(new std::string("GTE"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++;}
| condition LT condition {$$ = newNode(new std::string("LT"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++;}
| condition LTE condition {$$ = newNode(new std::string("LTE"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++;}
| condition AND condition {$$ = newNode(new std::string("AND"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++;}
| condition OR condition {$$ = newNode(new std::string("OR"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++;}
| NOT condition {$$ = newNode(new std::string("NOT"),nodeID); addChild($$, $2);nodeID++;}
| FLOAT {$$ = newNode(new std::string("float: " + *$1),nodeID);nodeID++;}
| IDENTIFIER {$$ = newNode(new std::string("identifier: " + *$1),nodeID);nodeID++;}
| TRUE {$$ = newNode(new std::string("true"),nodeID);nodeID++;}
| FALSE {$$ = newNode(new std::string("false"),nodeID);nodeID++;}
  ;

else
: ELSE COLON NEWLINE INDENT program DEDENT {$$ = $5;}
| ELIF condition COLON NEWLINE INDENT program DEDENT else {newNode(new std::string("ELIF"), nodeID); addChild($$, $2); addChild($$, $6); addChild($$, $8); nodeID++;}
| %empty {$$ = newNode(NULL, nodeID); nodeID++;}
;


expression
: LPAREN expression RPAREN { $$ = $2; }
| expression PLUS expression { $$ = newNode(new std::string("plus"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++; }
| expression MINUS expression { $$ = newNode(new std::string("minus"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++; }
| expression TIMES expression { $$ = newNode(new std::string("times"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++; }
| expression DIVIDEDBY expression { $$ = newNode(new std::string("DividedBY"),nodeID); addChild($$, $1); addChild($$, $3);nodeID++; }
| FLOAT { $$ = newNode(new std::string("FLOAT: " + *$1),nodeID);nodeID++; }
| IDENTIFIER { $$ = newNode(new std::string("Identifier: " + *$1),nodeID);nodeID++; }
| TRUE{$$ = newNode(new std::string("true"),nodeID);nodeID++;}
| FALSE{$$ = newNode(new std::string("false"),nodeID);nodeID++;}
  ;

%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error: " << err << std::endl;
}
