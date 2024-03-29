/* BOISSON Romain - GUY Timothée
 *
 * Yokai No-Mori project - UFR-ST 2019
 *
 * ia.pl - Artificial Intelligence predicates
 *
 */

% Flag for long list
:-set_prolog_flag(toplevel_print_options,
    [quoted(true), portrayed(true), max_depth(0)]).

:-use_module(library(lists)).
:-use_module(library(between)).

%----------------------------------------------------------------
% Initial board generation
%----------------------------------------------------------------

% inital( pieces(side, type, x, y) ) : put a piece on the board
initial(piece(north, oni, 1, 1)).
initial(piece(north, kirin, 2, 1)).
initial(piece(north, koropokkuru, 3, 1)).
initial(piece(north, kirin, 4, 1)).
initial(piece(north, oni, 5, 1)).
initial(piece(north, kodama, 2, 3)).
initial(piece(north, kodama, 3, 3)).
initial(piece(north, kodama, 4, 3)).

initial(piece(south, oni, 1, 6)).
initial(piece(south, kirin, 2, 6)).
initial(piece(south, koropokkuru, 3, 6)).
initial(piece(south, kirin, 4, 6)).
initial(piece(south, oni, 5, 6)).
initial(piece(south, kodama, 2, 4)).
initial(piece(south, kodama, 3, 4)).
initial(piece(south, kodama, 4, 4)).

% initial_board : initialize the board with a default configuration
initial_board(Board) :-
    findall(Piece, initial(Piece), Board).

%----------------------------------------------------------------
% opponent : describes a player and its opponent
%----------------------------------------------------------------
opponent(north, south).
opponent(south, north).

%----------------------------------------------------------------
% isEmpty : check if a square is empty
%----------------------------------------------------------------
isEmpty(X, Y, Board):-
	between(1, 5, X),
	between(1, 6, Y),
	\+(member(piece(_, _, X, Y), Board)).


% /!\ Warning /!\ : capture and move, used alone, duplicate pieces

%----------------------------------------------------------------
% capture : capture an opponent piece
%----------------------------------------------------------------
capture(piece(Side, Type, X, Y), Board, NewBoard, Capt, NewCapt):-
	% Get the opponent
	opponent(Side, OtherSide),
	% Extract the board without the captured piece
	select(piece(OtherSide, OtherType, X, Y), Board, TempBoard),
	% If a promoted unit is captured, remove the promotion
	(
		OtherType = samourai,
		CorrectedType = kodama
		;
		OtherType = superoni,
		CorrectedType = oni
		;
		CorrectedType = OtherType
	),
	% Add the captured piece to the list of captured pieces
	NewCapt = [piece(Side, CorrectedType, 0, 0) | Capt],
	% Create the new board
	NewBoard = [piece(Side, Type, X, Y) | TempBoard].

%----------------------------------------------------------------
% move : move a piece without capturing
%----------------------------------------------------------------
move(Piece, Board, NewBoard):-
	NewBoard = [Piece | Board].

%----------------------------------------------------------------
% try_move : try to move a piece
% First, extract a piece from the board, then try to move it
% on an empty square, otherwise capture the opponent piece
%----------------------------------------------------------------

% try_move north kodama
try_move(Board, CaptN, CaptS, north, NewBoard, NewCaptN, NewCaptS, kodama, X, Y, N_X, N_Y, Capture):-
	select(piece(north, kodama, X, Y), Board, TempBoard),
	N_X is X, N_Y is Y + 1,
	(
		% Promote
		N_Y >= 5,
		(
			% Try moving
			isEmpty(N_X, N_Y, Board),
			move(piece(north, samourai, N_X, N_Y), TempBoard, NewBoard),
			NewCaptN = CaptN,
      Capture = 0
			;
			% Try capturing
			capture(piece(north, samourai, N_X, N_Y), TempBoard, NewBoard, CaptN, NewCaptN),
      Capture = 1
		)
		;
		(
			isEmpty(N_X, N_Y, Board),
			move(piece(north, kodama, N_X, N_Y), TempBoard, NewBoard),
			NewCaptN = CaptN,
      Capture = 0
			;
			capture(piece(north, kodama, N_X, N_Y), TempBoard, NewBoard, CaptN, NewCaptN),
      Capture = 1
		)
	),
	NewCaptS = CaptS.


