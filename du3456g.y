%language "c++"
%require "3.0.4"
%defines
%define parser_class_name{ mlaskal_parser }
%define api.token.constructor
%define api.token.prefix{DUTOK_}
%define api.value.type variant
%define parse.assert
%define parse.error verbose

%locations

%define api.location.type{ unsigned }

%code requires
{
	// this code is emitted to du3456g.hpp

	// allow references to semantic types in %type
#include "dutables.hpp"

#include "du3456sem.hpp"

	// avoid no-case warnings when compiling du3g.hpp
#pragma warning (disable:4065)

// adjust YYLLOC_DEFAULT macro for our api.location.type
#define YYLLOC_DEFAULT(res,rhs,N)	(res = (N)?YYRHSLOC(rhs, 1):YYRHSLOC(rhs, 0))
// supply missing YY_NULL in bfexpg.hpp
#define YY_NULL	0
#define YY_NULLPTR	0
}

%param{ mlc::yyscan_t2 yyscanner }	// formal name "yyscanner" is enforced by flex
%param{ mlc::MlaskalCtx* ctx }

%start mlaskal

%code
{
	// this code is emitted to du3456g.cpp

	// declare yylex here 
	#include "bisonflex.hpp"
	YY_DECL;

	// allow access to context 
	#include "dutables.hpp"

	// other user-required contents
	#include <assert.h>
	#include <stdlib.h>

    /* local stuff */
    using namespace mlc;

}

%token EOF	0	"end of file"

%token PROGRAM			/* program */
%token LABEL			    /* label */
%token CONST			    /* const */
%token TYPE			    /* type */
%token VAR			    /* var */
%token BEGIN			    /* begin */
%token END			    /* end */
%token PROCEDURE			/* procedure */
%token FUNCTION			/* function */
%token ARRAY			    /* array */
%token OF				    /* of */
%token GOTO			    /* goto */
%token IF				    /* if */
%token THEN			    /* then */
%token ELSE			    /* else */
%token WHILE			    /* while */
%token DO				    /* do */
%token REPEAT			    /* repeat */
%token UNTIL			    /* until */
%token FOR			    /* for */
%token OR				    /* or */
%token NOT			    /* not */
%token RECORD			    /* record */

/* literals */
%token<mlc::ls_id_index> IDENTIFIER			/* identifier */
%token<mlc::ls_int_index> UINT			    /* unsigned integer */
%token<mlc::ls_real_index> REAL			    /* real number */
%token<mlc::ls_str_index> STRING			    /* string */

/* delimiters */
%token SEMICOLON			/* ; */
%token DOT			    /* . */
%token COMMA			    /* , */
%token EQ				    /* = */
%token COLON			    /* : */
%token LPAR			    /* ( */
%token RPAR			    /* ) */
%token DOTDOT			    /* .. */
%token LSBRA			    /* [ */
%token RSBRA			    /* ] */
%token ASSIGN			    /* := */

/* grouped operators and keywords */
%token<mlc::DUTOKGE_OPER_REL> OPER_REL			    /* <, <=, <>, >=, > */
%token<mlc::DUTOKGE_OPER_SIGNADD> OPER_SIGNADD		    /* +, - */
%token<mlc::DUTOKGE_OPER_MUL> OPER_MUL			    /* *, /, div, mod, and */
%token<mlc::DUTOKGE_FOR_DIRECTION> FOR_DIRECTION		    /* to, downto */



%type<mlc::parameter_list_ptr> maly
%type<std::vector<mlc::ls_id_index>> idloop
%type<std::list<mlc::type_pointer>> OrdTpLoop
%type<mlc::ls_int_index> OrdinalConstant
%type<mlc::type_pointer> malyp
%type<mlc::parameter_list_ptr> fp_pars_1
%type<mlc::type_pointer> type
%type<mlc::ls_id_index> funOrPar
%type<mlc::vc> IDEN_loop

%type<mlc::ls_id_index> function_header
%type<mlc::ls_id_index> procedure_header

%type<bool> Evar
%type<mlc::parameter_list_ptr> formal_params

%type<mlc::type_pointer> type_identifier

%type<mlc::icblock_pointer> block
%type<mlc::icblock_pointer> blockP
%type<mlc::icblock_pointer> statements
%type<mlc::icblock_pointer> statement
%type<mlc::icblock_pointer> st2
%type<mlc::icblock_pointer> st1


%type<mlc::icblock_pointer> BlockP
%type<mlc::icblock_pointer> bp2
%type<mlc::icblock_pointer> bp3
%type<mlc::icblock_pointer> bp4
%type<mlc::icblock_pointer> bp5
%type<mlc::icblock_pointer> bp6
%type<mlc::icblock_pointer> Block
%type<mlc::icblock_pointer> b2
%type<mlc::icblock_pointer> b3
%type<mlc::icblock_pointer> b4
%type<mlc::icblock_pointer> b5

%type<mlc::icblock_pointer> bp5m
%type<mlc::icblock_pointer> bp5ma
%type<mlc::icblock_pointer> bp5mb
%type<mlc::icblock_pointer> semBlocSem


%type<mlc::vys> expression
%type<mlc::vys> SimpleExpression
%type<mlc::vys> term
%type<mlc::vys> TermLoop
%type<mlc::vys> factor
%type<mlc::factor_no_id> factor_no_id
%type<mlc::real_params> real_params
%type<mlc::Eplmin> Eplmin

