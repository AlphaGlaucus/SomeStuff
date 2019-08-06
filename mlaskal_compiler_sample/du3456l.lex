
%{
    // this code is emitted into du12l.cpp 
    // avoid macro redefinition warnings when compiling du1l.cpp
    #pragma warning (disable:4005)
    // avoid unreferenced parameter warnings when compiling du1l.cpp
    #pragma warning (disable:4100)
    // avoid unreferenced function warnings when compiling du1l.cpp
    #pragma warning (disable:4505)

    // allow access to YY_DECL macro
    #include "bisonflex.hpp"

    // allow access to custom c++ routines
    #include "du3456sem.hpp"

    // allow access to context 
    // CHANGE THIS LINE TO #include "du3456g.hpp" WHEN THIS FILE IS COPIED TO du3456l.lex
    #include "du3456g.hpp"
%}

/* DO NOT TOUCH THIS OPTIONS! */
%option noyywrap nounput batch noinput stack reentrant
%option never-interactive



WHITESPACE[ \t]


%x STR
%x COMMENT


%%

%{
	typedef yy::mlaskal_parser parser;

	std::string s;
	int i;

%}


<COMMENT,INITIAL>[\n\r\f]		{
		ctx->curline++;

}

'		{
	BEGIN(STR); 
	s="";
}


<STR>[\n\r\f]		{	
	message(mlc::DUERR_EOLINSTRCHR, ctx->curline);
	ctx->curline++;
	BEGIN(INITIAL);
	return  parser::make_STRING(ctx->tab->ls_str().add(s), (ctx->curline - 1));
}

<STR><<EOF>>		{
	message(mlc::DUERR_EOFINSTRCHR, ctx->curline);
	return parser::make_EOF(ctx->curline);
}

<STR>\'\'		{
	s+="\'";
	
}

<STR>'		{

	BEGIN(INITIAL);
	return  parser::make_STRING(ctx->tab->ls_str().add(s), ctx->curline);	
	
}

<STR>.		{
	s+=*yytext;	
}

\}		{
		message(mlc::DUERR_UNEXPENDCMT, ctx->curline);

}

