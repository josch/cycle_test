open Graph
module G = Pack.Digraph
module Dfs = Graph.Traverse.Dfs(G)

if Array.length Sys.argv != 2 then begin
  Printf.printf "usage: %s max_num_vertices\n" Sys.argv.(0);
  exit 1;
end;

let max_v = int_of_string Sys.argv.(1) in

for v = 1 to max_v do
  let e = ref 1 in
  try
    while true do
      let g = G.Rand.graph ~v ~e:!e () in
      if Dfs.has_cycle g then
        G.dot_output g (Printf.sprintf "graph-%d-%d.dot" v !e);
      incr e;
    done;
  with _ -> ();
done;