%%

//mlaskal:	    PROGRAM IDENTIFIER SEMICOLON BlockP DOT { ctx->tab->set_main_code($2, $4); };

mlaskal:	PROGRAM IDENTIFIER SEMICOLON blockP DOT { ctx->tab->set_main_code($2, $4); };

blockP:		blabel bconts btype bvar bfunproc
			BEGIN 
			statements
			END { $$ = $7; };

block:		blabel bconts btype bvar
			BEGIN 
			statements
			END { $$ = $6; };	

blabel: LABEL UINT mb1 
		{
			ctx->tab->add_label_entry(@1, $2, ctx->tab->new_label());
		}
		|
		;
mb1: COMMA UINT mb1 
	{
		ctx->tab->add_label_entry(@1, $2, ctx->tab->new_label());
	}
	| SEMICOLON;

bconts:	CONST constLoop
				|
				;

constLoop:	constLoop cs1
			| cs1;

cs1:	IDENTIFIER EQ UINT SEMICOLON
		{
			ctx->tab->add_const_int(@1, $1, $3);
		}
		| IDENTIFIER EQ REAL SEMICOLON
		{
			ctx->tab->add_const_real(@1, $1, $3);
		}
		| IDENTIFIER EQ STRING SEMICOLON
		{
			ctx->tab->add_const_str(@1, $1, $3);
		}
		| IDENTIFIER EQ OPER_SIGNADD UINT SEMICOLON
		{
			if($3 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS) {
				
				ctx->tab->add_const_int(@1, $1, ctx->tab->ls_int().add(-*$4));	

			}
			else
				ctx->tab->add_const_int(@1, $1, $4);
		}

		| IDENTIFIER EQ OPER_SIGNADD REAL SEMICOLON
		{
			if($3 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS) {

			ctx->tab->add_const_real(@1, $1, ctx->tab->ls_real().add(-*$4));
			}
			else
				ctx->tab->add_const_real(@1, $1, $4);
		}
		| IDENTIFIER EQ IDENTIFIER SEMICOLON
		{
			mlc::symbol_pointer sp = ctx->tab->find_symbol($3);
			if ( sp->kind() != SKIND_CONST ) 
			{ message( DUERR_NOTCONST, @3, * $3); }
			if ( sp->access_const()->type()->cat() == TCAT_INT )
			{
				ctx->tab->add_const_int( @1, $1, sp->access_const()->access_int_const()->int_value());
			}
			else if ( sp->access_const()->type()->cat() == TCAT_REAL )
			{
				ctx->tab->add_const_real( @1, $1, sp->access_const()->access_real_const()->real_value());
			}
			else if ( sp->access_const()->type()->cat() == TCAT_BOOL )
			{
				ctx->tab->add_const_bool( @1, $1, sp->access_const()->access_bool_const()->bool_value());
			}
			else if ( sp->access_const()->type()->cat() == TCAT_STR )
			{
				ctx->tab->add_const_str( @1, $1, sp->access_const()->access_str_const()->str_value());
			}
		}
		|	IDENTIFIER EQ OPER_SIGNADD IDENTIFIER SEMICOLON
		{
			mlc::symbol_pointer sp = ctx->tab->find_symbol($4);
			if ( sp->kind() != SKIND_CONST ) { message( DUERR_NOTCONST, @4, * $4); }
			if ( sp->access_const()->type()->cat() == TCAT_INT )
			{
				mlc::ls_int_index val = sp->access_const()->access_int_const()->int_value();

				auto v = *val;
				if($3 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS)
				{
					v = -*val;
				}
				mlc::ls_int_index nval = ctx->tab->ls_int().add(v);
				ctx->tab->add_const_int( @1, $1, nval);
			}
			else if ( sp->access_const()->type()->cat() == TCAT_REAL )
			{
				mlc::ls_real_index val = sp->access_const()->access_real_const()->real_value();

				auto v = *val;
				if($3 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS)
				{
					v = -*val;
				}
				mlc::ls_real_index nval = ctx->tab->ls_real().add(v);
				ctx->tab->add_const_real( @1, $1, nval);
			}
			else
			{
				message(DUERR_CANNOTCONVERT, @4);
			}
		};

IDEN_loop:	IDENTIFIER	
					{
						std::vector<mlc::ls_id_index> d;
						d.push_back($1);
						mlc::vc v;
						v.ids = d;
						$$ = v;
					}
					 |		IDEN_loop COMMA IDENTIFIER	
					 {
							$1.ids.push_back($3);
							$$ = $1;
					 };

type_identifier:	IDENTIFIER	{
									auto sp = ctx->tab->find_symbol($1);
									if (!sp || (sp->kind() != SKIND_TYPE)) {
										message(DUERR_NOTTYPE, @1, * $1);
									} else {
										auto tr = sp->access_type();
										$$ = tr->type();
									}
								};


btype:	TYPE tLoop
			| 
			;

tLoop:	tLoop IDENTIFIER EQ type SEMICOLON
		{
			ctx->tab->add_type(@2, $2, $4);			
		}
		| IDENTIFIER EQ type SEMICOLON
		{
			ctx->tab->add_type(@1, $1, $3);
		};


bvar: VAR promenne
		   |
		   ;

