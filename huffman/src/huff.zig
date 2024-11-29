const std = @import("std");
const Node = @import("node.zig").Node;
const PriorityQueue = @import("pqueue.zig").PriorityQueue;
const String = @import("string").String;

pub const Huffman = struct {
    allocator: std.mem.Allocator,
    root: *Node,
    original_text: String,
    char_freqs: std.AutoHashMap([]u8, u8),
    huffman_codes: std.AutoHashMap(u8, String),

    pub fn init(allocator: std.mem.Allocator, text: String) !Huffman {
        const root = try Node.init(allocator, 0, null, null, null);
        const huff = try allocator.create(Huffman);
        huff.* = Huffman{
            .allocator = allocator,
            .root = root,
            .original_text = text,
            .char_freqs = std.AutoHashMap([]u8, u8).init(allocator),
            .huffman_codes = std.AutoHashMap(u8, String).init(allocator),
        };

        try huff.fillCharFrequenciesMap();

        return huff.*;
    }

    pub fn deinit(self: *Huffman) !void {
        try self.char_freqs.deinit();
        try self.generate_huff.deinit();
        try self.root.deinit();
        try self.original_text.deinit();
    }

    pub fn encode(self: *Huffman) !String {
        var queue = try PriorityQueue.init(self.allocator);
        defer queue.deinit();

        var char_freq_iterator = self.char_freqs.iterator();
        while(char_freq_iterator.next()) |entry| {
            try queue.push(try Node.init(self.allocator, entry.value_ptr.*, entry.key_ptr.*, null, null));
        }

        while(!queue.size() > 1) {
            const first_node = try queue.poll();
            const second_node = try queue.poll();

            const freq = first_node.payload.frequency + second_node.payload.frequency;
            queue.push(try Node.init(self.allocator, freq, null, first_node, second_node));
        }

        self.generateHuffmanCodes(queue.poll(), "");
        return self.getEncodedText();
    }

    pub fn decode(self: *Huffman, encoded_text: String) !String {
        var str = String.init(self.allocator);
        var current: Node = self.root;

        var encoded_text_iterator = encoded_text.iterator();
        while (encoded_text_iterator.next()) |char| {
            current = if (char == '0') current.left_node else current.right_node;
            if (current.?.payload.letter != null) {
                str.concat(current.?.payload.letter);
                current = self.root;
            }
        }

        return str;
    }

    pub fn printCodes(self: *Huffman) void {
        var iterator = self.huffman_codes.iterator();
        while(iterator.next()) |entry| {
            std.debug.print("{}:{}", .{entry.key_ptr.*, entry.value_ptr.*});
        }
    }

    fn fillCharFrequenciesMap(self: *Huffman) !void {
        var original_text_iterator = self.original_text.iterator();
        while (original_text_iterator.next()) |input| {
            var v = self.char_freqs.get(input) orelse 0;
            v += 1;
            try self.char_freqs.put(input, v);
        }
    }

    fn generateHuffmanCodes(self: *Huffman, root: Node, code: String) void{
        if (root.payload.letter != null) {
            self.huffman_codes.put(root.payload.letter, code);
            return;
        }

        self.generateHuffmanCodes(root.left_node, try code.concat('0'));
        self.generateHuffmanCodes(root.right_node, try code.concat('1'));
    }

    fn getEncodedText(self: *Huffman) !String {
        var str = String.init(self.allocator);
        const original_text_iterator = self.original_text.iterator();
        while (original_text_iterator.next()) |char| {
            try str.concat(self.huffman_codes.get(char));
        }

        return str;
    }
};
