// The build file for Proteus.

#include "libs.h"
#include "lexer.c"

static char *PROTC_VERSION = "0.0.1";

void show_help() {
    printf("todo: write the help\n");
    exit(0);
}

void show_version() {
    printf("protc version %s\n", PROTC_VERSION);
    exit(0);
}

int main(int argc, char *argv[]) {
    static struct option options[] = {{"help", no_argument, 0, 'h'},
                                      {"version", no_argument, 0, 'v'},

                                      // the terminator
                                      {0, 0, 0, 0}};

    int c, opt_idx = 0;
    while (1) {
        c = getopt_long(argc, argv, "hv", options, &opt_idx);

        // All done!
        if (c == -1)
            break;

        switch (c) {
        case 'h':
            show_help();
            break;

        case 'v':
            show_version();
            break;

        // the built-in error handling mechanism.
        case '?':
            break;

        // this should never happen, but it if does, crash instead of silently continuing.
        default:
            printf("error: unhandled option '%c'\n", c);
            abort();
        }
    }

    if (optind < argc) {
        printf("non-option elements: ");
        while (optind < argc) {
            tokenize(argv[optind]);
        }
        putchar('\n');
    }

    return 0;
}