promenne: promenne malyp | malyp;
malyp: IDENTIFIER COLON type SEMICOLON
		{
			ctx->tab->add_var(@1, $1, $3);
			$$ = $3;
		}
		| IDENTIFIER COMMA malyp
		{
			ctx->tab->add_var(@1, $1, $3);
			$$ = $3;
		
		};

bfunproc:	funproc_h
		|	
		;


funproc_h:		funOrPar SEMICOLON { ctx->tab->enter(@2, $1); } block { ctx->tab->leave(@3); } SEMICOLON { ctx->tab->set_subprogram_code($1, $4); }
			|	funproc_h funOrPar SEMICOLON { ctx->tab->enter(@3, $2); } block { ctx->tab->leave(@4); } SEMICOLON { ctx->tab->set_subprogram_code($2, $5); };

funOrPar:		function_header { $$ = $1; }
  |		procedure_header { $$ = $1; };


function_header:	FUNCTION IDENTIFIER	fp_pars_1 COLON type_identifier	
					{
						ctx->tab->add_fnc(@1, $2, $5, $3);
						$$ = $2;
					};

procedure_header:	PROCEDURE IDENTIFIER fp_pars_1 
					{ 
						ctx->tab->add_proc(@1, $2, $3);
						$$ = $2;
					};


fp_pars_1: LPAR formal_params RPAR { $$ = $2; }
			|	{ $$ = mlc::create_parameter_list(); } ;
					

/*ProcedureHeader: PROCEDURE IDENTIFIER LPAR FormalParameters RPAR 
				{
					auto parList = mlc::create_parameter_list();
					for( auto i = $4.begin(); i != $4.end(); i++) {
						parList->append_and_kill(*i);
					}

					ctx->tab->add_proc(@1, $2, parList);
					ctx->tab->enter(@1, $2);
				}

				 | PROCEDURE IDENTIFIER 
				 {
				     ctx->tab->add_proc(@1, $2, mlc::create_parameter_list());
					 ctx->tab->enter(@1, $2);
				 };

FunctionHeader: FUNCTION IDENTIFIER LPAR FormalParameters RPAR COLON IDENTIFIER
			{
				
				auto parList = mlc::create_parameter_list();
				for( auto i = $4.begin(); i != $4.end(); i++) {
					parList->append_and_kill(*i);
					}

				auto ts = ctx->tab->find_symbol($7)->access_type();
				if (! ts) { message(DUERR_NOTTYPE, @7, * $7);}
				else if (ts->type()->cat() != TCAT_INT &&  ts->type()->cat() != TCAT_REAL && ts->type()->cat() != TCAT_STR && ts->type()->cat() != TCAT_BOOL)
				{message(DUERR_NOTSCALAR, @7, * $7);}
						
				ctx->tab->add_fnc(@1, $2, ts->type(), parList);
				ctx->tab->enter(@1, $2);
			}



				| FUNCTION IDENTIFIER COLON IDENTIFIER
				{
					auto ts = ctx->tab->find_symbol($4)->access_type();
					if (! ts) { message(DUERR_NOTTYPE, @4, * $4);}
					else if (ts->type()->cat() != TCAT_INT &&  ts->type()->cat() != TCAT_REAL && ts->type()->cat() != TCAT_STR && ts->type()->cat() != TCAT_BOOL)
					{message(DUERR_NOTSCALAR, @4, * $4);}
					
				     ctx->tab->add_fnc(@1, $2, ts->type(), mlc::create_parameter_list());
					 ctx->tab->enter(@1, $2);
				 };
*/



