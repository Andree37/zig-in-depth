const std = @import("std");
const pqueue = @import("pqueue.zig");
const hoff = @import("hoff.zig");


pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(general_purpose_allocator.deinit() == .ok);

    const allocator = general_purpose_allocator.allocator();

    const input = "AAABBBCCDDEFFFFF";
    var queue = try parseInput(input, &allocator);
    defer queue.deinit();

    std.debug.print("Priority queue: {any}\n", .{queue.data.items});

    const root = hoff.Node.init(allocator,null,null);
    defer root.deinit();

    try root.buildHoff(queue);
}

fn parseInput(input_string: []const u8, allocator: *const std.mem.Allocator) !pqueue.PriorityQueue{
    var map = std.AutoHashMap(u8, usize).init(allocator.*);
    defer map.deinit();

    for (input_string) |input| {
        var v = map.get(input) orelse 0;
        v += 1;
        try map.put(input, v);
    }

    var queue = try pqueue.PriorityQueue.init(allocator.*);
    var map_iterator = map.iterator();
    while(map_iterator.next()) |entry|{
        const new_pitem = try allocator.create(pqueue.PriorityItem);
        new_pitem.* = pqueue.PriorityItem{.letter = entry.key_ptr.*, .priority = entry.value_ptr.*};

        try queue.push(new_pitem);
    }

    return queue;
}
