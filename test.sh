#!/bin/sh -e

time_file=.____time_file218h31u2hekqjn89dsa

run_test() {
  local file="$1"
  local algorithms=("${!2}")
  local reference="$3"

  local num_vertices=$(sed -n -E '/^ *[0-9]+ *; *$/p' "$file" | wc -l | tr -d ' ')
  local adj_list=$(sed -n -E 's/^ *([0-9]+) *-> *([0-9]+) *; *$/\1,\2/p' "$file")
  local num_edges=$(echo "$adj_list" | wc -w | tr -d ' ')

  count_cycles() { echo "$1" | wc -l | tr -d ' '; }

  local expected_cycles=$({ time $reference "$num_vertices" $adj_list; } 2>"$time_file")
  local time_taken=$(cat "$time_file")
  local expected_number_of_cycles=$(count_cycles "$expected_cycles")

  echo "testing graph in $file with $num_vertices vertices and $num_edges edges"
  echo "the reference algorithm ($reference) got:"
  echo "$expected_number_of_cycles cycles"
  echo "$time_taken"
  echo

  for algo in "${algorithms[@]}"; do
    local actual_cycles=$({ time $algo "$num_vertices" $adj_list; } 2>"$time_file")
    local time_taken=$(cat "$time_file")
    local actual_number_of_cycles=$(count_cycles "$actual_cycles")

    echo "$algo got:"
    echo "$actual_number_of_cycles cycles"
    echo "$time_taken"
    echo

    if [ "$expected_cycles" != "$actual_cycles" ]; then
      echo "error: $algo differs from the reference"

      echo "expected cycles (as computed by $reference):"
      echo "---------------------------------------------"
      echo "$expected_cycles"
      echo "---------------------------------------------"

      echo "actual cycles (as computed by $algo):"
      echo "---------------------------------------------"
      echo "$actual_cycles"
      echo "---------------------------------------------"

      exit 1
    fi
  done
}

algorithms=(
  "./d2-hawick/circuits_hawick"
  "java -classpath ./meyer de.normalisiert.utils.graphs.TestCycles"
  "python ./tarjan/cycles.py"
  "python ./networkx/cycles.py"
  "./abate/cycles_iter.native"
  "./abate/cycles_functional.native"
)

reference_algorithm="./hawick/circuits_hawick"


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
  if run_test "$file" algorithms[@] "$reference_algorithm"; then
    echo "------------------------------------------------------------------"
    counter=$((counter+1))
  fi
done
rm "$time_file"
echo successfully tested $counter graphs