% try_move south kodama
try_move(Board, CaptN, CaptS, south, NewBoard, NewCaptN, NewCaptS, kodama, X, Y, N_X, N_Y, Capture):-
	select(piece(south, kodama, X, Y), Board, TempBoard),
	N_X is X, N_Y is Y - 1,
	(
		% Promote
		N_Y =< 2,
		(
			isEmpty(N_X, N_Y, Board),
			move(piece(south, samourai, N_X, N_Y), TempBoard, NewBoard),
			NewCaptS = CaptS,
      Capture = 0
			;
			capture(piece(south, samourai, N_X, N_Y), TempBoard, NewBoard, CaptS, NewCaptS),
      Capture = 1
		)
		;
		(
			isEmpty(N_X, N_Y, Board),
			move(piece(south, kodama, N_X, N_Y), TempBoard, NewBoard),
			NewCaptS = CaptS,
      Capture = 0
			;
			capture(piece(south, kodama, N_X, N_Y), TempBoard, NewBoard, CaptS, NewCaptS),
      Capture = 1
		)
	),
	NewCaptN = CaptN.

% try_move north samourai
try_move(Board, CaptN, CaptS, north, NewBoard, NewCaptN, NewCaptS, samourai, X, Y, N_X, N_Y, Capture):-
	select(piece(north, samourai, X, Y), Board, TempBoard),
	(
		N_X is X, N_Y is Y + 1;
		N_X is X, N_Y is Y - 1;
		N_X is X + 1, N_Y is Y;
		N_X is X - 1, N_Y is Y;
		N_X is X + 1, N_Y is Y + 1;
		N_X is X - 1, N_Y is Y + 1
	),
	(
		isEmpty(N_X, N_Y, Board),
		move(piece(north, samourai, N_X, N_Y), TempBoard, NewBoard),
		NewCaptN = CaptN,
    Capture = 0
		;
		capture(piece(north, samourai, N_X, N_Y), TempBoard, NewBoard, CaptN, NewCaptN),
    Capture = 1
	),
	NewCaptS = CaptS.

% try_move south samourai
try_move(Board, CaptN, CaptS, south, NewBoard, NewCaptN, NewCaptS, samourai, X, Y, N_X, N_Y, Capture):-
	select(piece(south, samourai, X, Y), Board, TempBoard),
	(
		N_X is X, N_Y is Y + 1;
		N_X is X, N_Y is Y - 1;
		N_X is X + 1, N_Y is Y;
		N_X is X - 1, N_Y is Y;
		N_X is X + 1, N_Y is Y - 1;
		N_X is X - 1, N_Y is Y - 1
	),
	(
		isEmpty(N_X, N_Y, Board),
		move(piece(south, samourai, N_X, N_Y), TempBoard, NewBoard),
		NewCaptS = CaptS,
    Capture = 0
		;
		capture(piece(south, samourai, N_X, N_Y), TempBoard, NewBoard, CaptS, NewCaptS),
    Capture = 1
	),
	NewCaptN = CaptN.

% try_move north oni
try_move(Board, CaptN, CaptS, north, NewBoard, NewCaptN, NewCaptS, oni, X, Y, N_X, N_Y, Capture):-
	select(piece(north, oni, X, Y), Board, TempBoard),
	(
		N_X is X, N_Y is Y + 1;
		N_X is X + 1, N_Y is Y + 1;
		N_X is X + 1, N_Y is Y - 1;
		N_X is X - 1, N_Y is Y + 1;
		N_X is X - 1, N_Y is Y - 1
	),
	(
		% Promote
		N_Y >= 5,
		(
			isEmpty(N_X, N_Y, Board),
			move(piece(north, superoni, N_X, N_Y), TempBoard, NewBoard),
			NewCaptN = CaptN,
      Capture = 0
			;
			capture(piece(north, superoni, N_X, N_Y), TempBoard, NewBoard, CaptN, NewCaptN),
      Capture = 1
		)
		;
		(
			isEmpty(N_X, N_Y, Board),
			move(piece(north, oni, N_X, N_Y), TempBoard, NewBoard),
			NewCaptN = CaptN,
      Capture = 0
			;
			capture(piece(north, oni, N_X, N_Y), TempBoard, NewBoard, CaptN, NewCaptN),
      Capture = 1
		)
	),
	NewCaptS = CaptS.

