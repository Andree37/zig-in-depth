const std = @import("std");
const assert = @import("std").debug.assert;
const pqueue = @import("pqueue.zig");

pub const Node = struct {
    allocator: std.mem.Allocator,
    pItem: pqueue.PriorityItem,
    left_node: *Node,
    right_node: *Node,

    pub fn init(allocator: std.mem.Allocator) !Node {
        const node = try allocator.create(Node);

        return node;
    }

    pub fn pushNodes(self: *Node, left_node: *Node, right_node: *Node) !*Node {
        const pItem = try self.allocator.create(pqueue.PriorityItem);
        pItem.* = pqueue.PriorityItem{.priority = left_node.*.pItem.priority + right_node.*.pItem.priority };

        node.* = Node{
            .allocator = allocator,
            .pLetter = pItem,
            .left_node = left_node,
            .right_node = right_node,
        };

    }

    pub fn deinit(self: *Node) !void {
        self.allocator.destroy(self.pItem);

        if (self.left_node) {
            self.deinit(self.left_node);
        }

        if (self.right_node) {
            self.deinit(self.right_node);
        }

        self.allocator.destroy(self);
    }

    pub fn buildHoff(self: *Node, queue: *pqueue.PriorityQueue) !void {
        while (!queue.isEmpty()) {
            const new_node = self.init(self.allocator, try queue.poll(), try queue.poll());
            queue.push(new_node);
        }

        // generate the codes
    }
};
