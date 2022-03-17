#!/bin/bash
BENCH_LOC="../benchmark/simple_test"
BENCH_NAME_LOC="riscv32/sim"
BENCH_SUITE=("basic" "medium" "advanced")

rm -f log.txt
for ((i = 0; i < 3; i++))
do
	for src_name in ${BENCH_LOC}/${BENCH_SUITE[$i]}/${BENCH_NAME_LOC}/*
	do
	tmp_file=`basename $src_name`
	trace_name=${tmp_file//.mem/}
	echo $trace_name
	make BENCH_SUITE=${BENCH_SUITE[$i]} BENCH=$trace_name bhv_sim
	if [ $? -ne 0 ]
	then
	echo "${BENCH_SUITE[$i]} $trace_name error" >> log.txt
	else
	echo "${BENCH_SUITE[$i]} $trace_name success" >> log.txt
	fi
	done
done
