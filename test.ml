open OUnit2
open Board
open Playerstate
open Tile 

let start = create_tile "Start" "green" "School starts" 
"You are now a student at Cornell" []
let dummy = init_state "Jason" start

let tile = Tile.create_tile 
    "Tile1" 
    "Red" "Career Fair" 
    "The Career Fair. A place to stand in line, chat with recruiters, and trade resumes for free stuff." 
    ["gain 10"]

let tile2 = Tile.create_tile 
    "Tile2" 
    "Blue" "Career Fair" 
    "The Career Fair. A place to stand in line, chat with recruiters, and trade resumes for free stuff." 
    ["gain 10"]

let dummy_player = init_state "Jason" tile
let test_board = create_board 2

let get_player_name_test 
    (name : string)  
    (st: player)
    (expected_output : string) : test = 
  name >:: (fun _ -> 
      assert_equal expected_output (get_name st))

let get_points_test 
    (name: string)
    (st: player)
    (expected_output: int) : test = 
  name >:: (fun _ ->
      assert_equal expected_output (get_points st))

let tile_color_test (name : string) tile (expected : color) = 
  name >:: (fun _ -> assert_equal expected (get_tile_color tile))

let tile_event_test (name : string) tile expected = 
  name >:: (fun _ -> assert_equal expected (get_tile_event_name tile))

let tile_id_test (name : string) tile (expected : tile_id) = 
  name >:: (fun _ -> assert_equal expected (get_tile_id tile))

let start_tile_test (name : string) (board) (expected) =
  name >:: (fun _ -> assert_equal expected (start_tile board))

let next_tile_test (name : string) (tile) (compare) (board)
    expected =
  name >:: (fun _ ->
      assert_equal expected (next_tile tile compare board))

let test_player = init_state "Player name" tile
let new_tile = go test_player test_board 1; get_current_tile test_player
let two_spaces = go test_player test_board 2; get_current_tile test_player


let go_test (name : string) player board moves expected= 
  name >:: (fun _ -> assert_equal expected (get_current_tile player))

let player_state_test = [
  get_player_name_test "Works?" dummy "Jason";
  get_points_test "Just started, 0" dummy 0; (*
  go_test "go test 1 move" test_player test_board 1 new_tile;
  go_test "go test 2 moves" test_player test_board 1 two_spaces *)
]

let tile_test = [
  tile_color_test "tile is red" tile Red;
  tile_event_test "tile event is career fair" tile2 "Career Fair";
  tile_id_test "tile id is Career Fair Red" tile "Career Fair Red"
]

(* creates a board and runs next tile to get the next board*)
let board_test = [
  (* need a start tile to give to players*)
  start_tile_test "start tile is career fair" test_board tile;
  next_tile_test "first to second 2 tile board"
    tile compare_tiles_id test_board [tile2];
  next_tile_test "second to first 2 tile board"
    tile2 compare_tiles_id test_board [tile];
  (* TODO: test next_tile on a tile w/o adjacent tiles*)
]

let suite =
  "test suite for game"  >::: List.flatten [
    player_state_test;
    tile_test;
    board_test;
  ]

let _ = run_test_tt_main suite
