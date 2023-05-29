#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "XSParseKeyword.h"
//#include "XSParseSublike.h"

#define NEED_newSVpvn_flags
#include "ppport.h"

#define lex_consume_unichar(c)  MY_lex_consume_unichar(aTHX_ c)
static bool MY_lex_consume_unichar(pTHX_ I32 c)
{
  if(lex_peek_unichar(0) != c)
    return FALSE;

  lex_read_unichar(0);
  return TRUE;
}

static const struct XSParseKeywordPieceType pieces_keyword_hello[] = {
  XPK_IDENT,
  {0}
};

static int build_keyword_hello(pTHX_ OP **out, XSParseKeywordPiece *args[], size_t nargs, void *hookdata)
{
  int argi = 0;

  SV *message = args[argi++]->sv;
  if(!message)
    croak("Expected a message after 'keyword_hello'");

  //sv_dump(message);

  if(lex_consume_unichar('{')) {
    ENTER;
  }
  else
    croak("Expected a block");


  I32 save_ix = block_start(TRUE);

  OP *body = parse_stmtseq(0);
  body = block_end(save_ix, body);

  SV *hello = newSVpvf("Hello, %s!\n", SvPV_nolen_const(message));
  OP *newstate = newSTATEOP(0, NULL, 0);
  OP *print_hello_op = newLISTOP(OP_PRINT, 0, newstate, newSVOP(OP_CONST, 0, hello));

  body = op_append_elem(OP_LINESEQ, print_hello_op, body);

  //op_dump(body);

  if(!lex_consume_unichar('}'))
    croak("Expected }");

  LEAVE;

  *out = op_append_elem(OP_LINESEQ,
    newWHILEOP(0, 1, NULL, NULL, body, NULL, 0),
    newSVOP(OP_CONST, 0, &PL_sv_yes));
  return KEYWORD_PLUGIN_STMT;
}


static const struct XSParseKeywordHooks keyword_hello_hooks = {
  .permit_hintkey = "Hello::Keyword/Hello",
  .pieces = pieces_keyword_hello,
  .build = &build_keyword_hello,
};

MODULE = Hello::Keyword    PACKAGE = Hello::Keyword

PROTOTYPES: DISABLE

BOOT:
  boot_xs_parse_keyword(0.33);

  register_xs_parse_keyword("Hello", &keyword_hello_hooks, "Hello");