% try_move south oni
try_move(Board, CaptN, CaptS, south, NewBoard, NewCaptN, NewCaptS, oni, X, Y, N_X, N_Y, Capture):-
	select(piece(south, oni, X, Y), Board, TempBoard),
	(
		N_X is X, N_Y is Y - 1;
		N_X is X + 1, N_Y is Y + 1;
		N_X is X + 1, N_Y is Y - 1;
		N_X is X - 1, N_Y is Y + 1;
		N_X is X - 1, N_Y is Y - 1
	),
	(
		% Promote
		N_Y =< 2,
		(
			isEmpty(N_X, N_Y, Board),
			move(piece(south, superoni, N_X, N_Y), TempBoard, NewBoard),
			NewCaptS = CaptS,
      Capture = 0
			;
			capture(piece(south, superoni, N_X, N_Y), TempBoard, NewBoard, CaptS, NewCaptS),
      Capture = 1
		)
		;
		(
			isEmpty(N_X, N_Y, Board),
			move(piece(south, oni, N_X, N_Y), TempBoard, NewBoard),
			NewCaptS = CaptS,
      Capture = 0
			;
			capture(piece(south, oni, N_X, N_Y), TempBoard, NewBoard, CaptS, NewCaptS),
      Capture = 1
		)
	),
	NewCaptN = CaptN.

% try_move north superoni
try_move(Board, CaptN, CaptS, north, NewBoard, NewCaptN, NewCaptS, superoni, X, Y, N_X, N_Y, Capture):-
	select(piece(north, superoni, X, Y), Board, TempBoard),
	(
		N_X is X, N_Y is Y + 1;
		N_X is X, N_Y is Y - 1;
		N_X is X + 1, N_Y is Y;
		N_X is X - 1, N_Y is Y;
		N_X is X + 1, N_Y is Y + 1;
		N_X is X - 1, N_Y is Y + 1
	),
	(
		isEmpty(N_X, N_Y, Board),
		move(piece(north, superoni, N_X, N_Y), TempBoard, NewBoard),
		NewCaptN = CaptN,
    Capture = 0
		;
		capture(piece(north, superoni, N_X, N_Y), TempBoard, NewBoard, CaptN, NewCaptN),
    Capture = 1
	),
	NewCaptS = CaptS.

% try_move south superoni
try_move(Board, CaptN, CaptS, south, NewBoard, NewCaptN, NewCaptS, superoni, X, Y, N_X, N_Y, Capture):-
	select(piece(south, superoni, X, Y), Board, TempBoard),
	(
		N_X is X, N_Y is Y + 1;
		N_X is X, N_Y is Y - 1;
		N_X is X + 1, N_Y is Y;
		N_X is X - 1, N_Y is Y;
		N_X is X + 1, N_Y is Y - 1;
		N_X is X - 1, N_Y is Y - 1
	),
	(
		isEmpty(N_X, N_Y, Board),
		move(piece(south, superoni, N_X, N_Y), TempBoard, NewBoard),
		NewCaptS = CaptS,
    Capture = 0
		;
		capture(piece(south, superoni, N_X, N_Y), TempBoard, NewBoard, CaptS, NewCaptS),
    Capture = 1
	),
	NewCaptN = CaptN.

% try_move north kirin
try_move(Board, CaptN, CaptS, north, NewBoard, NewCaptN, NewCaptS, kirin, X, Y, N_X, N_Y, Capture):-
	select(piece(north, kirin, X, Y), Board, TempBoard),
	(
		N_X is X, N_Y is Y + 1;
		N_X is X, N_Y is Y - 1;
		N_X is X + 1, N_Y is Y;
		N_X is X - 1, N_Y is Y;
		N_X is X + 1, N_Y is Y + 1;
		N_X is X - 1, N_Y is Y + 1
	),
	(
		isEmpty(N_X, N_Y, Board),
		move(piece(north, kirin, N_X, N_Y), TempBoard, NewBoard),
		NewCaptN = CaptN,
    Capture = 0
		;
		capture(piece(north, kirin, N_X, N_Y), TempBoard, NewBoard, CaptN, NewCaptN),
    Capture = 1
	),
	NewCaptS = CaptS.

