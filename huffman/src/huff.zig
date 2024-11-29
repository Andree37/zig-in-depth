const std = @import("std");
const Node = @import("node.zig").Node;
const PriorityQueue = @import("pqueue.zig").PriorityQueue;
const String = @import("string").String;

pub const Huffman = struct {
    allocator: std.mem.Allocator,
    root: *Node,
    original_text: String,
    char_freqs: std.StringArrayHashMap(u8),
    huffman_codes: std.StringArrayHashMap(String),

    pub fn init(allocator: std.mem.Allocator, text: String) !Huffman {
        const root = try Node.init(allocator, 0, null, null, null);
        const huff = try allocator.create(Huffman);
        huff.* = Huffman{
            .allocator = allocator,
            .root = root,
            .original_text = text,
            .char_freqs = std.StringArrayHashMap(u8).init(allocator),
            .huffman_codes = std.StringArrayHashMap(String).init(allocator),
        };

        try huff.fillCharFrequenciesMap();

        return huff.*;
    }

    pub fn deinit(self: *Huffman) void {
        self.char_freqs.deinit();
        self.huffman_codes.deinit();
        self.root.deinit();
        self.original_text.deinit();
    }

    pub fn encode(self: *Huffman) !String {
        var queue = try PriorityQueue.init(self.allocator);
        defer queue.deinit();

        var char_freq_iterator = self.char_freqs.iterator();
        while(char_freq_iterator.next()) |entry| {
            const loose_key: []u8 = @constCast(entry.key_ptr.*);
            try queue.push(try Node.init(self.allocator, entry.value_ptr.*, loose_key, null, null));
        }

        while(queue.size() > 1) {
            const first_node = try queue.poll();
            const second_node = try queue.poll();

            const freq = first_node.payload.frequency + second_node.payload.frequency;
            try queue.push(try Node.init(self.allocator, freq, null, first_node, second_node));
        }

        var str = String.init(self.allocator);
        defer str.deinit();

        try self.generateHuffmanCodes(try queue.poll(), str);
        return self.getEncodedText();
    }

    pub fn decode(self: *Huffman, encoded_text: String) !String {
        var str = String.init(self.allocator);
        var current = self.root;

        var encoded_text_iterator = encoded_text.iterator();
        while (encoded_text_iterator.next()) |char| {
            std.debug.print("current char: {any}\n", .{char});
            current = if (std.mem.eql(u8, char, "0")) current.left_node.? else current.right_node.?;
            if (current.payload.letter != null) {
                try str.concat(current.payload.letter.?);
                current = self.root;
            }
        }

        return str;
    }

    pub fn printCodes(self: *Huffman) void {
        var iterator = self.huffman_codes.iterator();
        while(iterator.next()) |entry| {
            std.debug.print("{any}:{any}\n", .{entry.key_ptr.*, entry.value_ptr.*});
        }
    }

    fn fillCharFrequenciesMap(self: *Huffman) !void {
        var original_text_iterator = self.original_text.iterator();
        while (original_text_iterator.next()) |input| {
            const in_loose: []u8 = @constCast(input);
            var v = self.char_freqs.get(in_loose) orelse 0;
            v += 1;
            try self.char_freqs.put(in_loose, v);
        }
    }

    fn generateHuffmanCodes(self: *Huffman, root: *Node, code: String) !void{
        if (root.payload.letter != null) {
            try self.huffman_codes.put(root.payload.letter.?, code);
            return;
        }
        var left_code = try code.clone();
        try left_code.concat("0");

        var right_code = try code.clone();
        try right_code.concat("1");

        try self.generateHuffmanCodes(root.left_node.?, left_code);
        try self.generateHuffmanCodes(root.right_node.?, right_code);
    }

    fn getEncodedText(self: *Huffman) !String {
        var str = String.init(self.allocator);
        var original_text_iterator = self.original_text.iterator();
        while (original_text_iterator.next()) |char| {
            const char_loose: []u8 = @constCast(char);
            const char_to_concat = self.huffman_codes.get(char_loose);
            try str.concat(char_to_concat.?.str());
        }

        return str;
    }
};
