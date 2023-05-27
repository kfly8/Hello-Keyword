#ifdef __cplusplus
extern "C" {
#endif

#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "XSParseKeyword.h"
//#include "XSParseSublike.h"

#ifdef __cplusplus
} /* extern "C" */
#endif

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

  SV *typename = args[argi++]->sv;
  /* Grrr; XPK bug */
  if(!typename) {
    croak("Expected a type name after 'type'");
  }

  sv_dump(typename);

  /* At this point XS::Parse::Keyword has parsed all it can. From here we will
   * take over to perform the odd "block or statement" behaviour of `class`
   * keywords
   */

  if(lex_consume_unichar('{')) {
    ENTER;
  }
  else {
    croak("Expected a block");
  }

  I32 save_ix = block_start(TRUE);

  OP *body = parse_stmtseq(0);
  body = block_end(save_ix, body);

  op_dump(body);

  if(!lex_consume_unichar('}')) {
    croak("Expected }");
  }

  LEAVE;

  *out = op_append_elem(OP_LINESEQ,
    newWHILEOP(0, 1, NULL, NULL, body, NULL, 0),
    newSVOP(OP_CONST, 0, &PL_sv_yes));
  return KEYWORD_PLUGIN_STMT;
}


static const struct XSParseKeywordHooks keyword_hello_hooks = {
  .permit_hintkey = "Hello::Keyword/keyword_hello",
  .pieces = pieces_keyword_hello,
  .build = &build_keyword_hello,
};

MODULE = Hello::Keyword    PACKAGE = Hello::Keyword

PROTOTYPES: DISABLE

void
hello()
CODE:
{
    ST(0) = newSVpvs_flags("Hello, world!", SVs_TEMP);
}

BOOT:
  boot_xs_parse_keyword(0.33);

  register_xs_parse_keyword("keyword_hello", &keyword_hello_hooks, "keyword_hello");