% try_move south kirin
try_move(Board, CaptN, CaptS, south, NewBoard, NewCaptN, NewCaptS, kirin, X, Y, N_X, N_Y, Capture):-
  select(piece(south, kirin, X, Y), Board, TempBoard),
	(
		N_X is X, N_Y is Y + 1;
		N_X is X, N_Y is Y - 1;
		N_X is X + 1, N_Y is Y;
		N_X is X - 1, N_Y is Y;
		N_X is X + 1, N_Y is Y - 1;
		N_X is X - 1, N_Y is Y - 1
	),
	(
		isEmpty(N_X, N_Y, Board),
		move(piece(south, kirin, N_X, N_Y), TempBoard, NewBoard),
		NewCaptS = CaptS,
    Capture = 0
		;
		capture(piece(south, kirin, N_X, N_Y), TempBoard, NewBoard, CaptS, NewCaptS),
    Capture = 1
	),
	NewCaptN = CaptN.

% try_move north koropokkuru
try_move(Board, CaptN, CaptS, north, NewBoard, NewCaptN, NewCaptS, koropokkuru, X, Y, N_X, N_Y, Capture):-
	select(piece(north, koropokkuru, X, Y), Board, TempBoard),
	(
		N_X is X, N_Y is Y + 1;
		N_X is X, N_Y is Y - 1;
		N_X is X + 1, N_Y is Y;
		N_X is X - 1, N_Y is Y;
		N_X is X + 1, N_Y is Y + 1;
		N_X is X + 1, N_Y is Y - 1;
		N_X is X - 1, N_Y is Y + 1;
		N_X is X - 1, N_Y is Y - 1
	),
	(
		isEmpty(N_X, N_Y, Board),
		move(piece(north, koropokkuru, N_X, N_Y), TempBoard, NewBoard),
		NewCaptN = CaptN,
    Capture = 0
		;
		capture(piece(north, koropokkuru, N_X, N_Y), TempBoard, NewBoard, CaptN, NewCaptN),
    Capture = 1
	),
	NewCaptS = CaptS.

% try_move south koropokkuru
try_move(Board, CaptN, CaptS, south, NewBoard, NewCaptN, NewCaptS, koropokkuru, X, Y, N_X, N_Y, Capture):-
	select(piece(south, koropokkuru, X, Y), Board, TempBoard),
	(
		N_X is X, N_Y is Y + 1;
		N_X is X, N_Y is Y - 1;
		N_X is X + 1, N_Y is Y;
		N_X is X - 1, N_Y is Y;
		N_X is X + 1, N_Y is Y + 1;
		N_X is X + 1, N_Y is Y - 1;
		N_X is X - 1, N_Y is Y + 1;
		N_X is X - 1, N_Y is Y - 1
	),
	(
		isEmpty(N_X, N_Y, Board),
		move(piece(south, koropokkuru, N_X, N_Y), TempBoard, NewBoard),
		NewCaptS = CaptS,
    Capture = 0
		;
		capture(piece(south, koropokkuru, N_X, N_Y), TempBoard, NewBoard, CaptS, NewCaptS),
    Capture = 1
	),
	NewCaptN = CaptN.

