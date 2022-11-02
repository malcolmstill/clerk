const std = @import("std");
const fs = std.fs;
const io = std.io;
const process = std.process;
const print = @import("print.zig");
const cmd = @import("command.zig");
const Database = @import("db.zig").Database;

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var db = try Database.init();

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

            const id = try db.addTodo(text);

            try stdout.print("[{}] TODO: {s}\n", .{ id, text });
        },
        else => {},
    }

    try bw.flush(); // don't forget to flush!
}
