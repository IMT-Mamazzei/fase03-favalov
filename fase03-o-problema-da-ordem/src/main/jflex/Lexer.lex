package br.maua.cic303;
import java_cup.runtime.Symbol;
%%
%class Lexer
%public
%unicode
%cup
%line
%column
%{
    private Symbol symbol(int type) {
        return new Symbol(type, yyline, yycolumn);
    }
    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }
%}
/* ========================================================================= */
/* MACROS                                                                     */
/* ========================================================================= */
LineTerminator      = \r|\n|\r\n
WhiteSpace          = {LineTerminator} | [ \t\f]
Number              = [0-9]+(\.[0-9]+)?([Ee][+-]?[0-9]+)?
Letter              = [a-zA-Z]
Digit               = [0-9]
Identifier          = {Letter}({Letter}|{Digit}|_){0,31}
/* OversizedIdentifier: letra + 32 chars + zero ou mais = 33+ chars no total */
OversizedIdentifier = {Letter}({Letter}|{Digit}|_){32}({Letter}|{Digit}|_)*
%%
/* ========================================================================= */
/* REGRAS LÉXICAS                                                             */
/* ========================================================================= */
<YYINITIAL> {
    /* Ignora espaços em branco */
    {WhiteSpace}    { /* Não faz nada */ }

    /* Palavras Reservadas */
    "if"            { return symbol(sym.IF); }
    "then"          { return symbol(sym.THEN); }
    "else"          { return symbol(sym.ELSE); }
    "while"         { return symbol(sym.WHILE); }

    /* Pontuação */
    "("             { return symbol(sym.LPAREN); }
    ")"             { return symbol(sym.RPAREN); }
    "{"             { return symbol(sym.LBRACE); }
    "}"             { return symbol(sym.RBRACE); }
    ";"             { return symbol(sym.SEMI); }

    /* Operadores Relacionais — DEVEM vir ANTES do "=" simples! */
    "=="            { return symbol(sym.REL_OP, yytext()); }
    "!="            { return symbol(sym.REL_OP, yytext()); }
    "<="            { return symbol(sym.REL_OP, yytext()); }
    ">="            { return symbol(sym.REL_OP, yytext()); }
    "<"             { return symbol(sym.REL_OP, yytext()); }
    ">"             { return symbol(sym.REL_OP, yytext()); }

    /* Atribuição — DEPOIS dos relacionais */
    "="             { return symbol(sym.ASSIGN); }

    /* Operadores Aritméticos */
    "+" | "-"       { return symbol(sym.ADD_OP, yytext()); }
    "*" | "/" | "%" { return symbol(sym.MUL_OP, yytext()); }

    /* Identificador grande demais (> 32 chars) — ANTES do Identifier normal! */
    {OversizedIdentifier} { throw new RuntimeException("Erro Léxico: Identificador gigante -> " + yytext()); }

    /* Identificadores e Números */
    {Identifier}    { return symbol(sym.ID, yytext()); }
    {Number}        { return symbol(sym.NUMBER, yytext()); }

    /* Fallback: caractere não reconhecido */
    .   { throw new RuntimeException("Erro Léxico: Caractere Ilegal -> " + yytext()); }
}
/* Final do arquivo */
<<EOF>>             { return symbol(sym.EOF, ""); }
