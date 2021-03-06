%{
#include <iostream>
#include <stack>
#include <cstdlib>

#include "parser-push.hpp"

YYSTYPE yylval;
YYLTYPE yylloc;

yypstate* pstate = yypstate_new();

#define PUSH_TOKEN(token) do {  \
  int s = yypush_parse(pstate, token, &yylval, &yylloc);  \
  if (s != YYPUSH_MORE) {                                 \
    yypstate_delete(pstate);                              \
    return s;                                             \
  }                                                       \
} while(0)


/*
 * We'll use this stack to keep track of indentation level, as described in
 * the Python docs:
 *
 * https://docs.python.org/3/reference/lexical_analysis.html#indentation
 */
std::stack<int> _indent_stack;
%}
%option noyywrap

%option yylineno

%%

%{
  /*
   * These lines go at the top of the lexing function.  We only want to
   * initialize the indentation level stack once by pushing a 0 onto it (the
   * indentation stack should never be empty, except immediately after it is
   * created).
   */
  if (_indent_stack.empty()) {
    _indent_stack.push(0);
  }
%}

^[ \t]*\r?\n   { /* Skip blank lines */ }

^[ \t]*#.*\r?\n    { /* Skip whole-line comments. */ }

#.*$        { /* Skip comments on the same line as a statement. */ }

^[ \t]+     {
              /*
               * Handle indentation as described in Python docs linked above.
               * Note that this pattern treats leading spaces and leading tabs
               * equivalently, which could cause some unexpected behavior if
               * they're combined in a single line.  For the purposes of this
               * project, that's OK.
               */
              if (_indent_stack.top() < yyleng) {
                /*
                 * If the current indentation level is greater than the
                 * previous indentation level (stored at the top of the stack),
                 * then emit an INDENT and push the new indentation level onto
                 * the stack.
                 */
                 PUSH_TOKEN((yylval.token = INDENT));
                _indent_stack.push(yyleng);
              } else {
                /*
                 * If the current indentation level is less than or equal to
                 * the previous indentation level, pop indentation levels off
                 * the stack until the top is equal to the current indentation
                 * level.  Emit a DEDENT for each element popped from the stack.
                 */
                while (!_indent_stack.empty() && _indent_stack.top() != yyleng) {
                  _indent_stack.pop();
                  PUSH_TOKEN((yylval.token = DEDENT));
                }

                /*
                 * If we popped everythin g off the stack, that means the
                 * current indentation level didn't match any on the stack,
                 * which is an indentation error.
                 */
                if (_indent_stack.empty()) {
                  std::cerr << "Error: Incorrect indentation on line "
                    << yylineno << std::endl;
                  return 1;
                }
              }
            }

^[^ \t\n]+  {
              /*
               * If we find a line that's not indented, pop all indentation
               * levels off the stack, and emit a DEDENT for each one.  Then,
               * call REJECT, so the next rule matching this token is also
               * applied.
               */
              while(_indent_stack.top() != 0) {
                _indent_stack.pop();
                PUSH_TOKEN((yylval.token = DEDENT));
              }
              REJECT;
            }

\r?\n       {
              PUSH_TOKEN ((yylval.token = NEWLINE));
            }

<<EOF>>     {
              /*
               * If we reach the end of the file, pop all indentation levels
               * off the stack, and emit a DEDENT for each one.
               */
              while(_indent_stack.top() != 0) {
                _indent_stack.pop();
                PUSH_TOKEN((yylval.token = DEDENT));
              }
              int s = yypush_parse(pstate, 0, NULL, NULL);
                yypstate_delete(pstate);
                return s;
            }

[ \t]       { /* Ignore spaces that haven't been handled above. */ }

"and"       { PUSH_TOKEN((yylval.token = AND)); }
"break"     { PUSH_TOKEN((yylval.token = BREAK));}
"elif"      { PUSH_TOKEN((yylval.token = ELIF)); }
"else"      { PUSH_TOKEN((yylval.token = ELSE)); }
"if"        { PUSH_TOKEN((yylval.token = IF)); }
"not"       { PUSH_TOKEN((yylval.token = NOT)); }
"or"        { PUSH_TOKEN((yylval.token = OR)); }
"while"     { PUSH_TOKEN((yylval.token = WHILE)); }

"True"      { PUSH_TOKEN((yylval.token = TRUE)); }
"False"     { PUSH_TOKEN((yylval.token = FALSE)); }

[a-zA-Z_][a-zA-Z0-9_]*  {
                          yylval.str = new std::string(yytext, yyleng);
                          PUSH_TOKEN(IDENTIFIER);
                        }

-?[0-9]*"."[0-9]+       {
                          yylval.str = new std::string(yytext, yyleng);
                          PUSH_TOKEN(FLOAT);
                        }

-?[0-9]+    {
              yylval.str = new std::string(yytext, yyleng);
              PUSH_TOKEN(FLOAT);
            }

"="         { PUSH_TOKEN((yylval.token = ASSIGN)); }
"+"         { PUSH_TOKEN((yylval.token = PLUS)); }
"-"         { PUSH_TOKEN((yylval.token = MINUS)); }
"*"         { PUSH_TOKEN((yylval.token = TIMES));  }
"/"         { PUSH_TOKEN((yylval.token = DIVIDEDBY));  }
"=="        { PUSH_TOKEN((yylval.token = EQ)); }
"!="        { PUSH_TOKEN((yylval.token = NEQ)); }
">"         { PUSH_TOKEN((yylval.token = GT)); }
">="        { PUSH_TOKEN((yylval.token = GTE)); }
"<"         { PUSH_TOKEN((yylval.token = LT)); }
"<="        { PUSH_TOKEN((yylval.token = LTE)); }
"("         { PUSH_TOKEN((yylval.token = LPAREN)); }
")"         { PUSH_TOKEN((yylval.token = RPAREN)); }
":"         { PUSH_TOKEN((yylval.token = COLON)); }

.           {
              std::cerr << "Unrecognized token on line " << yylineno << ": "
                << yytext << std::endl;
              return 1;
            }

%%
