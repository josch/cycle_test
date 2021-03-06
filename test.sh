#!/bin/sh -e

echo compiling ./hawick/circuits_hawick...
make -C ./hawick >/dev/null

echo compiling ./meyer/de/normalisiert/utils/graphs/TestCycles.class
make -C ./meyer >/dev/null

echo compiling ./abate/cycles_iter.native and ./abate/cycles_functional.native
make -C ./abate >/dev/null

echo compiling ./boost_hawick/hawick_circuits...
make -C ./boost_hawick >/dev/null

echo compiling ./rand_graph.native...
make > /dev/null

echo generating random graphs...
rm -f *.dot
./rand_graph.native $1

echo testing graphs...
counter=0
for f in *.dot; do
  num_vertices=$(sed -n -e '/^  [0-9]\+;$/p' $f | wc -l)
  adj_list=$(sed -n -e 's/^  \([0-9]\) -> \([0-9]\);$/\1 \2/p' $f)

  result_hawick=$(echo "$adj_list" | ./hawick/circuits_hawick $num_vertices)
  result_meyer=$(echo "$adj_list" | java -classpath ./meyer de.normalisiert.utils.graphs.TestCycles $num_vertices)
  result_tarjan=$(echo "$adj_list" | python ./tarjan/cycles.py $num_vertices)
  result_abate_iter=$(echo "$adj_list" | ./abate/cycles_iter.native $num_vertices)
  result_abate_func=$(echo "$adj_list" | ./abate/cycles_functional.native $num_vertices)
  result_networkx=$(echo "$adj_list" | python ./networkx/cycles.py $num_vertices)
  result_boost_hawick=$(echo "$adj_list" | ./boost_hawick/hawick_circuits $num_vertices)

  if [ "$result_hawick" != "$result_meyer" ]; then
  	echo error: hawick differs from meyer
  	exit 1
  fi
  if [ "$result_hawick" != "$result_tarjan" ]; then
  	echo error: hawick differs from tarjan
  	exit 1
  fi
  if [ "$result_hawick" != "$result_abate_iter" ]; then
  	echo error: hawick differs from abate_iter
  	exit 1
  fi
  if [ "$result_hawick" != "$result_abate_func" ]; then
  	echo error: hawick differs from abate_func
  	exit 1
  fi
  if [ "$result_hawick" != "$result_networkx" ]; then
  	echo error: hawick differs from networkx
  	exit 1
  fi
  if [ "$result_hawick" != "$result_boost_hawick" ]; then
    echo error: hawick differs from boost_hawick
    exit 1
  fi
  echo $f okay, $(echo "$result_hawick" | wc -l) cycles
  counter=$((counter+1))
done
echo successfully tested $counter graphs
