(** board type is implemented as an adjacency matrix *)
type 'a t = 'a list list

(** *)
let create x = failwith "notfound"

(** [next_tile tile] is the list of adjacent tiles to [tile] *)
(* should build something to match if length 1, go to the tile, otherwise
   prompt user choice and then go to tile*)
let next_tile tile func board = failwith "notfound"

(* finds the tile in the list that matches and gives the list of adjacent
   tiles*)
let rec find_tile tile board =
  match board with
  | [] -> failwith "notfound"
  | h :: t -> failwith "notfound"

(** TODO: helper for generation tiles and path randomly *)
let randPaths = failwith "notfound"