// Provides the tests for basic function lexing.

static char *assert_tokens(struct token expected[], struct token *tokens) {
    char *errmsg = 0;
    int idx = 0;
    struct token *token = tokens;
    while (1) {
        if (token == 0) {
            errmsg = "token is a null pointer!";
            break;
        }

        if (expected[idx].type == TOKEN_EOF || token->type == TOKEN_EOF) {
            if (expected[idx].type != TOKEN_EOF || token->type != TOKEN_EOF) {
                errmsg = "tokens differ";
            }
            break;
        }

        if (expected[idx].value != 0 && token->value != 0) {
            errmsg = "tokens differ";
            break;
        }
        if (strcmp(expected[idx].value, token->value) != 0) {
            errmsg = "tokens differ";
            break;
        }
        if (expected[idx].type != token->type) {
            errmsg = "tokens differ";
            break;
        }
        if (expected[idx].location.offset != token->location.offset) {
            errmsg = "tokens differ";
            break;
        }
        if (expected[idx].location.length != token->location.length) {
            errmsg = "tokens differ";
            break;
        }
        if (expected[idx].location.line != token->location.line) {
            errmsg = "tokens differ";
            break;
        }
        if (expected[idx].location.column != token->location.column) {
            errmsg = "tokens differ";
            break;
        }

        idx++;
        token = token->next;
    }

    return errmsg;
}

static char *test_minimal_func_decl() {
    char *content = "fn f() {}";

    struct token *tokens = tokenize(content);

    static struct token expected_tokens[] = {
        {"fn", TOKEN_KEYWORD, {0, 2, 0, 0}, 0},   {"f", TOKEN_STRING_LITERAL, {3, 1, 0, 0}, 0},
        {"(", TOKEN_OPEN_PAREN, {4, 1, 0, 0}, 0}, {")", TOKEN_CLOSE_PAREN, {5, 1, 0, 0}, 0},
        {"{", TOKEN_OPEN_BRACE, {7, 1, 0, 0}, 0}, {"}", TOKEN_CLOSE_BRACE, {8, 1, 0, 0}, 0},
        {0, TOKEN_EOF, {8, 0, 0, 0}, 0}};

    return assert_tokens(expected_tokens, tokens);
}

// fn f() {}
// // #tokens
// // keyword: fn
// // string_literal: f
// // open_paren
// // close_paren
// // open_brace
// // close_brace

// fn f() -> i32 { return 12 }
// // #tokens
// // keyword: fn
// // string_literal: f
// // open_paren
// // close_paren
// // func_return_type_decl
// // string_literal: i32
// // open_brace
// // keyword: return
// // number_literal: 12
// // close_brace

// fn f_g(
//     i: i32,
//     foo_bar: f32           )

//     ->

//                     f32
//     {

//                     return i * foo_bar/3.1234567891234}
// // #tokens
// // keyword: fn
// // string_literal: f_g
// // open_paren
// // string_literal: i
// // type_decl
// // string_literal: i32
// // comma
// // string_literal: foo_bar
// // type_decl
// // string_literal: f32
// // close_paren
// // func_return_type_decl
// // string_literal: f32
// // open_brace
// // keyword: return
// // string_literal: i
// // operator_*
// // string_literal: foo_bar
// // operator_/
// // number_literal: 3.1234567891234
// // close_brace
