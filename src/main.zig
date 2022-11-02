const std = @import("std");
const sqlite = @import("sqlite");
const fs = std.fs;
const io = std.io;
const process = std.process;
const print = @import("print.zig");
const cmd = @import("command.zig");

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    _ = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .File = ".clerk.db" },
        .open_flags = .{
            .write = true,
            .create = true,
        },
        .threading_mode = .MultiThread,
    });

    var it = process.args();

    _ = it.next(); // Skip "clerk"

    const command_arg = it.next() orelse {
        try print.version(stdout);
        try print.err(stdout, "Expected <command>\n\n");
        try stdout.print("Commands:\n", .{});
        try print.help(stdout);
        try bw.flush(); // don't forget to flush!
        process.exit(1);
    };

    const command = cmd.parse(command_arg) catch {
        try print.version(stdout);
        try print.err(stdout, "Unknown command: ");
        try stdout.print("{s}\n\n", .{command_arg});
        try stdout.print("Commands:\n", .{});
        try print.help(stdout);
        try bw.flush(); // don't forget to flush!
        process.exit(1);
    };

    switch (command) {
        .todo => {
            const text = it.next() orelse {
                try print.version(stdout);
                try print.err(stdout, "Expected: clerk todo <text>\n\n");
                try bw.flush(); // don't forget to flush!
                process.exit(1);
            };

            try stdout.print("[1242] TODO: {s}\n", .{text});
        },
        else => {},
    }

    try bw.flush(); // don't forget to flush!
}