%----------------------------------------------------------------
% force_move : force a movement by giving the coordinates
% of the moving piece and its coordinates of arrival
%----------------------------------------------------------------
force_move(Side, Type, X, Y, N_X, N_Y, Board, CaptN, CaptS, NewBoard, NewCaptN, NewCaptS):-
  (
    Side = north,
    N_Y >= 5,
    (
      Type = kodama,
      NewType = samourai
      ;
      Type = oni,
      NewType = superoni
    )
    ;
    Side = south,
    N_Y =< 2,
    (
      Type = kodama,
      NewType = samourai
      ;
      Type = oni,
      NewType = superoni
    )
    ;
    NewType = Type
  ),
	select(piece(Side, Type, X, Y), Board, TempBoard),
	(
		% Try moving
		isEmpty(N_X, N_Y, Board),
		move(piece(Side, NewType, N_X, N_Y), TempBoard, NewBoard),
		NewCaptN = CaptN,
		NewCaptS = CaptS
		;
		% Try capturing if side is north
		Side = north,
		capture(piece(Side, NewType, N_X, N_Y), TempBoard, NewBoard, CaptN, NewCaptN),
		NewCaptS = CaptS
		;
		% Try capturing if side is south
		Side = south,
		capture(piece(Side, NewType, N_X, N_Y), TempBoard, NewBoard, CaptS, NewCaptS),
		NewCaptN = CaptN
	).

%----------------------------------------------------------------
% put : put a piece on the board and remove it from the Capt list
%----------------------------------------------------------------
put(Side, Type, X, Y, Board, Capt, NewBoard, NewCapt):-
	% Check coordinates
	between(1, 5, X),
	(
		Side = north,
		between(1, 5, Y)
		;
		Side = south,
		between(2, 6, Y)
	),
	% Check if there's a kodama in the column
	\+member(piece(Side, _, X, _), Board),
	% Check if the square is empty
	isEmpty(X, Y, Board),
	% Extract the piece from the list of captured pieces
	select(piece(Side, Type, _, _), Capt, NewCapt),
	% Create the new board
	NewBoard = [piece(Side, Type, X, Y)| Board].

%----------------------------------------------------------------
% get_moves : get all possible moves for a side
%----------------------------------------------------------------

get_moves(Board, CaptN, CaptS, Side, MoveList):-
  findall(
    [Board, CaptN, CaptS, Side, NewBoard, NewCaptN, NewCaptS, Type, X, Y, N_X, N_Y, Capture, 0],
    try_move(Board, CaptN, CaptS, Side, NewBoard, NewCaptN, NewCaptS, Type, X, Y, N_X, N_Y, Capture),
    MoveList
  ).

%----------------------------------------------------------------
% distance_to_koropokkuru : get the distance between a given
% piece and the opponent koropokkuru, substract this distance
% to the score
%----------------------------------------------------------------

distance_to_koropokkuru(Board, Side, _, N_X, N_Y, Score, NewScore):-
  opponent(Side, Opposide),
  select(piece(Opposide, koropokkuru, KX, KY), Board, _),
  NewScore is Score - abs(KX - N_X) - abs(KY - N_Y).

%----------------------------------------------------------------
% is_capturing : increase the score if a piece is capturing an
% opponent piece
%----------------------------------------------------------------

is_capturing(Board, Side, Type, N_X, N_Y, Capture, Score, NewScore):-
  opponent(Side, Opposide),
  (
    Capture = 1,
    (
      Type = koropokkuru,
      NewScore is Score - 5
      ;
      select(piece(Opposide, OppoType, N_X, N_Y), Board, _),
      (
        OppoType = kodama,
        NewScore is Score + 1
        ;
        OppoType = samourai,
        NewScore is Score + 3
        ;
        OppoType = oni,
        NewScore is Score + 2
        ;
        OppoType = superoni,
        NewScore is Score + 3
        ;
        OppoType = kirin,
        NewScore is Score + 3
        ;
        OppoType = koropokkuru,
        NewScore is Score + 10
      )
    )
    ;
    Capture = 0,
    NewScore is Score
  ).

%----------------------------------------------------------------
% oppo_moves : for a given move, test if its going to be in
% the range of an opponent move, if its the case, substract score
%----------------------------------------------------------------

oppo_moves([], _, _, _, _, _, _, NewScore, NewScore):-!.

oppo_moves([Head|Tail], Board, Side, Type, N_X, N_Y, Capture, Score, NewScore):-
  Head = [_, _, _, _, _, _, _, _, _, _, HN_X, HN_Y, _, _],
  (
    HN_X = N_X, HN_Y = N_Y,
    (
      Type = koropokkuru,
      NewScore is Score - 1000
      ;
      NewScore is Score - 2
    )
    ;
    oppo_moves(Tail, Board, Side, Type, N_X, N_Y, Capture, Score, NewScore)
  ).

