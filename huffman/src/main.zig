const std = @import("std");
const String = @import("string").String;
const Huffman = @import("huff.zig").Huffman;

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(general_purpose_allocator.deinit() == .ok);

    const allocator = general_purpose_allocator.allocator();

    var input = try String.init_with_contents(allocator, "AAABBBCCDDEFFFFF");
    defer input.deinit();

    var huff = try Huffman.init(allocator, input);
    defer huff.deinit();

    const encoded_text = try huff.encode();
    std.debug.print("encoded text: {any}\n", .{encoded_text});

    huff.printCodes();

    const original_text = try huff.decode(encoded_text);
    std.debug.print("original text: {any}\n", .{original_text});
}
