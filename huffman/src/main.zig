const std = @import("std");
const String = @import("string").String;
const Huffman = @import("huff.zig").Huffman;

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(general_purpose_allocator.deinit() == .ok);

    const allocator = general_purpose_allocator.allocator();

    const input = try String.init_with_contents(allocator, "AAABBBCCDDEFFFFF");
    defer input.deinit();

    const huff = try Huffman.init(allocator, input);
    defer huff.deinit();

    const encoded_text = huff.encode();
    std.debug.print("encoded text: {}", .{encoded_text});

    huff.printCodes();

    const original_text = try huff.decode(encoded_text);
    std.debug.print("original text: {}", .{original_text});
}