/*BlockP: bp1 | bp2 {$$ = $1;};
bp1: LABEL UINT bp1a
	{
		ctx->tab->add_label_entry(@1, $2, ctx->tab->new_label());
	};
bp1a: COMMA UINT bp1a 
	{
		ctx->tab->add_label_entry(@1, $2, ctx->tab->new_label());
	}
	| SEMICOLON bp2;
bp2: CONST constLoop bp3 {$$ = $3;} | bp3 {$$ = $1;};

constLoop:	constLoop cs1
			| cs1;

cs1:	IDENTIFIER EQ UINT SEMICOLON
		{
			ctx->tab->add_const_int(@1, $1, $3);
		}
		| IDENTIFIER EQ REAL SEMICOLON
		{
			ctx->tab->add_const_real(@1, $1, $3);
		}
		| IDENTIFIER EQ STRING SEMICOLON
		{
			ctx->tab->add_const_str(@1, $1, $3);
		}
		| IDENTIFIER EQ OPER_SIGNADD UINT SEMICOLON
		{
			if($3 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS) {
				
				ctx->tab->add_const_int(@1, $1, ctx->tab->ls_int().add(-*$4));	

			}
			else
				ctx->tab->add_const_int(@1, $1, $4);
		}

		| IDENTIFIER EQ OPER_SIGNADD REAL SEMICOLON
		{
			if($3 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS) {

			ctx->tab->add_const_real(@1, $1, ctx->tab->ls_real().add(-*$4));
			}
			else
				ctx->tab->add_const_real(@1, $1, $4);
		}
		| IDENTIFIER EQ IDENTIFIER SEMICOLON
		{
			mlc::symbol_pointer sp = ctx->tab->find_symbol($3);
			if ( sp->kind() != SKIND_CONST ) 
			{ message( DUERR_NOTCONST, @3, * $3); }
			if ( sp->access_const()->type()->cat() == TCAT_INT )
			{
				ctx->tab->add_const_int( @1, $1, sp->access_const()->access_int_const()->int_value());
			}
			else if ( sp->access_const()->type()->cat() == TCAT_REAL )
			{
				ctx->tab->add_const_real( @1, $1, sp->access_const()->access_real_const()->real_value());
			}
			else if ( sp->access_const()->type()->cat() == TCAT_BOOL )
			{
				ctx->tab->add_const_bool( @1, $1, sp->access_const()->access_bool_const()->bool_value());
			}
			else if ( sp->access_const()->type()->cat() == TCAT_STR )
			{
				ctx->tab->add_const_str( @1, $1, sp->access_const()->access_str_const()->str_value());
			}
		}
		|	IDENTIFIER EQ OPER_SIGNADD IDENTIFIER SEMICOLON
		{
			mlc::symbol_pointer sp = ctx->tab->find_symbol($4);
			if ( sp->kind() != SKIND_CONST ) { message( DUERR_NOTCONST, @4, * $4); }
			if ( sp->access_const()->type()->cat() == TCAT_INT )
			{
				mlc::ls_int_index val = sp->access_const()->access_int_const()->int_value();

				auto v = *val;
				if($3 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS)
				{
					v = -*val;
				}
				mlc::ls_int_index nval = ctx->tab->ls_int().add(v);
				ctx->tab->add_const_int( @1, $1, nval);
			}
			else if ( sp->access_const()->type()->cat() == TCAT_REAL )
			{
				mlc::ls_real_index val = sp->access_const()->access_real_const()->real_value();

				auto v = *val;
				if($3 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS)
				{
					v = -*val;
				}
				mlc::ls_real_index nval = ctx->tab->ls_real().add(v);
				ctx->tab->add_const_real( @1, $1, nval);
			}
			else
			{
				message(DUERR_CANNOTCONVERT, @4);
			}
		};



bp3: TYPE tLoop bp4 {$$ = $3; } | bp4 { $$ = $1; };

tLoop:	tLoop IDENTIFIER EQ Type SEMICOLON
		{
			ctx->tab->add_type(@2, $2, $4);			
		}
		| IDENTIFIER EQ Type SEMICOLON
		{
			ctx->tab->add_type(@1, $1, $3);
		};


bp4: VAR promenne bp5 { $$ = $3;} | bp5 {$$ = $1;} ;
promenne: promenne malyp | malyp;
malyp: IDENTIFIER COLON Type SEMICOLON
		{
			ctx->tab->add_var(@1, $1, $3);
			$$ = $3;
		}
		| IDENTIFIER COMMA malyp
		{
			ctx->tab->add_var(@1, $1, $3);
			$$ = $3;
		
		};


bp5: bp5m | bp6 { $$ = $1;} ;
bp5m: bp5ma;
bp5ma: ProcedureHeader  bp5mb  | FunctionHeader bp5mb {ctx->tab->set_subprogram_code($1, $2); } ;
bp5mb: semBlocSem bp5mc {$$ = $1; };
semBlocSem: SEMICOLON Block SEMICOLON 
		{
			ctx->tab->leave(@2); 
			$$ = $2;
		}
bp5mc: bp5ma | bp6;
bp6: BEGIN statements END {$$ = $2; };


Block: b1 | b2 { $$ = $1;};
b1: LABEL UINT b1a
	{
		ctx->tab->add_label_entry(@1, $2, ctx->tab->new_label());
	};
b1a: COMMA UINT b1a 
	{
		ctx->tab->add_label_entry(@1, $2, ctx->tab->new_label());
	}
| SEMICOLON b2;
b2: CONST constLoop b3 {$$ = $3;} 
	| b3 { $$ = $1;} ;

b3: TYPE tLoop b4 {$$ = $3;} 
	| b4 { $$ = $1;};

b4: VAR promenne b5 { $$ = $3;}
	| b5 { $$ = $1;};
b5: BEGIN statements END { $$ = $2;} ;	
*/

real_params:	expression	
			{
				mlc::real_params r;
				r.bpoint = $1.bpoint;
				r.param_types = std::vector<mlc::type_category>{ $1.tc };
				$$ = r;

			}
			|	real_params COMMA expression	
				{
						mlc::real_params r;
						r.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
						$1.param_types.push_back($3.tc);
						r.param_types = $1.param_types;
						$$ = r;
				};



statement:	UINT COLON st2 { $$ = $3; }
		|	st2 { $$ = $1; }
		|	UINT COLON st1 { $$ = $3; }
		|	st1 { $$ = $1; }
		|	{ $$ = mlc::icblock_create(); }
		;


