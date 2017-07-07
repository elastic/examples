#!/usr/bin/env bash
file_name=$(hexdump -n 4 -e '4/4 "%08X" 1 "\n"' /dev/random)
echo $file_name
bash -c "exec -a $file_name sleep 10"