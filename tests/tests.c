// Proteus
#include "../protc/libs.h"
#include "../protc/lexer.c"

// Test Support
#include "testlib.h"

// Tests
#include "lexer/lexer_tests.c"

int main(int argc, char **argv) {
    int number_of_tests_run = 0;
    int number_of_tests_failed = 0;

    tt_test_header();

    LEXER_TESTS(number_of_tests_run, number_of_tests_failed);

    printf(u8"\n§ test status (%d of %d) passed.\n", number_of_tests_run - number_of_tests_failed, number_of_tests_run);

    return number_of_tests_failed != 0;
}