//
// The test library.
//
// Copyright © 2018 Kiad Studios. All rights reserved.
//

#pragma once

#define tt_assert(unit_test, message)                                                                                  \
    do {                                                                                                               \
        if (!(unit_test))                                                                                              \
            return __FILE__ ": error:" message;                                                                        \
    } while (0)

#define tt_run_test(unit_test, test_counter, test_fail_counter)                                                        \
    do {                                                                                                               \
        test_counter++;                                                                                                \
                                                                                                                       \
        char *message = unit_test();                                                                                   \
        if (message) {                                                                                                 \
            printf(u8"  𐄂 " #unit_test "\n");                                                                          \
            printf(u8"    → error: %s\n", message);                                                                    \
            test_fail_counter += 1;                                                                                    \
            free(message);                                                                                             \
        }                                                                                                              \
        else {                                                                                                         \
            printf(u8"  ✓ " #unit_test "\n");                                                                          \
        }                                                                                                              \
    } while (0)

#define tt_test_header() printf(u8"‡ tests from " __FILE__ "\n");

#define tt_test_footer(test_counter, test_fail_counter)                                                                \
    printf(u8"\n§ test status (%d of %d) passed.\n", test_counter - test_fail_counter, test_counter);
