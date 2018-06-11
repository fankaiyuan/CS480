%{
#include <iostream>
#include <stack>

std::stack<std::size_t> mystack;
bool _error = false;
bool beginline = true;
%}

%option noyywrap
%option yylineno

%%

%{
  mystack.push(0);
  /* No code to put at the top of yylex(). */
%}

[ \t]*       {
		if(beginline){
                	size_t top_len = mystack.top();
                 	if(yyleng>top_len){
                    		mystack.push(yyleng);
                    		printf("INDENT\n");
                 	}
                else if(yyleng<top_len){
			while(yyleng<top_len){
                        	mystack.pop();
                        	printf("DEDENT\n");
                        	top_len = mystack.top();
                       }
                }
               	beginline=false;
               	}	
        }
"#".*\n      /* ignore whole line comments */
^\n
\n           {if(beginline){
                size_t top_len=mystack.top();
                if(yyleng>top_len){
                    while(yyleng<top_len){
                        mystack.pop();
                        printf("DEDENT\n");
                        top_len=mystack.top();
                    }
                  }
                }
               else{
               printf("NEWLINE\n");
               beginline=true;
               }
        }
[-]?[1-9][0-9]*|[0] { printf("%-20s %s\n", "INTEGER", yytext); beginline=false;}
[-]?[0-9]*[.][0-9]+ { printf("%-20s %s\n", "FLOAT", yytext);beginline=false; }

and           { printf("%-20s %s\n", "AND", yytext);beginline=false;}
break         { printf("%-20s %s\n", "BREAK", yytext);beginline=false;}
def           { printf("%-20s %s\n", "DEF", yytext);beginline=false;}
elif          { printf("%-20s %s\n", "ELIF", yytext);beginline=false;}
else          { printf("%-20s %s\n", "ELSE", yytext);beginline=false;}
for           { printf("%-20s %s\n", "FOR", yytext);beginline=false;}
if            { printf("%-20s %s\n", "IF", yytext);beginline=false;}
not           { printf("%-20s %s\n", "NOT", yytext);beginline=false;}
or            { printf("%-20s %s\n", "OR", yytext);beginline=false;}
return        { printf("%-20s %s\n", "RETURN", yytext);beginline=false;}
while         { printf("%-20s %s\n", "WHILE", yytext);beginline=false;}
                
True            { printf("%-20s %s\n", "BOOLEAN", "1");beginline=false;}
False            { printf("%-20s %s\n", "BOOLEAN", "0");beginline=false;}

([a-z]|[A-Z]|_)([a-z]|[A-Z]|[0-9]|_)*   {
               				if(beginline){
                				size_t top_len=mystack.top();
                				while(top_len!=0){
                    					mystack.pop();
                    					printf("DEDENT\n");
                    					top_len = mystack.top();
                    				}
               				}
                			printf("%-20s %s\n", "IDENTIFIER", yytext);
                			beginline=false;
              }

"="           { printf("%-20s %s\n", "ASSIGN", yytext); beginline=false;}
"+"           { printf("%-20s %s\n", "PLUS", yytext); beginline=false;}
"-"           { printf("%-20s %s\n", "MINUS", yytext); beginline=false;}
"*"           { printf("%-20s %s\n", "TIMES", yytext); beginline=false;}
"/"           { printf("%-20s %s\n", "DIVIDEDBY", yytext); beginline=false;}
"=="          { printf("%-20s %s\n", "EQ", yytext); beginline=false;}
"!="          { printf("%-20s %s\n", "NEQ", yytext); beginline=false;}
">"           { printf("%-20s %s\n", "GT", yytext); beginline=false;}
">="          { printf("%-20s %s\n", "GTE", yytext); beginline=false;}
"<"           { printf("%-20s %s\n", "LT", yytext); beginline=false;}
"<="          { printf("%-20s %s\n", "LTE", yytext); beginline=false;}
"("           { printf("%-20s %s\n", "LPAREN", yytext); beginline=false;}
")"           { printf("%-20s %s\n", "RPAREN", yytext); beginline=false;}
","           { printf("%-20s %s\n", "COMMA", yytext); beginline=false;}
":"           { printf("%-20s %s\n", "COLON", yytext); beginline=false;}


<<EOF>>       {
                size_t top_len=mystack.top();
                if(yyleng<top_len){
                	while(yyleng<top_len){
                		mystack.pop();
                		printf("DEDENT\n");
                		top_len = mystack.top();
               		}
                }
                if (_error) {
                  return 1;
                }
                return 0;
              }
%%

int main() {
    yylex();
}