st2:	IF expression THEN st2 ELSE st2
			|	WHILE expression DO st2
			|	IDENTIFIER varWithout_IDEN ASSIGN expression {
				
				auto icblock = mlc::icblock_create();
											
				auto sp = ctx->tab->find_symbol($1);
				if (!sp || (sp->kind() == SKIND_UNDEF || sp->kind() == SKIND_PROCEDURE || sp->kind() == SKIND_PARAMETER_BY_REFERENCE 
					|| sp->kind() == SKIND_TYPE || sp->kind() == SKIND_CONST )) {
						message(DUERR_NOTTYPE, @1, * $1);
						} else if (sp->kind() == SKIND_FUNCTION) {
							if (!ctx->tab->nested() || ($1 != ctx->tab->my_function_name())) {
							message(DUERR_NOTTYPE, @1, * $1);
						} else {
							icblock = mlc::icblock_merge_and_kill(icblock, $4.bpoint);
							auto my_function_type_cat = ctx->tab->find_symbol(ctx->tab->my_function_name())->access_typed()->type()->cat();
							if (my_function_type_cat == TCAT_BOOL) {
								icblock->append<ai::LSTB>(ctx->tab->my_return_address());
							}
							if (my_function_type_cat == TCAT_INT) {
								icblock->append<ai::LSTI>(ctx->tab->my_return_address());
							}
							if (my_function_type_cat == TCAT_REAL) {
								icblock->append<ai::LSTR>(ctx->tab->my_return_address());
							}
							if (my_function_type_cat == TCAT_STR) {
								icblock->append<ai::LSTS>(ctx->tab->my_return_address());
							}
						}
						} else { 
							icblock = mlc::icblock_merge_and_kill(icblock, $4.bpoint);
							auto vs = sp->access_variable();
							auto address = vs->address();
							auto type = vs->type();
							auto cat = type->cat();
							if (cat == TCAT_BOOL) {
								if (sp->kind() == SKIND_GLOBAL_VARIABLE) {
									icblock->append<ai::GSTB>(address);
								} else if (sp->kind() == SKIND_LOCAL_VARIABLE) {
									icblock->append<ai::LSTB>(address);
								}
							}
							if (cat == TCAT_INT) {
								if (sp->kind() == SKIND_GLOBAL_VARIABLE) {
									icblock->append<ai::GSTI>(address);
								} else if (sp->kind() == SKIND_LOCAL_VARIABLE) {
									icblock->append<ai::LSTI>(address);
								}
							}
								if (cat == TCAT_REAL) {
							if ($4.tc == TCAT_INT) {
									icblock->append<ai::CVRTIR>();
							}
							if (sp->kind() == SKIND_GLOBAL_VARIABLE) {
								icblock->append<ai::GSTR>(address);
							} else if (sp->kind() == SKIND_LOCAL_VARIABLE) {
								icblock->append<ai::LSTR>(address);
								}
							}
							if (cat == TCAT_STR) {
								if (sp->kind() == SKIND_GLOBAL_VARIABLE) {
									icblock->append<ai::GSTS>(address);
							} else if (sp->kind() == SKIND_LOCAL_VARIABLE) {
								icblock->append<ai::LSTS>(address);
								}
						}
					}
																					
				$$ = icblock;
	
			}
			|	IDENTIFIER

			{

				auto icblock = mlc::icblock_create();
				auto sp = ctx->tab->find_symbol($1);
				if (!sp || (sp->kind() != SKIND_PROCEDURE)) {
					message(DUERR_NOTTYPE, @1, * $1);
				} else {
					auto sps = sp->access_subprogram();
					icblock = mlc::icblock_merge_and_kill(icblock, mlc::icblock_create());
					icblock->append<ai::CALL>(sps->code());

					for(int i = std::vector<mlc::type_category>().size() - 1; i >= 0; i--) {
							if(std::vector<mlc::type_category>()[i] == TCAT_BOOL) {
								icblock->append<ai::DTORB>();
							}
							if (std::vector<mlc::type_category>()[i] == TCAT_INT) {
								icblock->append<ai::DTORI>();
							}
							if (std::vector<mlc::type_category>()[i] == TCAT_REAL) {
								icblock->append<ai::DTORR>();
							}
							if (std::vector<mlc::type_category>()[i] == TCAT_STR) {
								icblock->append<ai::DTORS>();
							}
						}
					}
				$$ = icblock;	
			
			}

			|	IDENTIFIER LPAR real_params RPAR 
			{
			
			auto icblock = mlc::icblock_create();
												auto sp = ctx->tab->find_symbol($1);
												if (!sp || (sp->kind() != SKIND_PROCEDURE)) {
													message(DUERR_NOTTYPE, @1, * $1);
												} else {
													auto sps = sp->access_subprogram();
													icblock = mlc::icblock_merge_and_kill(icblock, $3.bpoint);
													icblock->append<ai::CALL>(sps->code());

													for(int i = $3.param_types.size() - 1; i >= 0; i--) {
														if($3.param_types[i] == TCAT_BOOL) {
															icblock->append<ai::DTORB>();
														}
														if ($3.param_types[i] == TCAT_INT) {
															icblock->append<ai::DTORI>();
														}
														if ($3.param_types[i] == TCAT_REAL) {
															icblock->append<ai::DTORR>();
														}
														if ($3.param_types[i] == TCAT_STR) {
															icblock->append<ai::DTORS>();
														}
													}
												}
											$$ = icblock;	
			}

			|	GOTO UINT
			|	BEGIN statements END
			|	REPEAT statements UNTIL expression
			|	FOR IDENTIFIER ASSIGN expression FOR_DIRECTION expression DO st2
			;



st1:	IF expression THEN statement
			|	IF expression THEN st2 ELSE st1
			|	WHILE expression DO st1
			|	FOR IDENTIFIER ASSIGN expression FOR_DIRECTION expression DO st1;


