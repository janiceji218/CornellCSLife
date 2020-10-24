open Event
open Tile

(** board type is implemented as an adjacency list *)
type gameboard = (Tile.tile * (Tile.tile list)) list

exception No_Tile of string
(** TODO: helper for generation tiles and path randomly *)
(* let rand_paths = failwith "not_found" *)

let event =
  create_event "Career Fair"
    "10"
    "The Career Fair. A place to stand in line, chat with recruiters, and trade resumes for free stuff."
    (Points [("Gain", 10)])

(* should ids be strings or numbers?*)
let tile = Tile.create_tile Red event "Career Fair Red"
let tile2 = Tile.create_tile Blue event "Career Fair Blue"

let test_board = [(tile,[tile2]);(tile2,[tile])]

(* how to create boards:
   function to
   Generate tiles from a list of different tiles with events
   - automatically gives them a numerical string id by order of generation
     -
     tiles = [
      [color, event, neighbors, numoccur];
      [color, event, neighbors, numoccur];
     ]
     thinking we should add tile neighbors to the tile module
     Generate board using those tiles *)

let create_board x = 
  test_board
(*
   match x with
| 0 -> acc
| x -> create (x-1) (tile :: acc)
*)

let start_tile (board : gameboard) = 
  match board with
  | [] -> raise (No_Tile "Board has no start tile")
  | h :: t -> fst h

let rec find_tile (tile : Tile.tile) func (board : gameboard) =
  match board with
  | [] -> raise (No_Tile "No such tile exists in the given board")
  | (a, b) :: t -> if func a tile then b else find_tile tile func t

(** [next_tile tile func board] is the list of adjacent tiles to [tile]
    [func tile1 tile2] is a function used to compare tiles *)
let next_tile = find_tile
