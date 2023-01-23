class Piece
    attr_reader :symbol
    attr_reader :team
    def initialize(team)
        @team = team
        @symbol = " "
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
        @team = team
        @symbol = "K"
    end
    def legal_move?(pos1, pos2, game_board)
        if(pos1 == pos2)
            return false
        elsif(is_king_move?(pos1, pos2))
            if can_move_to?(game_board, pos2)
                return true
            end
        end
        return false
    end
end

class Rook < Piece
    def initialize(team)
        @team = team
        @symbol = "R"
    end

    def legal_move?(pos1, pos2, game_board)
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
        @team = team
        @symbol = "B"
    end
    
    def legal_move?(pos1, pos2, game_board)
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
        @team = team
        @symbol = "Q"
    end
    def legal_move?(pos1, pos2, game_board)
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
        @team = team
        @symbol = "N"
    end
    def legal_move?(pos1, pos2, game_board)
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
        @team = team
        @symbol = "p"
    end
    def legal_move?(pos1, pos2, game_board)
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
    def initialize()
        @board = Array.new(8,Array.new(8))
    end
    def reset_game
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
    def move_piece(pos1, pos2)
        piece = self.get_spot(pos1)
        return false if !piece
        legal = piece.legal_move?(pos1, pos2, self)
        if legal
            @board[pos2[0]][pos2[1]] = @board[pos1[0]][pos1[1]]
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

    def get_spot(pos)
    #    p "checking #{pos[0]} and #{pos[1]}"
        @board[pos[0]][pos[1]]
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
        for row in @board
            for spot in row
                if spot
                    print(spot.symbol)
                else
                    print("_")
                end
                
            end
            print "\n"
        end
        print "\n"
    end
    def show_legal_moves(pos)
        piece = get_spot(pos)
        return false if !piece
        legal_moves = []
        for i in (0..7)
            for j in (0..7)
                if piece.legal_move?(pos, [i,j], self)
                    print "X"
                    legal_moves << [i,j]
                else
                    spot = @board[i][j]
                    if spot
                        print(spot.symbol)
                    else
                        print("_")
                    end
                end
            end
            print "\n"
        end
        print "\n"
        return legal_moves
    end

end

board = GameBoard.new()
board.reset_game

while true do
    pos_1_0 = gets.chomp.to_i
    pos_1_1 = gets.chomp.to_i
    pos_1 = [pos_1_0, pos_1_1]
    board.show_legal_moves(pos_1)
    pos_2_0 = gets.chomp.to_i
    pos_2_1 = gets.chomp.to_i
    pos_2 = [pos_2_0, pos_2_1]
    board.move_piece(pos_1, pos_2)
    board.show_board
end


