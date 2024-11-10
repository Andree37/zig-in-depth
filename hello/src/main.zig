const std = @import("std");

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



}
