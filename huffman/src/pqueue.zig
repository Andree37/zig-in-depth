const std = @import("std");
const Node = @import("node.zig").Node;

const QueueError = error  {
    EmptyQueue
};

pub const PriorityQueue = struct{
    data: std.ArrayList(*Node),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !PriorityQueue {
        return PriorityQueue{
            .data= std.ArrayList(*Node).init(allocator),
            .allocator= allocator,
        };
    }

    pub fn deinit(self: *PriorityQueue) void {
        self.data.deinit();
    }

    pub fn isEmpty(self: *PriorityQueue) bool {
        return self.data.items.len == 0;
    }

    pub fn size(self: *PriorityQueue) usize {
        return self.data.items.len;
    }

    pub fn peek(self: *PriorityQueue) !u8 {
        if (self.isEmpty()) {
            return QueueError.EmptyQueue;
        }

        return self.data.items[0].letter;
    }

    pub fn push(self: *PriorityQueue, new_node: *Node) !void {
        if (self.isEmpty()) {
            try self.data.append(new_node);
            return;
        }

        for (self.data.items, 0..) |pitem, idx| {
            if (new_node.payload.frequency <= pitem.payload.frequency) {
                try self.data.insert(idx, new_node);
                return;
            }
        }

        try self.data.append(new_node);
    }

    pub fn poll(self: *PriorityQueue) !*Node {
        if (self.isEmpty()) {
            return QueueError.EmptyQueue;
        }

        const v = self.data.getLast();

        self.data.shrinkRetainingCapacity(self.data.items.len-1);

        return v;
    }
};
