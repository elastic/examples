#!/usr/bin/env bash
rm full_stack_example/full_stack_example.*
tar -cvf full_stack_example.tar.gz full_stack_example
zip -r full_stack_example.zip full_stack_example
mv full_stack_example.tar.gz full_stack_example/
mv full_stack_example.zip full_stack_example/
