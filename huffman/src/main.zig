const std = @import("std");


const LetterAmount = struct {
    letter: u8,
    amount: u8
};


const Node = struct {
    value: LetterAmount,
    left_node: ?*Node,
    right_node: ?*Node,
};


pub fn main() !void {
    const input = "AAABBBCCDDEFFFFF";
    const parsed_input = try parseInput(input);
    defer parsed_input.deinit();

    std.debug.print("parsed input: {any}", .{parsed_input});

}

fn parseInput(input_string: []const u8) !std.ArrayList(LetterAmount){
    const allocator = std.heap.page_allocator;

    var letters = std.ArrayList(u8).init(allocator);
    defer letters.deinit();
    var amount = std.ArrayList(u8).init(allocator);
    defer amount.deinit();


    for (input_string) |input| {
        var found = false;
        for (letters.items, 0..) |letter, idx| {
            if (letter == input) {
                amount.items[idx] += 1;
                found = true;
                break;
            }
        }

        if (!found) {
            try letters.append(input);
            try amount.append(1);
        }
    }

    var letter_amount_pairs = std.ArrayList(LetterAmount).init(allocator);

    for (letters.items, 0..) |letter, idx| {
        try letter_amount_pairs.append( .{ .letter=letter, .amount=amount.items[idx] });
    }

    std.mem.sort(LetterAmount, letter_amount_pairs.items, {}, struct {
        fn inner(_: void, a:LetterAmount, b:LetterAmount) bool {
           return a.amount < b.amount;
        }
    }.inner);

    return letter_amount_pairs;
}