varWithout_IDEN:	varWithout_IDEN LSBRA ord_expr_loop RSBRA
				|
				;



type:		type_identifier	{ 
								$$ = $1;
							}
		|	ordinal_type
		|	structured_type
		;

ordinal_type:	ordinal_constant DOTDOT ordinal_constant;

structured_type:	ARRAY LSBRA ordTpLoop RSBRA OF type;



statements:		statement { $$ = $1; }
				|	statements SEMICOLON statement	
				{	
					$$ = mlc::icblock_merge_and_kill($1, $3);
				}
				;

/*OrdTpLoop: OrdinalType 	
			{ 
				$$.push_back($1);  
			} 
		 | OrdTpLoop COMMA OrdinalType
			{
				$$ = $1;
				$$.push_back($3);
			} 
		  | OrdTpLoop COMMA IDENTIFIER
			{
				$$ = $1;
				auto ts = ctx->tab->find_symbol($3)->access_type();
				if (!ts) 
					{ message(DUERR_NOTTYPE, @3, * $3); }
				else if(ts->type()->cat() != TCAT_RANGE) 
					message(DUERR_NOTORDINAL, @3 , *$3); 
				$$.push_back(ts->type());
			}
  		  | IDENTIFIER
			{
				auto ts = ctx->tab->find_symbol($1)->access_type();
				if (!ts) 
					{ message(DUERR_NOTTYPE, @1, * $1); }
				else if(ts->type()->cat() != TCAT_RANGE)
					{message(DUERR_NOTORDINAL, @1 , *$1); }
				$$.push_back(ts->type());
			};
*/

ordTpLoop:	ordinal_type
					|	IDENTIFIER													
					|	ordTpLoop COMMA ordinal_type
					|	ordTpLoop COMMA IDENTIFIER	;

ord_expr_loop:	expression												
				|	ord_expr_loop COMMA expression	;





formal_params:	Evar IDEN_loop COLON type_identifier	
				{
				auto parlist = mlc::create_parameter_list();
				for (std::size_t i = 0; i < $2.ids.size(); ++i) {
					if ($1) {
						parlist->append_parameter_by_reference($2.ids[i], $4);
					} else {
						parlist->append_parameter_by_value($2.ids[i], $4);
					}
				}
				$$ = parlist;
				}
			|	formal_params SEMICOLON Evar IDEN_loop COLON type_identifier
			{
				auto parlist = mlc::create_parameter_list();
				for (std::size_t i = 0; i < $4.ids.size(); ++i) {
					if ($3) {
				parlist->append_parameter_by_reference($4.ids[i], $6);
				} else {
					parlist->append_parameter_by_value($4.ids[i], $6);
					}
				}
					$1->append_and_kill(parlist);
					$$ = $1;
			};

constant:	unsigned_constant 
		|	OPER_SIGNADD UINT 
		|	OPER_SIGNADD REAL ;

unsigned_constant:	IDENTIFIER					
				|	UINT
				|	REAL
				|	STRING ;

ordinal_constant:	OPER_SIGNADD IDENTIFIER				
				|	Eplmin UINT ;



Evar:	VAR { $$ = true; } 
			|	{ $$ = false; };

Eplmin: OPER_SIGNADD	
		{
			mlc::Eplmin m;
			m.b = true;
			m.sign = $1;
			$$ = m;
		}
		|	{
				mlc::Eplmin m;
				m.b = false;
				$$ = m;
			};


expression:		SimpleExpression { $$ = $1; }
			|	SimpleExpression OPER_REL SimpleExpression
			|	SimpleExpression EQ SimpleExpression ;

SimpleExpression:	Eplmin TermLoop	
					{
						if ($1.b && $1.sign == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS) {
							if ($2.tc == TCAT_INT) {
								$2.bpoint->append<ai::MINUSI>();
							}
							if ($2.tc == TCAT_REAL) {
								$2.bpoint->append<ai::MINUSR>();
							}
						}
					$$ = $2;
					};

TermLoop:	term { $$ = $1; }
			|	TermLoop OPER_SIGNADD term	{
													mlc::vys e;
													if ($1.tc == TCAT_STR && $3.tc == TCAT_STR) {
														e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
														e.bpoint->append<ai::ADDS>();
														e.tc = TCAT_STR;
													}
													if ($1.tc == TCAT_INT && $3.tc == TCAT_INT) {
														if ($2 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_PLUS) {
															e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
															e.bpoint->append<ai::ADDI>();
															e.tc = TCAT_INT;
														}
														if ($2 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS) {
															e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
															e.bpoint->append<ai::SUBI>();
															e.tc = TCAT_INT;
														}
													}
													if ($1.tc == TCAT_INT && $3.tc == TCAT_REAL) {
														if ($2 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_PLUS) {
															$1.bpoint->append<ai::CVRTIR>();
															e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
															e.bpoint->append<ai::ADDR>();
															e.tc = TCAT_REAL;
														}
														if ($2 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS) {
															$1.bpoint->append<ai::CVRTIR>();
															e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
															e.bpoint->append<ai::SUBR>();
															e.tc = TCAT_REAL;
														}
													}
													if ($1.tc == TCAT_REAL && $3.tc == TCAT_INT) {
														if ($2 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_PLUS) {
															e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
															e.bpoint->append<ai::CVRTIR>();
															e.bpoint->append<ai::ADDR>();
															e.tc = TCAT_REAL;
														}
														if ($2 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS) {
															e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
															e.bpoint->append<ai::CVRTIR>();
															e.bpoint->append<ai::SUBR>();
															e.tc = TCAT_REAL;
														}
													}
													if ($1.tc == TCAT_REAL && $3.tc == TCAT_REAL) {
														if ($2 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_PLUS) {
															e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
															e.bpoint->append<ai::ADDR>();
															e.tc = TCAT_REAL;
														}
														if ($2 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS) {
															e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
															e.bpoint->append<ai::SUBR>();
															e.tc = TCAT_REAL;
														}
													}
													$$ = e;
												}
			|	TermLoop OR term;

