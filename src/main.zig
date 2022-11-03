const std = @import("std");
const fs = std.fs;
const io = std.io;
const fmt = std.fmt;
const process = std.process;
const print = @import("print.zig");
const cmd = @import("command.zig");
const Database = @import("db.zig").Database;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    defer _ = gpa.deinit();

    const stdout_file = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var db = try Database.init(gpa.allocator());
    defer db.deinit();

    var it = process.args();

    _ = it.next(); // Skip "clerk"

    const command_arg = it.next() orelse {
        try print.version(stdout);
        try print.err(stdout, "Expected <command>\n\n");
        try stdout.print("Commands:\n", .{});
        try print.help(stdout);
        try bw.flush();
        process.exit(1);
    };

    const command = cmd.parse(command_arg) catch {
        try print.version(stdout);
        try print.err(stdout, "Unknown command: ");
        try stdout.print("{s}\n\n", .{command_arg});
        try stdout.print("Commands:\n", .{});
        try print.help(stdout);
        try bw.flush();
        process.exit(1);
    };

    switch (command) {
        .todo => {
            const text = it.next() orelse {
                try print.version(stdout);
                try print.err(stdout, "Expected: clerk todo <text>\n\n");
                try bw.flush();
                process.exit(1);
            };

            const id = try db.addTodo(text, &it);
            try db.printTodo(stdout, id);
        },
        .done => {
            const arg = it.next() orelse {
                try print.version(stdout);
                try print.err(stdout, "Expected: clerk done <id>\n\n");
                try bw.flush();
                process.exit(1);
            };

            const id = try fmt.parseInt(usize, arg, 10);
            try db.markDone(id);
            try db.printTodo(stdout, id);
        },
        else => {},
    }

    try bw.flush();
}