\{		{ BEGIN(COMMENT);
		  i=1;

}

<COMMENT>\{		{
	i++;

}


<COMMENT>\}		{
	i--;
	if(i == 0) {
		BEGIN(INITIAL);	
	}


}

<COMMENT>.		{; }


<COMMENT><<EOF>>		{
	message(mlc::DUERR_EOFINCMT, ctx->curline);
	return parser::make_EOF(ctx->curline);
}



[Pp][Rr][Oo][Gg][Rr][Aa][Mm]		{
	return  parser::make_PROGRAM(ctx->curline);			
}

[Ll][Aa][Bb][Ee][Ll]		{
	return  parser::make_LABEL(ctx->curline);
}

[Cc][Oo][Nn][Ss][Tt]		{
	return  parser::make_CONST(ctx->curline);			
}

[Tt][Yy][Pp][Ee]		{
	return  parser::make_TYPE(ctx->curline);			
}

[Vv][Aa][Rr]		{
	return  parser::make_VAR(ctx->curline);			
}


[Bb][Ee][Gg][Ii][Nn]		{
	return  parser::make_BEGIN(ctx->curline);			
}


[Ee][Nn][Dd]		{
	return  parser::make_END(ctx->curline);			
}


[Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee]		{
	return  parser::make_PROCEDURE(ctx->curline);			
}


[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]		{
	return  parser::make_FUNCTION(ctx->curline);			
}

[Aa][Rr][Rr][Aa][Yy]		{
	return  parser::make_ARRAY(ctx->curline);			
}

[Oo][Ff]		{
	return  parser::make_OF(ctx->curline);			
}

[Gg][Oo][Tt][Oo]		{
	return  parser::make_GOTO(ctx->curline);			
}

[Ii][Ff]		{
	return  parser::make_IF(ctx->curline);			
}

[Tt][Hh][Ee][Nn]		{
	return  parser::make_THEN(ctx->curline);			
}

[Ee][Ll][Ss][Ee]		{
	return  parser::make_ELSE(ctx->curline);				
}

[Ww][Hh][Ii][Ll][Ee]		{
	return  parser::make_WHILE(ctx->curline);			
}

[Dd][Oo]		{
	return  parser::make_DO(ctx->curline);			
}

[Rr][Ee][Pp][Ee][Aa][Tt]		{
	return  parser::make_REPEAT(ctx->curline);			
}

[Uu][Nn][Tt][Ii][Ll]		{
	return  parser::make_UNTIL(ctx->curline);			
}

[Ff][Oo][Rr]		{
	return  parser::make_FOR(ctx->curline);			
}

[Oo][Rr]		{
	return  parser::make_OR(ctx->curline);			
}

[Nn][Oo][Tt]		{
	return  parser::make_NOT(ctx->curline);			
}

[Rr][Ee][Cc][Oo][Rr][Dd]		{
	return  parser::make_RECORD(ctx->curline);			
}






\;		{
	return  parser::make_SEMICOLON(ctx->curline);			
}

\.		{
	return  parser::make_DOT(ctx->curline);			
}

\,		{
	return  parser::make_COMMA(ctx->curline);			
}

\=		{
	return  parser::make_EQ(ctx->curline);			
}

\:		{
	return  parser::make_COLON(ctx->curline);			
}

\(		{
	return  parser::make_LPAR(ctx->curline);			
}

\)		{
	return  parser::make_RPAR(ctx->curline);			
}

\.\.		{
	return  parser::make_DOTDOT(ctx->curline);			
}

\[		{
	return  parser::make_LSBRA(ctx->curline);			
}

\]		{
	return  parser::make_RSBRA(ctx->curline);			
}

\:\=		{
	return  parser::make_ASSIGN(ctx->curline);			
}

\<		{
	return  parser::make_OPER_REL(mlc::DUTOKGE_OPER_REL::DUTOKGE_LT,ctx->curline);	
}

\<\=		{
	return  parser::make_OPER_REL(mlc::DUTOKGE_OPER_REL::DUTOKGE_LE,ctx->curline);	
}

\<\>		{
	return  parser::make_OPER_REL(mlc::DUTOKGE_OPER_REL::DUTOKGE_NE,ctx->curline);	
}

\>\=		{
	return  parser::make_OPER_REL(mlc::DUTOKGE_OPER_REL::DUTOKGE_GE,ctx->curline);	
}

\>		{
	return  parser::make_OPER_REL(mlc::DUTOKGE_OPER_REL::DUTOKGE_GT,ctx->curline);	
}

\+		{
	return  parser::make_OPER_SIGNADD(mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_PLUS,ctx->curline);	
}

\-		{
	return  parser::make_OPER_SIGNADD(mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS,ctx->curline);	
}

\*		{
	return  parser::make_OPER_MUL(mlc::DUTOKGE_OPER_MUL::DUTOKGE_ASTERISK,ctx->curline);	
}

\/		{
	return  parser::make_OPER_MUL(mlc::DUTOKGE_OPER_MUL::DUTOKGE_SOLIDUS,ctx->curline);	
}

[Dd][Ii][Vv]		{
	return  parser::make_OPER_MUL(mlc::DUTOKGE_OPER_MUL::DUTOKGE_DIV,ctx->curline);	
}

[Mm][Oo][Dd]		{
	return  parser::make_OPER_MUL(mlc::DUTOKGE_OPER_MUL::DUTOKGE_MOD,ctx->curline);	
}

[Aa][Nn][Dd]		{
	return  parser::make_OPER_MUL(mlc::DUTOKGE_OPER_MUL::DUTOKGE_AND,ctx->curline);	
}

[Tt][Oo]		{
	return  parser::make_FOR_DIRECTION(mlc::DUTOKGE_FOR_DIRECTION::DUTOKGE_TO,ctx->curline);	
}

[Dd][Oo][Ww][Nn][Tt][Oo]		{
	return  parser::make_FOR_DIRECTION(mlc::DUTOKGE_FOR_DIRECTION::DUTOKGE_DOWNTO,ctx->curline);	
}

(([0-9]+\.[0-9]+([Ee][\+-]?[0-9]+)?)|([0-9]+[Ee][\+-]?[0-9]+))[a-zA-Z]+		{

	message(mlc::DUERR_BADREAL, ctx->curline, yytext);
	std::regex reg ("(([0-9]+\.[0-9]+([Ee][\+-]?[0-9]+)?)|([0-9]+[Ee][\+-]?[0-9]+))([a-zA-Y]+)");
	std::string s = mlc::GetNumberFromWrongNumber(yytext, reg , "$1");
	double doubleNumber;
	try {
		 doubleNumber = stod(s);
	}
	catch(std::exception& e) {
		message(mlc::DUERR_REALOUTRANGE, ctx->curline, s);			
	}

	return  parser::make_REAL(ctx->tab->ls_real().add(doubleNumber), ctx->curline);
}



([0-9]+\.[0-9]+([Ee][\+-]?[0-9]+)?)|([0-9]+[Ee][\+-]?[0-9]+)		{
			
	double doubleNumber;
	try {
		 doubleNumber = std::stod(yytext);
	}
	catch(std::exception& e) {
		message(mlc::DUERR_REALOUTRANGE, ctx->curline, yytext);			
	}
	return  parser::make_REAL(ctx->tab->ls_real().add(doubleNumber), ctx->curline);
}





[a-zA-Z]+[a-zA-Z0-9]*		{

	std::string x = yytext;	

	for(int i=0; i < x.length(); i++) {
	
		x[i] = toupper(yytext[i]);
	}

	return  parser::make_IDENTIFIER(ctx->tab->ls_id().add(x), ctx->curline);			
}

[0-9]+[a-zA-Z]+		{
	message(mlc::DUERR_BADINT, ctx->curline, yytext);
	std::regex reg ("[a-zA-Z]+");
	std::string s = mlc::GetNumberFromWrongNumber(yytext, reg , "");

	bool smallEnough = true;
	std::uint_least64_t number = 0;
	std::uint_least64_t max = 2147483648 - 1;


	const char* cp = s.c_str();

	while (*cp != '\0') {
		number = (number * 10) + (*cp - '0');
		if (number > max)
			smallEnough = false;
		cp++;
	
	}
	
	if(!smallEnough) {
		message(mlc::DUERR_INTOUTRANGE, ctx->curline, yytext);
		number %= (max + 1);
	}

	return parser::make_UINT(ctx->tab->ls_int().add(number), ctx->curline);

}


[0-9]+		{
	bool smallEnough = true;
	std::uint_least64_t number = 0;
	std::uint_least64_t max = 2147483648 - 1;
	char* cp = yytext;

	while (*cp != '\0') {
		number = (number * 10) + (*cp - '0');
		if (number > max)
			smallEnough = false;
		cp++;
	
	}
	
	if(!smallEnough) {
		message(mlc::DUERR_INTOUTRANGE, ctx->curline, yytext);
		number %= (max + 1);
	}

	return parser::make_UINT(ctx->tab->ls_int().add(number), ctx->curline);

}






			
{WHITESPACE}+		/* go out with whitespaces */

.			message(mlc::DUERR_UNKCHAR, ctx->curline, *yytext, *yytext);

<<EOF>>		return parser::make_EOF(ctx->curline);

%%

namespace mlc {

	yyscan_t2 lexer_init(FILE * iff)
	{
		yyscan_t2 scanner;
		yylex_init(&scanner);
		yyset_in(iff, scanner);
		return scanner;
	}

	void lexer_shutdown(yyscan_t2 scanner)
	{
		yyset_in(nullptr, scanner);
		yylex_destroy(scanner);
	}

}