term:	factor { $$ = $1; }
	|	term OPER_MUL factor	{
									mlc::vys e;
									if ($1.tc == TCAT_INT && $3.tc == TCAT_INT) {
										
										if ($2 == mlc::DUTOKGE_OPER_MUL::DUTOKGE_SOLIDUS) {
											$1.bpoint->append<ai::CVRTIR>();
											e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
											e.bpoint->append<ai::CVRTIR>();
											e.bpoint->append<ai::DIVR>();
											e.tc = TCAT_REAL;
										}
										if ($2 == mlc::DUTOKGE_OPER_MUL::DUTOKGE_DIV) {
											e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
											e.bpoint->append<ai::DIVI>();
											e.tc = TCAT_INT;
										}
										if ($2 == mlc::DUTOKGE_OPER_MUL::DUTOKGE_MOD) {
											e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
											e.bpoint->append<ai::MODI>();
											e.tc = TCAT_INT;
										}
										if ($2 == mlc::DUTOKGE_OPER_MUL::DUTOKGE_ASTERISK) {
											e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
											e.bpoint->append<ai::MULI>();
											e.tc = TCAT_INT;
										}
									}
									if ($1.tc == TCAT_INT && $3.tc == TCAT_REAL) {
										
										if ($2 == mlc::DUTOKGE_OPER_MUL::DUTOKGE_SOLIDUS) {
											$1.bpoint->append<ai::CVRTIR>();
											e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
											e.bpoint->append<ai::DIVR>();
											e.tc = TCAT_REAL;
										}
									}
									if ($1.tc == TCAT_REAL && $3.tc == TCAT_INT) {
										if ($2 == mlc::DUTOKGE_OPER_MUL::DUTOKGE_ASTERISK) {
											e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
											$1.bpoint->append<ai::CVRTIR>();
											e.bpoint->append<ai::MULR>();
											e.tc = TCAT_REAL;
										}
										if ($2 == mlc::DUTOKGE_OPER_MUL::DUTOKGE_SOLIDUS) {
											e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
											$1.bpoint->append<ai::CVRTIR>();
											e.bpoint->append<ai::DIVR>();
											e.tc = TCAT_REAL;
										}
										if ($2 == mlc::DUTOKGE_OPER_MUL::DUTOKGE_ASTERISK) {
											$1.bpoint->append<ai::CVRTIR>();
											e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
											e.bpoint->append<ai::MULR>();
											e.tc = TCAT_REAL;
										
										}
									}
									if ($2 == mlc::DUTOKGE_OPER_MUL::DUTOKGE_SOLIDUS) {
											e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
											e.bpoint->append<ai::DIVR>();
											e.tc = TCAT_REAL;
									}
									if ($1.tc == TCAT_REAL && $3.tc == TCAT_REAL) {
										if ($2 == mlc::DUTOKGE_OPER_MUL::DUTOKGE_ASTERISK) {
											e.bpoint = mlc::icblock_merge_and_kill($1.bpoint, $3.bpoint);
											e.bpoint->append<ai::MULR>();
											e.tc = TCAT_REAL;
										}
									
									}
									$$ = e;
								}
	;

