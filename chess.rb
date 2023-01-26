require 'colorize'
class Piece
    attr_reader :symbol
    attr_reader :team
    attr_accessor :has_moved
    attr_reader :opposite_team
    @@black_pieces = []
    @@white_pieces = []
    def initialize(team)
        @opposite_team = 2
        @has_moved = false
        @team = team
        if @team == 0
            @@black_pieces << self
            @opposite_team = 1
        elsif @team == 1
            @@white_pieces << self
            @opposite_team = 0
        end
        @symbol = " "
    end
    def self.list_black_pieces
        return @@black_pieces
    end
    def self.list_white_pieces
        return @@white_pieces
    end

    def can_move_to?(game_board, pos)
        if(!game_board.get_spot(pos))
            return true
        end
        if(game_board.get_spot(pos).team == self.team)
            return false
        end
        return true
    end
    def is_diagonal?(pos1, pos2)
        ydiff = pos2[0] - pos1[0]
        xdiff = pos2[1] - pos1[1]
        return xdiff.abs == ydiff.abs
    end
    def is_king_move?(pos1, pos2)
        (pos1[0] - pos2[0]).abs<= 1 && (pos1[1] - pos2[1]).abs<= 1
    end
    def is_orthogonal?(pos1, pos2)
        ((pos1[0] == pos2[0]) || (pos1[1] == pos2[1]))
    end

end

class King < Piece
    def initialize(team)
        super(team)
        @symbol = "K"
    end
    def is_attacking?(pos1, pos2, game_board)
        return is_king_move?(pos1, pos2)
    end
    def legal_move?(pos1, pos2, game_board)
        return false if game_board.is_king_in_check_after_move?(@team, pos1, pos2)
        return false if !game_board.is_on_board?(pos2)
        if(pos1 == pos2)
            return false
        elsif(is_king_move?(pos1, pos2))
            if can_move_to?(game_board, pos2)
                return true
            end
        elsif(pos1[0] == pos2[0] && (pos1[1]-pos2[1]).abs == 2)
            if self.has_moved || game_board.castled[self.team]
                return false
            else
                if pos2[1] == 2
                    rook_spot = [pos2[0], 0]
                    new_rook_spot = [pos2[0], 3]                    
                elsif pos2[1] == 6
                    rook_spot = [pos2[0], 7]
                    new_rook_spot = [pos2[0], 5]
                end
                return false if game_board.get_spot(new_rook_spot)
                rook_spot_piece = game_board.get_spot(rook_spot)
          #      p rook_spot_piece
                return false if !(Rook === rook_spot_piece)
                return false if rook_spot_piece.has_moved
                return false if !rook_spot_piece.legal_move?(rook_spot, new_rook_spot, game_board)
                return [rook_spot, new_rook_spot] if can_move_to?(game_board, pos2)
            end
        end
        return false
    end
    def in_check?(pos, game_board)
 #       p @opposite_team
        return game_board.is_attacked?(pos, @opposite_team)
    end
    def self.in_checkmate?(pos1, game_board)
    end
end

class Rook < Piece
    def initialize(team)
        super(team)
        @symbol = "R"
    end
    def is_attacking?(pos1, pos2, game_board)
        if(pos1 == pos2)
            return false
        elsif !is_orthogonal?(pos1, pos2)
            return false
        else
            spots = game_board.between_ortho(pos1, pos2)
            for spot in spots
                if game_board.get_spot(spot)
                    return false
                end
            end
            return true
        end
        return false
    end
    def legal_move?(pos1, pos2, game_board)
        return false if !game_board.is_on_board?(pos2)
        return false if game_board.is_king_in_check_after_move?(@team, pos1, pos2)
        if(pos1 == pos2)
            return false
        elsif(is_orthogonal?(pos1,pos2))
            spots = game_board.between_ortho(pos1, pos2)
            for spot in spots
                if game_board.get_spot(spot)
                    return false
                end
            end
            if can_move_to?(game_board, pos2)
                return true
            end
        end
        return false
    end
end

class Bishop < Piece
    def initialize(team)
        super(team)
        @symbol = "B"
    end
    def is_attacking?(pos1, pos2, game_board)
        if(pos1 == pos2)
            return false
        elsif !is_diagonal?(pos1, pos2)
            return false
        else
            spots = game_board.between_diag(pos1, pos2)
            for spot in spots
                if game_board.get_spot(spot)
                    return false
                end
            end
            return true
        end
        return false
    end
    def legal_move?(pos1, pos2, game_board)
        return false if !game_board.is_on_board?(pos2)
        return false if game_board.is_king_in_check_after_move?(@team, pos1, pos2)
        if(pos1 == pos2)
            return false
        elsif !is_diagonal?(pos1, pos2)
            return false
        else
            spots = game_board.between_diag(pos1, pos2)
            for spot in spots
                if game_board.get_spot(spot)
                    return false
                end
            end
            if can_move_to?(game_board, pos2)
                return true
            end
        end
        return false
    end
