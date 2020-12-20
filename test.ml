open OUnit2
open Board
open Playerstate
open Tile
(**---------TEST PLAN--------------- 
   what you tested, anything you omitted testing, and why you believe 
   that your test suite demonstrates the correctness of your system.

   -1: The test plan does not explain which parts of the system were 
   automatically tested by OUnit vs. manually tested.
   -1: The test plan does not explain what modules were tested by OUnit 
   and how test cases were developed (black box, glass box, randomized, etc.).
   -1: The test plan does not provide an argument for why the testing 
   approach demonstrates the correctness of the system.

   All functions documented in the mli files of modules tile, board, and 
   playerstate are tested here using OUnit, with the exception of print_state 
   and make_player_list from playerstate.mli . Those two and some more 
   complicated cases of functions, such as branching paths for go, were tested 
   manually as well, since they often required input from the terminal.

   How test cases developed (Black box, glass box, etc) 

   Why does testing approach demonstrate correctness of system?

   -------------------------------------*)

(** [pp_string s] pretty-prints string [s]. *)
let pp_string s = "\"" ^ s ^ "\""

(** [pp_list pp_elt lst] pretty-prints list [lst], using [pp_elt]
    to pretty-print each element of [lst]. *)
let pp_list pp_elt lst =
  let pp_elts lst =
    let rec loop n acc = function
      | [] -> acc
      | [h] -> acc ^ pp_elt h
      | h1 :: (h2 :: t as t') ->
        if n = 100 then acc ^ "..."  (* stop printing long list *)
        else loop (n + 1) (acc ^ (pp_elt h1) ^ "; ") t'
    in loop 0 "" lst
  in "[" ^ pp_elts lst ^ "]"

let tile1 = Tile.create_tile 
    "Tile1" 
    "Red" "Career Fair" 
    "The Career Fair. A place to stand in line, chat with recruiters, and trade resumes for free stuff." 
    ["gain 10"]

let tile2 = Tile.create_tile 
    "Tile2" 
    "Blue" "Prelims" 
    "Prelims. A time to shut yourself in your room to study and hopefully pass all your classes." 
    ["lose 15"]

let tile_proj = Tile.create_tile 
    "Make a project" "Green" "Start your own project"
    "You have started making your own CS project. You plan to show it off in your resume and gain some good technical experience"
    ["gain 100"; "minigame choose_project"]

let tile_start = Tile.create_tile "start" "Black" "Start Tile" "Start Tile"
    ["gain 0"]

let tile_id_test (name : string) tile (expected : tile_id) = 
  name >:: (fun _ -> assert_equal expected (get_tile_id tile))

let tile_color_test (name : string) tile (expected : color) = 
  name >:: (fun _ -> assert_equal expected (get_tile_color tile))

let tile_event_name_test (name : string) tile (expected: string) = 
  name >:: (fun _ -> assert_equal expected (get_tile_event_name tile))

let tile_description_test (name : string) tile (expected : string) = 
  name >:: (fun _ -> assert_equal expected (get_tile_description tile))

let get_effects_test (name: string) (str : string) (expected : effect) = 
  name >:: (fun _ -> assert_equal expected (get_effects str))

let tile_effects_test (name : string) tile (expected : effect list) =
  name >:: (fun _ -> assert_equal expected (get_tile_effects tile))

let get_effect_desc_test name effect (expected: string) = 
  name >:: (fun _ -> assert_equal expected (get_effect_desc effect))

let tile_test = [
  tile_color_test "Red tile" tile1 Red;
  tile_color_test "Blue tile" tile2 Blue;
  tile_color_test "proj green tile" tile_proj Green;
  tile_color_test "start tile" tile_start Black;
  tile_event_name_test "career fair event" tile1 "Career Fair";
  tile_event_name_test "prelims event" tile2 "Prelims";
  tile_event_name_test "proj event" tile_proj "Start your own project";
  tile_event_name_test "start event" tile_start "Start Tile";
  tile_id_test "tile1 id" tile1 "Tile1";
  tile_id_test "tile12 id" tile2 "Tile2";
  tile_id_test "proj tile" tile_proj "Make a project";
  tile_id_test "start tile" tile_start "start";
  tile_description_test "tile1 description" tile1 "The Career Fair. A place to stand in line, chat with recruiters, and trade resumes for free stuff.";
  tile_description_test "tile2 description" tile2 "Prelims. A time to shut yourself in your room to study and hopefully pass all your classes.";
  tile_description_test "proj tile desc" tile_proj "You have started making your own CS project. You plan to show it off in your resume and gain some good technical experience";
  tile_description_test "start tile desc" tile_start "Start Tile";
  get_effects_test "gain 55 points effect" "gain 55" (Points ("Gained", 55)); 
  get_effects_test "lose 2 points effect" "lose 2" (Points ("Lost", 2));
  get_effects_test "1110 minigame" "minigame 1110" (Minigame "1110");
  get_effects_test "3 study partners" "study_partner 3" (Study_Partner 3);
  get_effects_test "item" "item laptop" (Item "laptop");
  get_effects_test "energy" "energy -29" (Energy ~-29);
  tile_effects_test "tile1 effects" tile1 [Points ("Gained", 10)]; 
  tile_effects_test "tile2 effects" tile2 [Points ("Lost", 15)]; 
  tile_effects_test "project tile effects" tile_proj 
    [Points ("Gained", 100); Minigame "choose_project"];
  tile_effects_test "start tile effects" tile_start [Points ("Gained", 0)]; 
  get_effect_desc_test "gain 55 points" (Points ("Gained", 55)) 
    "Gained 55 points\n";
  get_effect_desc_test "minigame event" (Minigame "3410") "Special Event!\n" ;
  get_effect_desc_test "lose 1 point" (Points ("Lost", 10)) "Lost 10 points\n";
  get_effect_desc_test "none" None "";
  get_effect_desc_test "energy" (Energy 10) "Your energy level changed\n";
  get_effect_desc_test "item" (Item "hi") 
    "You received hi! Added to your items\n";
]
let test_board = create_board (Yojson.Basic.from_file "gameboard1.json")
let start = start_tile test_board
let last = end_tile test_board

(* helper for comparing Tile.tile lists, get tile_id list for non-abstract 
   types,easier comparison *)
let rec tile_id_list acc (lst: Tile.tile list)= match lst with
  | [] -> acc
  | h :: t -> tile_id_list (Tile.get_tile_id h :: acc) t

let start_tile_test (name : string) (board : gameboard) (expected : string) =
  name >:: (fun _ -> assert_equal expected (get_tile_id (start_tile board)))

let end_tile_test (name : string) (board: gameboard) (expected: string) =
  name >:: (fun _ -> assert_equal expected (get_tile_id (end_tile board)))

let next_tile_test (name : string) tile compare board (expected) =
  let next_tiles_id_list = tile_id_list [] (next_tiles tile compare board) in 
  name >:: (fun _ ->
      assert_equal expected next_tiles_id_list)

let find_tile_by_id_test (name: string) id board expected =
  let found_id = find_tile_by_id id board |> get_tile_id in
  name >:: (fun _ -> assert_equal expected found_id)

let compare_tiles_id_test (name: string) tile_f tile_s (expected : bool) 
  = name >:: (fun _ -> assert_equal expected (compare_tiles_id tile_f tile_s))

let board_test = [
  start_tile_test "start tile is start" test_board "start";
  end_tile_test "end tile is graduation" test_board "Graduation";
  compare_tiles_id_test "start and end tile" start last false;
  compare_tiles_id_test "start tile same id compare" start start true;
  next_tile_test "first to second 2 tile board" start compare_tiles_id 
    test_board ["choose 1110 or 2110"];
  next_tile_test "next tile for end tile" last compare_tiles_id 
    test_board [];  
  find_tile_by_id_test "1110 waiting in board" "1110 waiting spot" test_board 
    "1110 waiting spot";
  find_tile_by_id_test "CS 2800 final find tile id" "CS 2800 final" test_board 
    "CS 2800 final";
  find_tile_by_id_test "3110 find tile id" "CS 3110 A0" test_board 
    "CS 3110 A0";
  "tile id not in board" >:: 
  (fun _ -> assert_raises (No_Tile "No such tile exists in the given board") 
      (fun () -> find_tile_by_id "hi there" test_board));
  compare_tiles_id_test "tile1, tile2 compare" tile1 tile2 false;
  compare_tiles_id_test "proj, start" tile_proj tile_start false;
  compare_tiles_id_test "start in board, tile_start compare" start tile_start 
    true; 
]

let get_player_name_test 
    (name : string)  
    (st: player)
    (expected_output : string) : test = 
  name >:: (fun _ -> 
      assert_equal expected_output (get_name st)) 

let get_nth_player_test 
    (name: string)
    (players: player list)
    (n : int)
    (expected : player) : test = 
  name >:: (fun _ -> 
      assert_equal expected (get_nth_player players n)) 

let get_points_test 
    (name: string)
    (st: player)
    (expected_output: int) : test = 
  name >:: (fun _ ->
      assert_equal expected_output (get_points st))

let get_points_set_test 
    (name: string)
    (st: player)
    (pt: int)
    (expected_output: int) : test = 
  name >:: (fun _ ->
      Playerstate.set_points st pt; 
      assert_equal expected_output (get_points st))

let get_study_partners_test 
    (name: string)
    (st: player)
    (expected_output: study_partners) : test = 
  name >:: (fun _ ->
      assert_equal expected_output (get_study_partners st))

let get_study_partners_set_test 
    (name: string)
    (st: player)
    (num : int)
    (expected_output: study_partners) : test = 
  name >:: (fun _ ->
      Playerstate.add_study_partners st num;
      assert_equal expected_output (get_study_partners st))

let get_project_test 
    (name: string)
    (st: player)
    (expected_output: project) : test = 
  name >:: (fun _ ->
      assert_equal expected_output (get_project st))

let get_project_set_test 
    (name: string)
    (st: player)
    (proj_name : string)
    (desc : string)
    (salary : int)
    (expected_output: project) : test = 
  name >:: (fun _ ->
      Playerstate.set_project st (Some(proj_name, desc, salary)); 
      assert_equal expected_output (get_project st))

let get_salary_test
    (name: string) 
    (st: player) 
    (expected) = 
  name >:: (fun _ -> 
      assert_equal expected (get_salary st))

let get_current_tile_test 
    (name: string)
    (st: player)
    (expected_output: tile_id) : test = 
  name >:: (fun _ ->
      print_endline ("id from tile in test: " ^ (get_current_tile st 
                                                 |> get_tile_id)); 
      assert_equal expected_output (get_current_tile st 
                                    |> get_tile_id))

let get_visited_tiles_test
    (name: string)
    (st: player)
    (expected_output: tile_id list) : test = 
  name >:: (fun _ ->
      assert_equal expected_output (st 
                                    |> get_visited_tiles))

let get_visited_tiles_after_go_test
    (name: string)
    (st: player)
    (steps: int)
    (expected_output: tile_id list) : test = 
  name >:: (fun _ ->
      go st test_board steps; 
      assert_equal expected_output (st |> get_visited_tiles) 
        ~printer:(pp_list pp_string))

let get_items_test 
    (name: string)
    (st: player)
    (expected_output: string list) : test = 
  name >:: (fun _ ->
      assert_equal expected_output (get_items st))     

let get_items_set_test 
    (name: string)
    (st: player)
    (item: string)
    (expected_output: string list) : test = 
  name >:: (fun _ ->
      Playerstate.add_items st item;
      assert_equal expected_output (get_items st))  

let get_energy_test 
    (name: string)
    (st: player)
    (expected_output: int) : test = 
  name >:: (fun _ ->
      assert_equal expected_output (get_energy st)) 

let get_energy_change_test 
    (name: string)
    (st: player)
    (num: int)
    (expected_output: int) : test = 
  name >:: (fun _ ->
      Playerstate.chg_energy st num;
      assert_equal expected_output (get_energy st))    

let go_test (name : string) player board moves (expected: string) = 
  name >:: (fun _ -> go player board moves; 
             assert_equal expected (player 
                                    |> get_current_tile 
                                    |> get_tile_id))

let test_player = init_state "Jason" (start_tile test_board)
let diff_player = init_state "Jenny" (start_tile test_board)

let player_state_test = [
  get_player_name_test "player name" test_player "Jason";
  get_nth_player_test "1st player" [test_player; diff_player] 0 test_player;
  get_points_test "Just started, 0" test_player 0; 
  get_project_test "no proj yet" test_player None; 
  get_salary_test "0 salary rn" test_player 0; 
  get_items_test "no items yet" test_player [];
  get_study_partners_test "no study partners yet" test_player 0;
  get_energy_test "full energy" test_player 100; 
  get_points_set_test "1000 points" test_player 1000 1000; 
  get_project_set_test "game project, desc, 10 sal" test_player "game" "desc" 10 
    (Some("game", "desc" ,10)); 
  get_items_set_test "textbook item" test_player "textbook" ["textbook"]; 
  get_energy_change_test "-10 energy" test_player ~-10 90;  
  get_study_partners_test "no study partners yet" test_player 0;
  get_current_tile_test "On start" test_player "start"; 
  get_visited_tiles_test "visited start only" test_player ["start"];
  go_test "go test 1 move" test_player test_board 1 "choose 1110 or 2110";
  (* get_visited_tiles_after_go_test "start and 1110/2110 waiting" test_player 1 
     ["choose 1110 or 2110"; "start"]; *)

  (* get_current_tile_test "on start" diff_player "start"; *)
  (* go_test "go test 1 move" diff_player go_board 1 "1110"; *)
  (* go_test "go test 2 move" diff_player go_board 2 "Start 2110";
     go_test "go test 7 move" diff_player go_board 7 "CS 3410"; *)
  (* get_visited_tiles_after_go_test "start and 1110/2110 waiting" diff_player 2 
     ["1110 waiting spot"; "choose 1110 or 2110"; "start"]; *)
]

let suite =
  "test suite for game"  >::: List.flatten [
    tile_test;
    board_test;
    player_state_test;
  ]

let _ = run_test_tt_main suite