factor:		
			
		IDENTIFIER LPAR real_params RPAR 
			{
				auto icblock = mlc::icblock_create();
				mlc::vys e;

				auto sp = ctx->tab->find_symbol($1);
											if (!sp || (sp->kind() != SKIND_FUNCTION )) {
												message(DUERR_NOTTYPE, @1, * $1);
											} else {
												auto sps = sp->access_subprogram();
												auto cat = sp->access_function()->type()->cat();
												
												if (cat == TCAT_INT) {
													icblock->append<ai::INITI>();
												}
												if (cat == TCAT_REAL) {
													icblock->append<ai::INITR>();
												}
												if (cat == TCAT_STR) {
													icblock->append<ai::INITS>();
												}
												if (cat == TCAT_BOOL) {
													icblock->append<ai::INITB>();
												}
												icblock = mlc::icblock_merge_and_kill(icblock, $3.bpoint);
												icblock->append<ai::CALL>(sps->code());

												for(int i = $3.param_types.size() - 1; i >= 0; i--) {
													
													if ($3.param_types[i] == TCAT_INT) {
														icblock->append<ai::DTORI>();
													}
													if ($3.param_types[i] == TCAT_REAL) {
														icblock->append<ai::DTORR>();
													}
													if ($3.param_types[i] == TCAT_STR) {
														icblock->append<ai::DTORS>();
													}
													if($3.param_types[i] == TCAT_BOOL) {
														icblock->append<ai::DTORB>();
													}
												}

												e.tc = cat;
												e.bpoint = icblock;
												$$ = e;
												}
			}

		| IDENTIFIER varWithout_IDEN {
			auto icblock = mlc::icblock_create();
			mlc::vys e;
			auto sp = ctx->tab->find_symbol($1);
			if (!sp || (sp->kind() == SKIND_UNDEF || sp->kind() == SKIND_PARAMETER_BY_REFERENCE || sp->kind() == SKIND_TYPE || sp->kind() == SKIND_CONST )) {
				message(DUERR_NOTTYPE, @1, * $1);
			} else if (sp->kind() == SKIND_FUNCTION) { 
			auto sps = sp->access_subprogram();
			auto cat = sp->access_function()->type()->cat();
			
			if (cat == TCAT_INT) {
				icblock->append<ai::INITI>();
			}
			if (cat == TCAT_REAL) {
				icblock->append<ai::INITR>();
			}
			if (cat == TCAT_STR) {
				icblock->append<ai::INITS>();
			}
			if (cat == TCAT_BOOL) {
				icblock->append<ai::INITB>();
			}
			icblock->append<ai::CALL>(sps->code());
			e.tc = cat;
			} else { 
				auto vs = sp->access_variable();
				auto address = vs->address();
				auto type = vs->type();
				auto cat = type->cat();
				
				if (cat == TCAT_INT) {
						if (sp->kind() == SKIND_GLOBAL_VARIABLE) {
							icblock->append<ai::GLDI>(address);
						} else if (sp->kind() == SKIND_LOCAL_VARIABLE) {
							icblock->append<ai::LLDI>(address);
							}
				}
				if (cat == TCAT_REAL) {
					if (sp->kind() == SKIND_GLOBAL_VARIABLE) {
						icblock->append<ai::GLDR>(address);
						} else if (sp->kind() == SKIND_LOCAL_VARIABLE) {
						icblock->append<ai::LLDR>(address);
					}
				}
				if (cat == TCAT_STR) {
						if (sp->kind() == SKIND_GLOBAL_VARIABLE) {
						icblock->append<ai::GLDS>(address);
							} else if (sp->kind() == SKIND_LOCAL_VARIABLE) {
								icblock->append<ai::LLDS>(address);
							}
				}
				if (cat == TCAT_BOOL) {
					if (sp->kind() == SKIND_GLOBAL_VARIABLE) {
						icblock->append<ai::GLDB>(address);
					} else if (sp->kind() == SKIND_LOCAL_VARIABLE) {
						icblock->append<ai::LLDB>(address);
					}
				}
				e.tc = cat;
			}
				
			e.bpoint = icblock;
			$$ = e;

		}
		|	LPAR expression RPAR { $$ = $2; }
		|	NOT factor
		|	UINT	{
						auto icblock = mlc::icblock_create();
						icblock->append<ai::LDLITI>($1);
						mlc::vys e;
						e.bpoint = icblock;
						e.tc = TCAT_INT;
						$$ = e;
					}
		|	REAL	{
						auto icblock = mlc::icblock_create();
						icblock->append<ai::LDLITR>($1);
						mlc::vys e;
						e.bpoint = icblock;
						e.tc = TCAT_REAL;
						$$ = e;
					}
		|	STRING	{
						auto icblock = mlc::icblock_create();
						icblock->append<ai::LDLITS>($1);
						mlc::vys e;
						e.bpoint = icblock;
						e.tc = TCAT_STR;
						$$ = e;
					};

/*OrdinalConstant: UINT 
					{
						$$ = $1;
					}
				| OPER_SIGNADD UINT
					{
						if($1 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS)
							$$ = ctx->tab->ls_int().add(-*$2);
						else
							$$ = $2;					
					}
				| IDENTIFIER
					{
						mlc::symbol_pointer sp = ctx->tab->find_symbol($1);
						if ( sp->kind() != SKIND_CONST ) 
						{ message( DUERR_NOTCONST, @1, * $1); }
						if ( sp->access_const()->type()->cat() == TCAT_INT )
						{
							$$ = sp->access_const()->access_int_const()->int_value();
						}

						else if ( sp->access_const()->type()->cat() == TCAT_BOOL )
						{
							bool val = sp->access_const()->access_bool_const()->bool_value();

							if(sp->access_const()->access_bool_const()->bool_value() == 1) 
								$$ = ctx->tab->ls_int().add(1);
							else
								$$ = ctx->tab->ls_int().add(0);

						}

						else
							message(DUERR_CANNOTCONVERT, @1);
					}
				| OPER_SIGNADD IDENTIFIER
					{
						mlc::symbol_pointer sp = ctx->tab->find_symbol($2);
						if ( sp->kind() != SKIND_CONST )
						{ message( DUERR_NOTCONST, @2, * $2); }					
						if ( sp->access_const()->type()->cat() == TCAT_INT )
						{
							auto val = sp->access_const()->access_int_const()->int_value();
							if($1 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS)
							{
								$$ = ctx->tab->ls_int().add(-*val);
							}
							else
							{
								$$ = val;
							}
						}
						else 
						{
							message(DUERR_CANNOTCONVERT, @2);
						}
					}
					*/



%%


namespace yy {

	void mlaskal_parser::error(const location_type& l, const std::string& m)
	{
		message(DUERR_SYNTAX, l, m);
	}

}
