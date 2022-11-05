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
    var allocator = gpa.allocator();

    const stdout_file = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var db = try Database.init(allocator);
    defer db.deinit();

    defer _ = bw.flush() catch {};

    var it = try process.argsWithAllocator(allocator);
    defer it.deinit();

    _ = it.next();

    const command_arg = it.next() orelse {
        try print.help(stdout);
        return;
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
                try print.addExpectsText(stdout);
                return;
            };

            const id = try db.addTodo(text, &it);
            try db.printTodo(stdout, id);
        },
        .done => {
            const arg = it.next() orelse {
                try print.doneExpectsId(stdout);
                return;
            };

            const id = try fmt.parseInt(usize, arg, 10);
            db.markDone(id) catch {
                try print.noSuchId(stdout, id);
                return;
            };

            try db.printTodo(stdout, id);
        },
        .list => try db.printAllTodos(stdout),
        .search => {
            const search_term = it.next() orelse {
                try print.searchExpectsTerm(stdout);
                return;
            };

            try db.search(stdout, search_term);
        },
    }
}
