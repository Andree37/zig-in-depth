const std = @import("std");

pub const Payload = struct {
    frequency: u8,
    letter: ?[]u8,
};

pub const Node = struct {
    allocator: std.mem.Allocator,
    payload: Payload,
    left_node: ?*Node,
    right_node: ?*Node,

    pub fn init(allocator: std.mem.Allocator, frequency: u8, letter: ?[]u8, left_node: ?*Node, right_node: ?*Node) !*Node {
        const new_payload = try allocator.create(Payload);
        new_payload.* = Payload {
            .frequency = frequency,
            .letter = letter
        };
        const new_node = try allocator.create(Node);

        new_node.* = Node{
            .allocator = allocator,
            .payload = new_payload.*,
            .left_node = left_node,
            .right_node = right_node,
        };

        return new_node;
    }

    pub fn deinit(self: *Node) void {
        if (self.left_node != null) {
            self.left_node.?.deinit();
        }
        if (self.right_node != null) {
            self.right_node.?.deinit();
        }

        self.allocator.destroy(self);
    }

    pub fn build_node(allocator: std.mem.Allocator, left_node: *Node, right_node: *Node, letter: ?[]u8) !*Node {
        const freq = if (left_node != null and right_node != null) left_node.payload.frequency + right_node.payload.frequency else 0;
        return try init(allocator, freq, letter, left_node, right_node);
    }
};
