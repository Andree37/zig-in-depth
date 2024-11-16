const std = @import("std");


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

    std.debug.print("parsed input: {any}\n", .{parsed_input});

    var huff_root = try mapInputIntroTree(parsed_input, &allocator);
    defer {
        huff_root.deinit(&allocator);
        allocator.destroy(huff_root);
    }


    std.debug.print("huff root: {any}\n", .{huff_root});
}

fn mapInputIntroTree(letter_amounts: std.ArrayList(LetterAmount), allocator: *const std.mem.Allocator) !*Node {
    var root = try allocator.*.create(Node);
    root.* = Node{ .left_node = null, .right_node = null, .value =null};

    for (letter_amounts.items) |la| {
        if (root.right_node == null) {
            const new_node = try allocator.*.create(Node);
            new_node.* = Node{.left_node = null, .right_node = null, .value = la};
            root.right_node = new_node;
        } else if (root.left_node == null) {
            const new_node = try allocator.*.create(Node);
            new_node.* = Node{.left_node = null, .right_node = null, .value = la};
            root.left_node = new_node;
        } else if (root.value == null) {
            root.value = la;
        } else {
            // create a new root and define this as the right child of that
            const old_root = root;
            root = try allocator.*.create(Node);
            root.* = Node{.left_node = null, .right_node = old_root, .value = null};
        }
    }

    return root;
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