%----------------------------------------------------------------
% process_score : process score for each piece of a list of piece
%----------------------------------------------------------------

process_score(_, _, [], _):-!.

process_score(Board, OppoMoveList, [Head|Tail], [NewHead|NewTail]):-
  Head = [Board, CaptN, CaptS, Side, NewBoard, NewCaptN, NewCaptS, Type, X, Y, N_X, N_Y, Capture, Score],
  % Calculate distance to opponent koropokkuru
  distance_to_koropokkuru(Board, Side, Type, N_X, N_Y, Score, NewScore),
  % Increase score if the piece is capturing another
  is_capturing(Board, Side, Type, N_X, N_Y, Capture, NewScore, NewScore2),
  % Process opponent moves
  oppo_moves(OppoMoveList, Board, Side, Type, N_X, N_Y, Capture, NewScore2, NewScore3),
  % Get the new move
  NewHead = [Board, CaptN, CaptS, Side, NewBoard, NewCaptN, NewCaptS, Type, X, Y, N_X, N_Y, Capture, NewScore3],
  % Print calculated score
  % write(pscore), write([Side, Type, X, Y, N_X, N_Y, Capture, NewScore3]), nl,
  % Loop
  process_score(Board, OppoMoveList, Tail, NewTail).

%----------------------------------------------------------------
% best_move : get the best possible move
%----------------------------------------------------------------

best_move_start([Head|Tail], BestMove):-
  best_move(Tail, Head, BestMove).

best_move([], BestMove, BestMove).

best_move([Head|Tail], BestMove, NewBestMove):-
  Head = [_, _, _, _, _, _, _, _, _, _, _, _, _, Score],
  BestMove = [_, _, _, _, _, _, _, _, _, _, _, _, _, BScore],
  (
    Score > BScore,
    best_move(Tail, Head, NewBestMove)
    ;
    best_move(Tail, BestMove, NewBestMove)
  ).

%----------------------------------------------------------------
% generate_move : generate (in theory), the best possible move
%----------------------------------------------------------------

generate_move(Board, CaptN, CaptS, Side, NewBoard, NewCaptN, NewCaptS, Type, X, Y, N_X, N_Y, Capture):-
  % Get opponent side
  opponent(Side, Opposide),
  % Get possible moves for our side
  get_moves(Board, CaptN, CaptS, Side, MoveList),
  % Get possible moves of the opponent
  get_moves(Board, CaptN, CaptS, Opposide, OppoMoveList),
  % Process scores
  process_score(Board, OppoMoveList, MoveList, NewMoveList),
  % Get the best move
  best_move_start(NewMoveList, BestMove),
  BestMove = [Board, CaptN, CaptS, Side, NewBoard, NewCaptN, NewCaptS, Type, X, Y, N_X, N_Y, Capture, _].

%----------------------------------------------------------------
% Print functions
%----------------------------------------------------------------

% draw_board : draw the board
draw_board(Board, _, _) :-
	nl, draw_row(1, 1, Board), nl.

% draw_row : draw a row of the board
draw_row(X, Y, Board) :-
	X =< 5,
	draw_piece(X, Y, Board),
	X1 is X+1,
	draw_row(X1, Y, Board).

draw_row(6, Y, Board) :-
	Y =< 5,
	nl,
	Y1 is Y+1,
	draw_row(1, Y1, Board).

draw_row(5, 5, _) :- nl.

% draw_piece : draw a piece of the board
draw_piece(X, Y, Board) :-
	X == 1,
	write('|'),
	draw_piece_on_board(X, Y, Board),
	write('|').

draw_piece(X, Y, Board) :-
	X > 1,
	draw_piece_on_board(X, Y, Board),
	write('|').

draw_piece_on_board(X, Y, Board) :-
	(member(piece(_, Which, X, Y), Board) ->
		letter(Which, Letter),
		write(Letter)
		;
		write('_')
	).

% letter : assign a letter to each piece type
letter(oni, 'o').
letter(kirin, 'k').
letter(koropokkuru, 'p').
letter(kodama, 'i').
letter(samourai, 'I').
letter(superoni, 'O').