end

class Queen < Piece
    def initialize(team)
        super(team)
        @symbol = "Q"
    end
    def is_attacking?(pos1, pos2, game_board)
        if is_diagonal?(pos1, pos2)
            spots = game_board.between_diag(pos1, pos2)
        elsif is_orthogonal?(pos1, pos2)
            spots = game_board.between_ortho(pos1, pos2)
        else
            return false
        end
        for spot in spots
            if game_board.get_spot(spot)
                return false
            end
        end
        return true
    end
    def legal_move?(pos1, pos2, game_board)
        return false if !game_board.is_on_board?(pos2)
        return false if game_board.is_king_in_check_after_move?(@team, pos1, pos2)
        if(pos1 == pos2)
            return false
        elsif is_diagonal?(pos1, pos2)
            spots = game_board.between_diag(pos1, pos2)
        elsif is_orthogonal?(pos1, pos2)
            spots = game_board.between_ortho(pos1, pos2)
        else
            return false
        end
        for spot in spots
            if game_board.get_spot(spot)
                return false
            end
        end
        if can_move_to?(game_board, pos2)
            return true
        end
        return false
    end
end

class Knight < Piece
    def initialize (team)
        super(team)
        @symbol = "N"
    end
    def is_attacking?(pos1, pos2, game_board)
        ydiff = (pos1[0] - pos2[0]).abs
        xdiff = (pos1[1] - pos2[1]).abs
        if ((ydiff == 1 && xdiff == 2) || (ydiff == 2 && xdiff == 1))
            return true
        end
    end
    def legal_move?(pos1, pos2, game_board)
        return false if !game_board.is_on_board?(pos2)
        return false if game_board.is_king_in_check_after_move?(@team, pos1, pos2)
        ydiff = (pos1[0] - pos2[0]).abs
        xdiff = (pos1[1] - pos2[1]).abs
        if ((ydiff == 1 && xdiff == 2) || (ydiff == 2 && xdiff == 1))
            return can_move_to?(game_board, pos2)
        end
        return false
    end
end
class Pawn < Piece
    def initialize(team)
        super(team)
        @symbol = "p"
    end
    def is_attacking?(pos1, pos2, game_board)
        if @team == 0
            direction = 1
        elsif @team == 1
            direction = -1
        end
        if (pos2[1] - pos1[1]).abs == 1
            if pos2[0] == pos1[0] + direction
                return true
            end
        end
        return false
    end
    def legal_move?(pos1, pos2, game_board)
        return false if !game_board.is_on_board?(pos2)
        return false if game_board.is_king_in_check_after_move?(@team, pos1, pos2)
        if @team == 0
            starting_line = 1
            direction = 1
        elsif @team == 1
            starting_line = 6
            direction = -1
        end
        if pos2[1] == pos1[1]
            legal_push = false
            if pos2[0] == pos1[0] + direction
                legal_push = true
            elsif pos1[0] == starting_line
                if pos2[0] == pos1[0] + (2 * direction)
                    legal_push = true
                end
            end
            
            return legal_push && (game_board.get_spot(pos2) == nil)

        end
        if (pos2[1] - pos1[1]).abs == 1
            if pos2[0] == pos1[0] + direction
                spot = game_board.get_spot(pos2)
                if spot
                    if(spot.team != @team)
                        return true
                    else
                        return false
                    end
                end
            end
        end
        return false
    end
end


