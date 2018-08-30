// This file converts the text into a series of tokens.

enum token_type {
    // It's important to keep the EOF token here to ensure that zero'd out structs get EOF as the value.
    TOKEN_EOF,

    TOKEN_KEYWORD,
    TOKEN_OPEN_PAREN,
    TOKEN_CLOSE_PAREN,
    TOKEN_OPEN_BRACE,
    TOKEN_CLOSE_BRACE,
    TOKEN_COMMA,
    TOKEN_FUNC_RETURN_TYPE_DECL,
    TOKEN_NUMBER_LITERAL,
    TOKEN_STRING_LITERAL,
    TOKEN_EQUAL,
    TOKEN_COLON,

    TOKEN_OPERATOR_PLUS,
    TOKEN_OPERATOR_MINUS,
    TOKEN_OPERATOR_MULT,
    TOKEN_OPERATOR_DIV,
    TOKEN_OPERATOR_MOD,
    TOKEN_OPERATOR_DOT,
    TOKEN_OPERATOR_ARROW,
    TOKEN_OPERATOR_EQUALS
};

struct location {
    int offset;
    int length;

    // these can be computed, so maybe store them elsewhere.
    int line;
    int column;
};

struct token {
    char *value;
    enum token_type type;
    struct location location;
    struct token *next;
};

char peek(const char *s, size_t len, size_t n) {
    if (n < len) {
        return s[n];
    }
    return '\0';
}

char next(const char *s, size_t len, size_t n) { return peek(s, len, n + 1); }

bool is_keyword(const char *s) {
    // todo: convert this to a hash and do a binary search across the table or implement an O(1) hash.
    if (strcmp(s, "fn") == 0)
        return true;
    if (strcmp(s, "return") == 0)
        return true;

    return false;
}

bool is_whitespace(char c) { return c == ' ' || c == '\t' || c == '\n' || c == '\r'; }
bool is_digit(char c) {
    int n = c - '0';
    return n >= 0 && n <= 9;
}
bool is_lower(char c) { return c >= 'a' && c <= 'z'; }
bool is_upper(char c) { return c >= 'A' && c <= 'Z'; }
bool is_char(char c) { return is_lower(c) || is_upper(c); }

struct token *tokenize(char *content) {
    // This mechanism currently loads the entire file into memory, which is not the optimal way to do this,
    // but it is very expedient.
    struct token *head_token = 0;
    struct token *token = 0;
    struct token *prev_token = 0;
    bool done = false;

    size_t content_length = strlen(content);

    size_t idx = 0;
    size_t length = 0;

    while (!done) {
        if (content[idx] == '\0') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_EOF;
            token->location.offset = idx;

            done = true;
        }
        else if (content[idx] == '(') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_OPEN_PAREN;
            token->location.offset = idx;
            token->location.length = 1;
            length += 1;
        }
        else if (content[idx] == ')') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_CLOSE_PAREN;
            token->location.offset = idx;
            token->location.length = 1;
            length += 1;
        }
        else if (content[idx] == '{') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_OPEN_BRACE;
            token->location.offset = idx;
            token->location.length = 1;
            length += 1;
        }
        else if (content[idx] == '}') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_CLOSE_BRACE;
            token->location.offset = idx;
            token->location.length = 1;
            length += 1;
        }
        else if (content[idx] == ',') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_COMMA;
            token->location.offset = idx;
            token->location.length = 1;
            length += 1;
        }
        else if (content[idx] == ':') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_COLON;
            token->location.offset = idx;
            token->location.length = 1;
            length += 1;
        }
        else if (content[idx] == '+') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_OPERATOR_PLUS;
            token->location.offset = idx;
            token->location.length = 1;
            length += 1;
        }
        else if (content[idx] == '-') {
            if (next(content, content_length, idx) == '>') {
                token = calloc(1, sizeof(struct token));
                token->type = TOKEN_OPERATOR_ARROW;
                token->location.offset = idx;
                token->location.length = 2;
                length += 2;
            }
            else {
                token = calloc(1, sizeof(struct token));
                token->type = TOKEN_OPERATOR_MINUS;
                token->location.offset = idx;
                token->location.length = 1;
                length += 1;
            }
        }
        else if (content[idx] == '=') {
            if (next(content, content_length, idx) == '=') {
                token = calloc(1, sizeof(struct token));
                token->type = TOKEN_OPERATOR_EQUALS;
                token->location.offset = idx;
                token->location.length = 2;
                length += 2;
            }
            else {
                token = calloc(1, sizeof(struct token));
                token->type = TOKEN_EQUAL;
                token->location.offset = idx;
                token->location.length = 1;
                length += 1;
            }
        }
        else if (content[idx] == '*') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_OPERATOR_MULT;
            token->location.offset = idx;
            token->location.length = 1;
            length += 1;
        }
        else if (content[idx] == '/') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_OPERATOR_DIV;
            token->location.offset = idx;
            token->location.length = 1;
            length += 1;
        }
        else if (content[idx] == '%') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_OPERATOR_MOD;
            token->location.offset = idx;
            token->location.length = 1;
            length += 1;
        }
        else if (content[idx] == '.') {
            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_OPERATOR_DOT;
            token->location.offset = idx;
            token->location.length = 1;
            length += 1;
        }
        else if (is_whitespace(content[idx])) {
            length += 1;
        }
        else if (is_char(content[idx])) {
            length = 1;
            while (true) {
                char c = peek(content, content_length, idx + length);
                if (is_char(c) || is_digit(c) || c == '_') {
                    length++;
                }
                else {
                    break;
                }
            }

            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_STRING_LITERAL;
            token->value = calloc(length + 1, sizeof(char));
            strncpy(token->value, &content[idx], length);
            token->location.offset = idx;
            token->location.length = length;

            if (is_keyword(token->value))
                token->type = TOKEN_KEYWORD;
        }
        else if (is_digit(content[idx])) {
            length = 1;

            bool dot_seen = false;
            while (true) {
                char c = peek(content, content_length, idx + length);
                if (is_digit(c) || c == '.') {
                    if (dot_seen)
                        break;
                    if (c == '.')
                        dot_seen = true;

                    length++;
                }
                else {
                    break;
                }
            }

            token = calloc(1, sizeof(struct token));
            token->type = TOKEN_NUMBER_LITERAL;
            token->value = calloc(length + 1, sizeof(char));
            strncpy(token->value, &content[idx], length);
            token->location.offset = idx;
            token->location.length = length;
        }
        else {
            // skip other stuff for now
            length += 1;
        }

        if (!head_token)
            head_token = token;

        if (prev_token) {
            prev_token->next = token;
        }

        prev_token = token;
        idx += length;
        length = 0;
    }

    return head_token;
}