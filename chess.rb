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


class GameBoard
    def initialize()
        @board = Array.new(8,Array.new(8))
    end
    def reset_game
        @board = 
       [[nil, nil, nil, King.new(0), nil, nil, nil, nil],                                      
        [nil, nil, nil, nil, nil, nil, nil, nil],                                      
        [nil, nil, nil, nil, nil, nil, nil, nil],                                      
        [nil, nil, nil, Rook.new(0), King.new(1), nil, nil, nil],                                      
        [nil, Queen.new(0), nil, nil, nil, nil, nil, nil],                                      
        [nil, nil, nil, nil, nil, nil, Knight.new(1), nil],                                      
        [nil, nil, nil, nil, nil, nil, nil, nil],                                      
        [nil, nil, nil, Bishop.new(0), nil, nil, nil, nil]]
    end
    def move_piece(pos1, pos2)
        piece = self.get_spot(pos1)
        legal = piece.legal_move?(pos1, pos2, self)
        if legal
            @board[pos2[0]][pos2[1]] = @board[pos1[0]][pos1[1]]
            @board[pos1[0]][pos1[1]] = nil
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
board.show_board
board.move_piece([3,3],[3,5])
board.show_board
board.move_piece([7,3],[6,2])
board.show_board
board.show_legal_moves([6,2])
board.show_legal_moves([5,6])