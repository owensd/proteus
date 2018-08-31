#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import os
import re


def parse_invocations(path):
    # #     tt_run_test(test_minimal_func_decl, number_of_tests_run, number_of_tests_failed);                                  \
    with open(path, 'r') as content:
        test_funcs = re.findall(
            r'static char ?\* ?test_([\w_]+)\(', content.read())
    return ["    tt_run_test(test_{}, number_of_tests_run, number_of_tests_failed);".format(fn) for fn in test_funcs]


parser = argparse.ArgumentParser(
    description='Generate the test invocation files.')
parser.add_argument('-i', '--additional-include', dest='includes', action='append',
                    help='the path of the file to include at the top of the generated test file')
parser.add_argument('-t', '--test-dir', dest='test_dir', required=True,
                    help='the base path for the tests directory')
parser.add_argument('-o', dest='output_path', required=True,
                    help='the path to output the generated test source file')
parser.add_argument('-p', '--include-prefix', dest='include_prefix',
                    default='', help='the path to prefix before all include directives')
args = parser.parse_args()

test_file_lines = []
test_file_lines.append('// this is a generated file, DO NOT MODIFY!!')
test_file_lines.append('')

additional_includes = []
test_invocations = []

test_file_lines.append('// includes specified from tool invocation')
for include in args.includes:
    test_file_lines.append('#include "{}{}"'.format(
        args.include_prefix, include))

# generate each of the test sections based on the presence of a .c file.
for root, _, files in os.walk(args.test_dir):
    for file in [f for f in files if os.path.splitext(f)[1] == '.c']:
        path = os.path.join(root, file)
        additional_includes.append(path)
        test_invocations += parse_invocations(path)


test_file_lines.append('')
test_file_lines.append('// test file includes')
for include in additional_includes:
    test_file_lines.append('#include "{}{}"'.format(
        args.include_prefix, include))

test_file_lines.append('')
test_file_lines.append('int main(int argc, char **argv) {')
test_file_lines.append('    int number_of_tests_run = 0;')
test_file_lines.append('    int number_of_tests_failed = 0;')
test_file_lines.append('')
test_file_lines.append('    tt_test_header();')
test_file_lines.append('')

test_file_lines.append('    // test invocations')
for invocation in test_invocations:
    test_file_lines.append(invocation)

test_file_lines.append('')
test_file_lines.append(
    '    tt_test_footer(number_of_tests_run, number_of_tests_failed);')
test_file_lines.append('')
test_file_lines.append('    return number_of_tests_failed != 0;')
test_file_lines.append('}')

# ensure there is always a blank line
test_file_lines.append('')

test_file_path = os.path.realpath(args.output_path)
with open(test_file_path, 'w') as test_file:
    test_file.write('\n'.join(test_file_lines))
