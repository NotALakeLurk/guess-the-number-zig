const std = @import("std");

// constants
const min_num: u8 = 0;
const max_num: u8 = 99;
const guess_count: u8 = 7;

pub fn main() !void {
    // get a seed for our prng
    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));

    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();

    // determine the number that the user must guess
    const target_number = rand.intRangeAtMost(u8, min_num, max_num);

    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    // 10 bytes to fit up to "100\n" or even "0b1100100\n" lol
    var guess_buf: [10]u8 = undefined;

    for (0..guess_count) |i| {
        try stdout.print("(Guess {d}/{d}) Guess a number {d} through {d}: ", .{
            i + 1,
            guess_count,
            min_num,
            max_num,
        });

        // just a note - I really like this read syntax, better than Rust
        // reads, honestly -
        // get user guess and check
        const raw_guess_slice = try stdin.readUntilDelimiter(&guess_buf, '\n');
        const guess_slice = std.mem.trim(u8, raw_guess_slice, "\r");
        const guess = std.fmt.parseInt(u8, guess_slice, 0) catch {
            try stdout.writeAll("Please input an int!\n");
            // give the user another chance
            // they still lose the guess though,,, lmao
            continue;
        };

        if (guess == target_number) {
            try stdout.writeAll("Yay! You guessed it!\n");
            return;
        }

        // nice, feels Rusty!
        const guess_relation: u8 = switch (guess < target_number) {
            true => '<',
            false => '>',
        };

        try stdout.print("Wrong, guess again! (Hint: {d}{c}??)\n", .{
            guess,
            guess_relation,
        });
    }

    try stdout.print("Too bad, you lose! The answer was {d}!\n", .{target_number});
}