class GameBoard
    attr_reader :game_lost
    attr_reader :castled
    def initialize()
        @board = Array.new(8,Array.new(8))
        @game_lost = false
        @castled = [false, false]
    end
    def copy()

    end
    def can_attack?(team, pos)
        for i in (0..7)
            for j in (0..7)
                piece = get_spot([i,j])
                if piece && piece.team == team
                    if piece.legal_move?([i,j], pos, self)
                        return true
                    end
                end
            end
        end
        return false
    end
    def reset_game
        @castled = [false, false]
        @game_lost = false
        @board = 
       [[Rook.new(0), Knight.new(0), Bishop.new(0), Queen.new(0), King.new(0), Bishop.new(0), Knight.new(0), Rook.new(0)],                                      
        [Pawn.new(0), Pawn.new(0), Pawn.new(0), Pawn.new(0), Pawn.new(0), Pawn.new(0), Pawn.new(0), Pawn.new(0)],                          
        [nil, nil, nil, nil, nil, nil, nil, nil],                                      
        [nil, nil, nil, nil, nil, nil, nil, nil],                                      
        [nil, nil, nil, nil, nil, nil, nil, nil],                                      
        [nil, nil, nil, nil, nil, nil, nil, nil],                                      
        [Pawn.new(1), Pawn.new(1), Pawn.new(1), Pawn.new(1), Pawn.new(1), Pawn.new(1), Pawn.new(1), Pawn.new(1)],                                      
        [Rook.new(1), Knight.new(1), Bishop.new(1), Queen.new(1), King.new(1), Bishop.new(1), Knight.new(1), Rook.new(1)]]
    end
    def is_on_board?(pos)
        return !(pos[0] < 0 || pos[0] > 7 || pos[1] < 0 || pos[1] > 8)
    end
    def move_piece(pos1, pos2)
        piece = self.get_spot(pos1)
        return false if !piece
        legal = piece.legal_move?(pos1, pos2, self)
        if Array === legal

            rook_spot = legal[0]
            new_rook_spot = legal[1]
            @castled[piece.team] = true
            move_piece(rook_spot, new_rook_spot)
         #   return true
        end
        if legal
            piece2 = get_spot([pos2[0],pos2[1]])
            if King === piece2
                @game_lost = piece2.team
            end

            @board[pos2[0]][pos2[1]] = @board[pos1[0]][pos1[1]]
            @board[pos2[0]][pos2[1]].has_moved = true
            @board[pos1[0]][pos1[1]] = nil
            if Pawn === piece
                if pos2[0] == 0 || pos2[0] == 7
                    @board[pos2[0]][pos2[1]] = Queen.new(piece.team)
                end
            end
            return true
        end
        return false
    end
    def is_attacked?(pos, team)
        for i in (0..7)
            for j in (0..7)
                piece = get_spot([i,j])
                if piece && piece.team == team && piece.is_attacking?([i,j], pos, self)
              #      p "#{pos} is attacked by #{team}"
                    return true                    
                end
            end
        end
      #  p "#{pos} is not attacked by #{team}"
        return false
    end
    def is_king_in_check_after_move?(team, pos1, pos2)
        pos1_orig = @board[pos1[0]][pos1[1]]
        pos2_orig = @board[pos2[0]][pos2[1]]
        @board[pos2[0]][pos2[1]] = pos1_orig
        @board[pos1[0]][pos1[1]] = nil
        is_in_check = false
        for i in (0..7)
            for j in (0..7)
                piece = get_spot([i,j])
                if King === piece
        #            p "#{piece} is a King"
                    if piece.team == team
                        if piece.in_check?([i,j], self)
                            is_in_check = true
                        end
                    end
                end
            end
        end
        @board[pos1[0]][pos1[1]] = pos1_orig
        @board[pos2[0]][pos2[1]] = pos2_orig
        return is_in_check
    end
    def is_king_in_check_after_every_move?(team)
        a = get_every_legal_move(team)
        pieces_arr = a[0]
        moves_arr = a[1]
    #    p pieces_arr
   #     p moves_arr
        for i in (0...pieces_arr.size)
            piece = pieces_arr[i]
   #         p i
    #        p moves_arr[i]
            if moves_arr[i].size > 0
                for move in moves_arr[i]
                    if !is_king_in_check_after_move?(team, piece, move)
                        return false
                    end
                end
            end
        end
        return true
    end
    def get_spot(pos)
    #    p "checking #{pos[0]} and #{pos[1]}"
        @board[pos[0]][pos[1]]
    end
    def force_move(pos1, pos2)
        @board[pos2[0]][pos2[1]] = @board[pos1[0]][pos1[1]]
        @board[pos1[0]][pos1[1]] = nil
    end
    def between_ortho(pos1, pos2)
        spots = []
        if(pos1[0] != pos2[0])
            if pos1[0] < pos2[0]
                lower = pos1[0]
                higher = pos2[0]
            else
                lower = pos2[0]
                higher = pos1[0]
            end
            lower += 1
            (lower...higher).each { |row|
                spots << [row, pos1[1]]
            }
        elsif(pos1[1] != pos2[1])
            if pos1[1] < pos2[1]
                lower = pos1[1]
                higher = pos2[1]
            else
                lower = pos2[1]
                higher = pos1[1]
            end
            lower += 1
            (lower...higher).each { |column|
                spots << [pos1[0], column]
            }
        end
        return spots
    end

    def between_diag(pos1, pos2)
        if(pos1[1] < pos2[1])
            lower = pos1
            upper = pos2
            if(pos1[0] < pos2[0])
                y_iter = 1
            else
                y_iter = -1
            end
        else
            lower = pos2
            upper = pos1
            if(pos1[0] < pos2[0])
                y_iter = -1
            else
                y_iter = 1
            end
        end
        iterations = (upper[1] - lower[1]) - 1
        x = lower[1]
        y = lower[0]
        spots = []
        iterations.times do
            x += 1
            y += y_iter
            spots << [y, x]
        end
        return spots
    end
    def show_board
        @board.each.with_index do |row, row_index|
            print ((8-row_index).to_s + "  |")
            for spot in row
                if spot
                    if spot.team == 0
                        print(spot.symbol.red)
                        print(" ")
                    else
                        print(spot.symbol.blue)
                        print(" ")
                    end
                    
                else
                    print("_ ")
                end
                
            end
            print "\n"
        end
        print "   |_______________\n    A B C D E F G H\n"
    end
    def get_all_legal_moves(pos)
        piece = self.get_spot(pos)
        return false if !piece
        legal_moves = []
        for i in (0..7)
            for j in (0..7)
                if piece.legal_move?(pos, [i,j], self)
                    legal_moves << [i,j]
                end
            end
        end
        return legal_moves
    end
    def get_every_legal_move(team)
        all_pieces = []
        all_moves = []
        for i in (0..7)
            for j in (0..7)
                piece = get_spot([i,j])
                if piece && piece.team == team
                    all_pieces << [i,j]
                    all_moves << get_all_legal_moves([i,j])
                end
            end
        end
        return [all_pieces, all_moves]
    end
    def show_legal_moves(pos)
        piece = get_spot(pos)
        return false if !piece
        legal_moves = get_all_legal_moves(pos)
        for i in (0..7)
            print ((8-i).to_s + "  |")
            for j in (0..7)
                if legal_moves.include?([i,j])
                    print "X "
                else
                    spot = @board[i][j]
                    if spot
                        if spot.team == 0
                            print(spot.symbol.red)
                            print(" ")
                        else
                            print(spot.symbol.blue)
                            print(" ")
                        end
                    else
                        print("_ ")
                    end
                end
            end
            print "\n"
        end
        print "   |_______________\n    A B C D E F G H\n"
        return false if legal_moves.size < 1
        return legal_moves
    end

