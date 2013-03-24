#!/bin/sh -e

run_test() {
  local file=$1
  local algorithms=("${!2}")
  local reference=$3
  local print_stats=${4-false}

  local num_vertices=$(sed -n -E -e '/^  [0-9]+;$/p' $file | wc -l)
  local adj_list=$(sed -n -E -e 's/^  ([0-9]) -> ([0-9]);$/\1,\2/p' $file)
  local num_edges=$(echo "$adj_list" | wc -w)

  local expected_cycles=$($reference $num_vertices $adj_list)
  local expected_number_of_cycles=$(echo "$expected_cycles" | wc -l)

  if $print_stats; then
    echo "$num_vertices vertices"
    echo "$num_edges edges"
  fi

  for algo in "${algorithms[@]}"; do
    local actual_cycles=$($algo $num_vertices $adj_list)
    local actual_number_of_cycles=$(echo "$actual_cycles" | wc -l)

    if [ "$expected_cycles" != "$actual_cycles" ]; then
      echo "error: $algo differs from the reference"

      echo "---------------------------------------------"
      echo "expected results (as computed by $reference):"
      echo "expected $expected_number_of_cycles cycles"
      echo "$expected_cycles"
      echo "---------------------------------------------"

      echo "---------------------------------------------"
      echo "actual results (as computed by $algo):"
      echo "got $actual_number_of_cycles cycles"
      echo "$actual_cycles"
      echo "---------------------------------------------"

      exit 1
    fi
  done

  echo "$file finished, found $expected_number_of_cycles cycles"
}

algorithms=(
  "./d2-hawick/circuits_hawick"
  "java -classpath ./meyer de.normalisiert.utils.graphs.TestCycles"
  "python ./tarjan/cycles.py"
  "python ./networkx/cycles.py"
  "./abate/cycles_iter.native"
  "./abate/cycles_functional.native"
)

reference_algorithm=./hawick/circuits_hawick


echo compiling ./hawick/circuits_hawick...
make -C ./hawick >/dev/null
echo compiling ./meyer/de/normalisiert/utils/graphs/TestCycles.class
make -C ./meyer >/dev/null
echo compiling ./abate/cycles_iter.native and ./abate/cycles_functional.native
make -C ./abate >/dev/null
echo compiling ./d2-hawick/circuits_hawick...
make -C ./d2-hawick >/dev/null
echo compiling ./rand_graph.native...
make > /dev/null
echo generating random graphs...
rm -f *.dot
./rand_graph.native $1
echo testing graphs...

counter=0
for file in *.dot; do
  if run_test $file algorithms[@] $reference_algorithm; then
    counter=$((counter+1))
  fi
done
echo successfully tested $counter graphs
