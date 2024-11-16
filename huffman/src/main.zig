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

    var map = std.AutoHashMap(u8, u8).init(allocator);
    defer map.deinit();

    for (input_string) |input| {
        const v = try map.getOrPut(input);
        if (!v.found_existing) {
            v.value_ptr.* = 1;
        } else {
            v.value_ptr.* = v.value_ptr.* + 1;
        }
    }

    var letter_amount_pairs = std.ArrayList(LetterAmount).init(allocator);

    var map_iterator = map.iterator();
    while(map_iterator.next()) |entry|{
        try letter_amount_pairs.append( .{ .letter=entry.key_ptr.*, .amount=entry.value_ptr.* });
    }

    std.mem.sort(LetterAmount, letter_amount_pairs.items, {}, struct {
        fn inner(_: void, a:LetterAmount, b:LetterAmount) bool {
           return a.amount < b.amount;
        }
    }.inner);

    return letter_amount_pairs;
}
