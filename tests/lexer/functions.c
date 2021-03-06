// Provides the tests for basic function lexing.

static char *to_string(char *s) {
    if (s)
        return s;

    return "";
}

static char *token_to_string(struct token *token) {
    static int max_length = 100;
    char *buffer = malloc(sizeof(char) * max_length);

    char *fmt = "type: %s, value: '%s', offset: %d:%d, line: %d, col: %d";
    int result = snprintf(buffer, max_length, fmt, token_type_to_string(token->type), to_string(token->value),
                          token->location.offset, token->location.length, token->location.line, token->location.column);
    if (result >= 0 && result < max_length) {
        return buffer;
    }

    free(buffer);
    return 0;
}

static char *token_info(struct token *expected, struct token *actual) {
    static int max_length = 255;
    char *buffer = malloc(sizeof(char) * max_length);

    char *expected_str = token_to_string(expected);
    char *actual_str = token_to_string(actual);

    int result =
        snprintf(buffer, max_length, "\n        [expected] %s\n          [actual] %s", expected_str, actual_str);

    if (expected_str)
        free(expected_str);

    if (actual_str)
        free(actual_str);

    if (result >= 0 && result < max_length) {
        return buffer;
    }

    free(buffer);
    return 0;
}

static char *assert_tokens(struct token expected[], struct token *tokens) {
    char *errmsg = 0;
    int idx = 0;
    struct token *token = tokens;

    bool is_finished = false;
    bool has_error = false;
    while (!is_finished) {
        if (expected[idx].type == TOKEN_EOF || token->type == TOKEN_EOF) {
            if (expected[idx].type != TOKEN_EOF || token->type != TOKEN_EOF) {
                has_error = true;
            }
            is_finished = true;
        }
        else if (strcmp(to_string(expected[idx].value), to_string(token->value)) != 0) {
            has_error = true;
        }
        else if (expected[idx].type != token->type) {
            has_error = true;
        }
        else if (expected[idx].location.offset != token->location.offset) {
            has_error = true;
        }
        else if (expected[idx].location.length != token->location.length) {
            has_error = true;
        }
        else if (expected[idx].location.line != token->location.line) {
            has_error = true;
        }
        else if (expected[idx].location.column != token->location.column) {
            has_error = true;
        }

        if (has_error) {
            errmsg = token_info(&expected[idx], token);
            break;
        }

        if (!is_finished) {
            idx++;
            token = token->next;
        }
    }

    return errmsg;
}

static char *test_minimal_func_decl() {
    char *content = "fn f() {}";

    struct token *tokens = tokenize(content);

    static struct token expected_tokens[] = {
        {"fn", TOKEN_KEYWORD, {0, 2, 0, 0}, 0}, {"f", TOKEN_STRING_LITERAL, {3, 1, 0, 0}, 0},
        {0, TOKEN_OPEN_PAREN, {4, 1, 0, 0}, 0}, {0, TOKEN_CLOSE_PAREN, {5, 1, 0, 0}, 0},
        {0, TOKEN_OPEN_BRACE, {7, 1, 0, 0}, 0}, {0, TOKEN_CLOSE_BRACE, {8, 1, 0, 0}, 0},
        {0, TOKEN_EOF, {8, 0, 0, 0}, 0}};

    return assert_tokens(expected_tokens, tokens);
}

static char *test_minimal_func_decl_with_return_type() {
    char *content = "fn f() -> i32 { return 12 }";

    struct token *tokens = tokenize(content);

    static struct token expected_tokens[] = {{"fn", TOKEN_KEYWORD, {0, 2, 0, 0}, 0},
                                             {"f", TOKEN_STRING_LITERAL, {3, 1, 0, 0}, 0},
                                             {0, TOKEN_OPEN_PAREN, {4, 1, 0, 0}, 0},
                                             {0, TOKEN_CLOSE_PAREN, {5, 1, 0, 0}, 0},
                                             {0, TOKEN_OPERATOR_ARROW, {7, 2, 0, 0}},
                                             {"i32", TOKEN_STRING_LITERAL, {10, 3, 0, 0}},
                                             {0, TOKEN_OPEN_BRACE, {14, 1, 0, 0}, 0},
                                             {"return", TOKEN_KEYWORD, {16, 6, 0, 0}},
                                             {"12", TOKEN_NUMBER_LITERAL, {23, 2, 0, 0}},
                                             {0, TOKEN_CLOSE_BRACE, {26, 1, 0, 0}, 0},
                                             {0, TOKEN_EOF, {28, 0, 0, 0}, 0}};

    return assert_tokens(expected_tokens, tokens);
}

static char *test_minimal_func_decl_with_return_type_and_crazy_spacing() {
    char *content = "fn f_g(\n\t\t\ti: i32,\n    foo_bar: f32           )\n\n\t     -> \n   \n   \n i32\n\t\n\t { "
                    "\t\n\n\n\t  \treturn 12 \t\t}";

    struct token *tokens = tokenize(content);

    static struct token expected_tokens[] = {
        {"fn", TOKEN_KEYWORD, {0, 2, 0, 0}, 0},       {"f_g", TOKEN_STRING_LITERAL, {3, 3, 0, 0}, 0},
        {0, TOKEN_OPEN_PAREN, {6, 1, 0, 0}, 0},       {"i", TOKEN_STRING_LITERAL, {11, 1, 0, 0}},
        {0, TOKEN_COLON, {12, 1, 0, 0}, 0},           {"i32", TOKEN_STRING_LITERAL, {14, 3, 0, 0}},
        {0, TOKEN_COMMA, {17, 1, 0, 0}, 0},           {"foo_bar", TOKEN_STRING_LITERAL, {23, 7, 0, 0}},
        {0, TOKEN_COLON, {30, 1, 0, 0}, 0},           {"f32", TOKEN_STRING_LITERAL, {32, 3, 0, 0}},
        {0, TOKEN_CLOSE_PAREN, {46, 1, 0, 0}, 0},     {0, TOKEN_OPERATOR_ARROW, {55, 2, 0, 0}},
        {"i32", TOKEN_STRING_LITERAL, {68, 3, 0, 0}}, {0, TOKEN_OPEN_BRACE, {76, 1, 0, 0}, 0},
        {"return", TOKEN_KEYWORD, {86, 6, 0, 0}},     {"12", TOKEN_NUMBER_LITERAL, {93, 2, 0, 0}},
        {0, TOKEN_CLOSE_BRACE, {98, 1, 0, 0}, 0},     {0, TOKEN_EOF, {30, 0, 0, 0}, 0}};

    return assert_tokens(expected_tokens, tokens);
}
