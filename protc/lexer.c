// This file converts the text into a series of tokens.

enum token_type {
    // It's important to keep the EOF token here to ensure that zero'd out structs get EOF as the value.
    TOKEN_EOF,

    TOKEN_KEYWORD,
    TOKEN_OPEN_PAREN,
    TOKEN_CLOSE_PAREN,
    TOKEN_OPEN_BRACE,
    TOKEN_CLOSE_BRACE,
    TOKEN_FUNC_RETURN_TYPE_DECL,
    TOKEN_INTEGER_LITERAL,
    TOKEN_FLOAT_LITERAL,
    TOKEN_STRING_LITERAL
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

struct token *tokenize(char *content) {
    // This mechanism currently loads the entire file into memory, which is not the optimal way to do this,
    // but it is very expedient.
    struct token *token = calloc(1, sizeof(struct token));

    // todo: actually tokenize the content! =)

    return token;
}