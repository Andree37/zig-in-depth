const std = @import("std");
const pqueue = @import("pqueue.zig");


const LetterAmount = struct {
    letter: u8,
    amount: usize
};


const Node = struct {
    value: ?LetterAmount,
    left_node: ?*Node,
    right_node: ?*Node,

    pub fn deinit(self: *Node, allocator: *const std.mem.Allocator) void {
        if (self.left_node) |left| {
            left.deinit(allocator);
            allocator.*.destroy(left);
        }
        if (self.right_node) |right| {
            right.deinit(allocator);
            allocator.*.destroy(right);
        }
    }
};


pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(general_purpose_allocator.deinit() == .ok);

    const allocator = general_purpose_allocator.allocator();

    const input = "AAABBBCCDDEFFFFF";
    const parsed_input = try parseInput(input, &allocator);
    defer parsed_input.deinit();

    var queue = try pqueue.PriorityQueue.init(allocator);
    defer queue.deinit();

    try queue.push(1, 1);
    try queue.push(1, 2);

    std.debug.print("here is the glorious queue: {any}\n", .{queue.data.items});

    const something = try queue.peek();
    std.debug.print("Something: {}", .{something});
}



fn parseInput(input_string: []const u8, allocator: *const std.mem.Allocator) !std.ArrayList(LetterAmount){
    var map = std.AutoHashMap(u8, usize).init(allocator.*);
    defer map.deinit();

    for (input_string) |input| {
        var v = map.get(input) orelse 0;
        v += 1;
        try map.put(input, v);
    }

    var letter_amount_pairs = std.ArrayList(LetterAmount).init(allocator.*);
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
