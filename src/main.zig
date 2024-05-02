const std = @import("std");
const fmt = std.fmt;

// 3x3 board
const BOARD_SIZE = 3;

const Player = enum {
    player_1,
    player_2,
};

const Mark = enum {
    Empty,
    X,
    O,
};

const MoveError = error{
    InvalidMove,
    InvalidSquare,
};

// This converts the Mark enum to it's string equivalent
fn markToStr(comptime mark: Mark) u8 {
    const choice = switch (mark) {
        Mark.Empty => '-',
        Mark.X => 'X',
        Mark.O => 'O',
    };
    return choice;
}

const State = struct {
    board: [BOARD_SIZE][BOARD_SIZE]Mark,
    turn: Player,
    winner: Player,

    const Self = @This();

    pub fn printBoard(self: *Self) !void {
        std.debug.print("\n", .{});
        for (self.board) |row| {
            const sep = '|';
            for (row) |cell| {
                std.debug.print("{}", .{cell});
                std.debug.print("{}", .{sep});
            }
            std.debug.print("\n", .{});
            std.debug.print("------\n", .{});
        }
    }

    pub fn spaceValid(self: *Self, r: u8, c: u8) bool {
        return self.board[r][c] == Mark.Empty;
    }

    fn getPiece(p: Player) Mark {
        switch (p) {
            Player.player_1 => return Mark.X,
            Player.player_2 => return Mark.O,
        }
    }

    // Since the board is integer based 1-9 we get the corresponding
    // row and col based on the integer.
    fn getRowColFromNumber(square: u8) [2]u8 {
        const row = ((square - 1) / BOARD_SIZE);
        const col = ((square - 1) % BOARD_SIZE);
        return .{ row, col };
    }

    pub fn setNextTurn(self: *Self) void {
        switch (self.turn) {
            Player.player_1 => self.turn = Player.player_2,
            Player.player_2 => self.turn = Player.player_1,
        }
    }

    pub fn makeMove(self: *Self, s: u8) bool {
        const rca = getRowColFromNumber(s);
        if (rca.len != 2) {
            return false;
        }

        const row = rca[0];
        const col = rca[1];

        if ((row < 0 or row > 2) or (col < 0 or row > 2)) {
            return false;
        }

        if (!spaceValid(self, row, col)) {
            return false;
        }

        // We should have a valid move, make the move!
        self.board[row][col] = getPiece(self.turn);
        setNextTurn(self);
        return true;
    }

    // refactor this
    fn checkWinner(b: [][]Mark) Mark {
        // Check rows
        for (b) |row| {
            if (row[0] != Mark.Empty and row[0] == row[1] and row[0] == row[2]) {
                return row[0];
            }
        }

        // Check columns
        for (0..BOARD_SIZE) |col| {
            if (b[0][col] != Mark.Empty and
                b[0][col] == b[1][col] and
                b[0][col] == b[2][col])
            {
                return b[0][col];
            }
        }

        // Check diagonals
        if (b[0][0] != Mark.Empty and
            b[0][0] == b[1][1] and
            b[0][0] == b[2][2])
        {
            return b[0][0];
        }

        if (b[0][2] != Mark.Empty and
            b[0][2] == b[1][1] and
            b[0][2] == b[2][0])
        {
            return b[0][2];
        }

        return Mark.Empty; // No winner
    }
};

fn getSquareChoice() !u8 {
    const stdin = std.io.getStdIn();
    var in: [4]u8 = undefined;

    const cnt = try stdin.read(&in);

    if (cnt < 1 or cnt > in.len) {
        return MoveError.InvalidSquare;
    }

    const choice = std.mem.trimRight(u8, in[0..cnt], "\r\n");
    return fmt.parseUnsigned(u8, choice, 10) catch {
        return MoveError.InvalidSquare;
    };
}

pub fn main() !void {
    var s = State{
        .board = [BOARD_SIZE][BOARD_SIZE]Mark{
            [_]Mark{ Mark.Empty, Mark.Empty, Mark.Empty },
            [_]Mark{ Mark.Empty, Mark.Empty, Mark.Empty },
            [_]Mark{ Mark.Empty, Mark.Empty, Mark.Empty },
        },
        .turn = Player.player_1,
        .winner = undefined,
    };
    var state = &s;

    // Game loop
    while (state.winner == undefined) {
        try state.printBoard();

        const square = try getSquareChoice();

        if (!state.makeMove(square)) {
            std.debug.print("Invalid move, try again.\n", .{});
            continue;
        }

        // Check for a winner

    }
}
