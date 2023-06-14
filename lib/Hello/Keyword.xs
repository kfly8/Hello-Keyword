#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "XSParseKeyword.h"

#define NEED_newSVpvn_flags
#include "ppport.h"

SV* my_parse_block_body(pTHX_) {
    char* start = NULL;
    char* end = NULL;
    I32 c;
    I32 block_start_depth = 0;
    I32 block_end_depth = 0;

    while ((c = lex_peek_unichar(0)) != EOF) {
        if (c == '{') {
            block_start_depth++;
            if (block_start_depth == 1) {
                start = PL_parser->bufptr;
            }
        }

        if (c == '}') {
            block_end_depth++;
            if (block_start_depth == block_end_depth) {
                end = PL_parser->bufptr;
            }
        }

        lex_read_unichar(0);

        if (start && end) {
            break;
        }
    }

    if (!start) {
        croak("not found block start");
    }

    if (!end) {
        croak("not found block end");
    }

    // Increment and decrement to ignore the brackets themselves
    start++;
    end--;

    if (end < start) {
        croak("illegal block");
    }

    STRLEN len = end - start + 1;
    SV *block = sv_2mortal(newSV(len));
    sv_setpvn(block, start, len);

    return block;
}


static const struct XSParseKeywordPieceType pieces_keyword_type[] = {
  XPK_IDENT,
  {0}
};

static int build_keyword_type(pTHX_ OP **out, XSParseKeywordPiece *args[], size_t nargs, void *hookdata)
{
  int argi = 0;

  XSParseKeywordPiece *ident = args[argi++];

  SV *hello = newSVpvf("Hello, %s at line %d\n", SvPV_nolen_const(ident->sv), ident->line);
  OP *print_hello_op = newLISTOP(OP_PRINT, 0, newSTATEOP(0, NULL, 0), newSVOP(OP_CONST, 0, hello));

  SV *body = my_parse_block_body(aTHX_);
  SV *mybody = newSVpvf("BODY: %s\n", SvPV_nolen_const(body));
  OP *print_body_op = newLISTOP(OP_PRINT, 0, newSTATEOP(0, NULL, 0), newSVOP(OP_CONST, 0, mybody));

  OP *myop = op_append_elem(OP_LINESEQ, print_hello_op, print_body_op);

  *out = op_append_elem(OP_LINESEQ,
    newWHILEOP(0, 1, NULL, NULL, myop, NULL, 0),
    newSVOP(OP_CONST, 0, &PL_sv_yes));

//  op_dump(*out);

  return KEYWORD_PLUGIN_STMT;
}


static const struct XSParseKeywordHooks keyword_type_hooks = {
  .permit_hintkey = "Hello::Keyword/type",
  .pieces = pieces_keyword_type,
  .build = &build_keyword_type,
};

MODULE = Hello::Keyword    PACKAGE = Hello::Keyword

PROTOTYPES: DISABLE

BOOT:
  boot_xs_parse_keyword(0.33);

  register_xs_parse_keyword("type", &keyword_type_hooks, "type");
