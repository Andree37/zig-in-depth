const std = @import("std");


const Color = enum {
    red,
    green,
    blue,
};

const Token = union(enum) {
    keyword_if,
    keyword_switch: void,
    digit: usize,

    fn is(self: Token, tag: std.meta.Tag(Token)) bool {
        return self == tag;
    }
};

pub fn main() !void {
    var potato: u8 = undefined;
    std.debug.print("the potato variable:{}\n", .{potato}); // trash memory stuff
    potato = 2;
    std.debug.print("the potato value again: {}\n", .{potato});

    const two: u8 = 2;
    const two_fifty: u8 = 250;
    var result = two_fifty *% two;
    std.debug.print("*% result: {}\n", .{result}); //warpping around
    result = two_fifty *| two;
    std.debug.print("*| result: {}\n", .{result}); // saturating

    // types coerce when it's safe
    const byte: u8 = 200;
    const word: u16 = 999;
    const dword: u32 = byte + word;
    std.debug.print("dword: {}\n", .{dword});
    // otherwise we need to cast
    const dword2: u16 = @intCast(dword);
    std.debug.print("dword2: {}\n", .{dword2});

    var arr: [2]u8 = undefined;
    arr[0] = 1;
    const multiarr: [2][2]u8 = [_][2]u8 {
        .{1, 2},
        .{2, 3}
    };
    std.debug.print("{}\n", .{multiarr[1][0]});

    var maybe_byte: ?u8 = null;
    std.debug.print("maybe byte: {?}\n", .{maybe_byte});
    maybe_byte = 4;
    std.debug.print("maybe byte: {?}\n", .{maybe_byte});

    // get the result or produce an error
    var the_byte = maybe_byte.?;

    // default operator
    the_byte = maybe_byte orelse 13;

    if (maybe_byte) |b| {
        std.debug.print("b is: {}\n", .{b});
    } else {
        std.debug.print("b is null\n", .{});
    }
    if (maybe_byte) |b| std.debug.print("inline maybe byte: {}\n", .{b});

    const x: u8 = blk: {
        const y: u8 = 13;
        const z = 42;
        break :blk y + z;
    };
    std.debug.print("x: {}\n", .{x});

    switch (x) {
        0...20 => std.debug.print("its o to 33\n", .{}),
        30, 31, 32 => |n| std.debug.print("n: {}", .{n}),
        77 => {
            const a = 1;
            const b = 2;
            std.debug.print("a+b: {}", .{a+b});
        },
        else => std.debug.print("None of the above\n", .{}),
    }

    const fav_color: Color = .red;
    std.debug.print("fav color is {s}", .{@tagName(fav_color)});
    _ = switch (fav_color) {
        .red => 1,
        .green => 10,
        else => 20
    };

    // pointers

    const sl: []u8 = &[_]u8{};
    std.debug.print("sl: {}", .{sl[0]});
}
