/*
 * Copyright (C) 1999, 2002, 2003, 2004  Free Software Foundation, Inc.
 * 
 * This file is part of GNU libmatheval
 *
 * GNU libmatheval is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * GNU libmatheval is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with program; see the file COPYING. If not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
 * USA.
 */

%{
/*
 * Copyright (C) 1999, 2002, 2003, 2004  Free Software Foundation, Inc.
 * 
 * This file is part of GNU libmatheval
 *
 * GNU libmatheval is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * GNU libmatheval is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with program; see the file COPYING. If not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
 * USA.
 */

#if HAVE_CONFIG_H
#  include "config.h"
#endif

#include "node.h"

/* Variables used to communicate with code using parser.  */
extern Node* root; /* Root of tree representation of function.  */
extern SymbolTable *symbol_table; /* Evaluator symbol table.  */
extern int ok; /* Flag representing success of parsing.  */

/* Report parsing error.  */
int yyerror (char *s);

/* Function used to tokenize string representing function (this function
   is generated by scanner generator).  */
int yylex (void);
%}

/* Parser semantic values type.  */
%union {
  Node *node;
  Record *record;
}

/* Grammar terminal symbols.  */
%token <node> NUMBER VARIABLE
%token <record> FUNCTION
%left '-' '+'
%left '*' '/'
%left NEG
%left '^'
%token END

/* Grammar non-terminal symbols.  */
%type <node> expression

/* Grammar start non-terminal.  */
%start input

%%

input
: expression '\n' {
  root = $1;
}
;

expression
: NUMBER
| VARIABLE
| expression '+' expression {
  /* Create addition binary operation node.  */
  $$ = node_create ('b', '+', $1, $3);
}
| expression '-' expression {
  /* Create subtraction binary operation node.  */
  $$ = node_create ('b', '-', $1, $3);
}
| expression '*' expression {
  /* Create multiplication binary operation node.  */
  $$ = node_create ('b', '*', $1, $3);
}
| expression '/' expression {
  /* Create division binary operation node.  */
  $$ = node_create ('b', '/', $1, $3);
}
| '-' expression %prec NEG {
  /* Create minus unary operation node.  */
  $$ = node_create ('u', '-', $2);
}
| expression '^' expression {
  /* Create exponentiation unary operation node.  */
  $$ = node_create ('b', '^', $1, $3);
}
| FUNCTION '(' expression ')' {
  /* Create function node.  */
  $$ = node_create ('f', $1, $3);
}
| '(' expression ')' {
  $$ = $2;
}
;

%%

int yyerror(char* s)
{
  /* Indicate parsing error through appropriate flag and stop
     parsing.  */
  ok = 0;
  return 0;
}
