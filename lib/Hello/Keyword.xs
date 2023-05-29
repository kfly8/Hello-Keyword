#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "XSParseKeyword.h"

#define NEED_newSVpvn_flags
#include "ppport.h"

static const struct XSParseKeywordPieceType pieces_keyword_hello[] = {
  XPK_IDENT,
  XPK_BLOCK,
  {0}
};

static int build_keyword_hello(pTHX_ OP **out, XSParseKeywordPiece *args[], size_t nargs, void *hookdata)
{
  int argi = 0;

  XSParseKeywordPiece *ident = args[argi++];

  SV *hello = newSVpvf("Hello, %s at line %d!\n", SvPV_nolen_const(ident->sv), ident->line);
  OP *print_hello_op = newLISTOP(OP_PRINT, 0, newSTATEOP(0, NULL, 0), newSVOP(OP_CONST, 0, hello));

  XSParseKeywordPiece *block = args[argi++];

  OP *body = op_append_elem(OP_LINESEQ, print_hello_op, block->op);

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