end

board = GameBoard.new()
board.reset_game
board.show_board
def get_user_spot
    piece = gets.chomp
    file_char = piece[0]
    rank_char = piece[1]
    if !'abcdefgh'.include?(file_char) || !'12345678'.include?(rank_char)
        return false
    end
    file = 'abcdefgh'.rindex(file_char).to_i
    rank = 8 - rank_char.to_i
    return [rank, file]
end
def get_user_move(team, game_board)
    

    game_board.show_board
    while true
        spot1 = get_user_spot
        piece1 = game_board.get_spot(spot1)
        if !piece1
            game_board.show_board
            print "There is no piece there.\n"
            next
        end
        if piece1.team != team
            game_board.show_board
            print "That is not your piece.\n"
            next
        end
        legal_moves = game_board.get_all_legal_moves(spot1)
        if legal_moves.size < 1
            game_board.show_board
            print "That piece has no legal moves.\n"
            next
        end
        break
    end
    game_board.show_legal_moves(spot1)
    legal_moves = game_board.get_all_legal_moves(spot1)
    spot2 = get_user_spot
    while !legal_moves.include?(spot2)
        print "Cannot move there. pick one of the spots indicated.\n"
        spot2 = get_user_spot
    end
    return [spot1, spot2]
end

while true do
    move = get_user_move(1, board)
    board.move_piece(move[0], move[1])
    if board.is_king_in_check_after_every_move?(0)
        board.show_board
        print "blue wins by checkmate\n"
        break
    end
    move = get_user_move(0, board)
    board.move_piece(move[0], move[1])
    if board.is_king_in_check_after_every_move?(1)
        board.show_board
        print "red wins by checkmate\n"
        break
    end
    board.show_board
    if board.game_lost
        print "\n#{board.game_lost} team just lost the game!\n"
        break
    end
end