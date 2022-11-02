const std = @import("std");
const io = std.io;
const mem = std.mem;
const process = std.process;

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var it = process.args();

    _ = it.next(); // Skip "clerk"

    const command = it.next() orelse {
        try printVersion(stdout);
        try stdout.print("Expected <command>\n\n", .{});
        try stdout.print("Commands:\n", .{});
        try printHelp(stdout);
        try bw.flush(); // don't forget to flush!
        process.exit(1);
    };

    if (mem.eql(u8, command, "todo")) {
        const text = it.next() orelse return;

        try stdout.print("[1242] TODO: {s}\n", .{text});
    } else if (mem.eql(u8, command, "done")) {
        //
    } else {
        try printVersion(stdout);
        try stdout.print("Unknown command: \"{s}\"\n\n", .{command});
        try stdout.print("Commands:\n", .{});
        try printHelp(stdout);
    }

    try bw.flush(); // don't forget to flush!
}

fn printHelp(stdout: anytype) !void {
    try stdout.print("\n", .{});
    try stdout.print("\ttodo [text]\t\tAdd a new todo\n", .{});
    try stdout.print("\tdone [id]\t\tMark todo as done\n", .{});
    try stdout.print("\tstatus [id] [status]\tChange status\n", .{});
    try stdout.print("\tedit [id]\t\tEdit todo as done\n", .{});
    try stdout.print("\tref [id] [refs..]\tAdd references to todo\n", .{});
    try stdout.print("\tunref [id] [ref]\tRemove [ref] from [id]\n", .{});
    try stdout.print("\tsearch [text]\t\tMark todo as done\n", .{});
    try stdout.print("\n", .{});
}

fn printVersion(stdout: anytype) !void {
    try stdout.print("clerk v0.0.1\n\n", .{});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
