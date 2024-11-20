const std = @import("std");

const QueueError = error  {
    EmptyQueue
};

const PriorityItem = struct {
    priority: usize,
    letter: u8,
};

pub const PriorityQueue = struct{
    data: std.ArrayList(*PriorityItem),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !PriorityQueue {
        return PriorityQueue{
            .data= std.ArrayList(*PriorityItem).init(allocator),
            .allocator= allocator,
        };
    }

    pub fn deinit(self: *PriorityQueue) void {
        for (self.data.items) |item| {
            self.allocator.destroy(item);
        }
        self.data.deinit();
    }

    pub fn isEmpty(self: *PriorityQueue) bool {
        return self.data.items.len == 0;
    }

    pub fn peek(self: *PriorityQueue) !u8 {
        if (self.isEmpty()) {
            return QueueError.EmptyQueue;
        }

        return self.data.items[0].letter;
    }

    pub fn push(self: *PriorityQueue, item: u8, priority: usize) !void {
        const new_pitem = try self.allocator.create(PriorityItem);
        new_pitem.* = PriorityItem{.letter = item, .priority = priority};

        if (self.isEmpty()) {
            try self.data.append(new_pitem);
            return;
        }

        for (self.data.items, 0..) |pitem, idx| {
            if (priority <= pitem.priority) {
                try self.data.insert(idx, new_pitem);
                return;
            }
        }

        try self.data.append(new_pitem);
    }

    pub fn pop(self: *PriorityQueue) ?u8 {
        if (self.isEmpty()) {
            return QueueError.EmptyQueue;
        }

        const v = self.data.getLast();

        self.data.shrinkRetainingCapacity(self.data.items.len-1);

        return v.item;
    }
};
