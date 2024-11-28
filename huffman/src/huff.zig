const std = @import("std");
const node = @import("node.zig");
const pqueue = @import("pqueue.zig");

pub const Huffman = struct {
    allocator: std.mem.Allocator,
    root: *node.Node,
    original_text: []u8,
    char_freqs: std.AutoHashMap(u8, u8),
    generate_huff: std.AutoHashMap(u8, []u8),

    pub fn init(allocator: std.mem.Allocator, text: []u8) !Huffman {
        const root = try node.Node.init(allocator, 0, null, null, null);
        const huff = try allocator.create(Huffman);
        huff.* = Huffman{
            .allocator = allocator,
            .root = root,
            .original_text = text,
            .char_freqs = std.AutoHashMap(u8, u8).init(allocator.*),
            .generated_huff = std.AutoHashMap(u8, []u8).init(allocator.*),
        };

        try huff.fillCharFrequenciesMap();

        return huff.*;
    }

    pub fn deinit(self: *Huffman) !void {
        try self.char_freqs.deinit();
        try self.generate_huff.deinit();
        try self.root.deinit();
    }

    pub fn encode(self: *Huffman) ![]u8 {
        var queue = try pqueue.PriorityQueue.init(self.allocator);
        defer queue.deinit();

        var map_iterator = self.char_freqs.iterator();
        while(map_iterator.next()) |entry|{
            const new_pitem = try allocator.create(pqueue.PriorityItem);
            new_pitem.* = pqueue.PriorityItem{.letter = entry.key_ptr.*, .priority = entry.value_ptr.*};

            try queue.push(new_pitem);
        }

        return queue;
    }

    fn fillCharFrequenciesMap(self: *Huffman) !void {
        for (self.input_string) |input| {
            var v = self.char_freqs.get(input) orelse 0;
            v += 1;
            try self.char_freqs.put(input, v);
        }
    }
};
