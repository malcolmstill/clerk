const std = @import("std");
const fs = std.fs;
const fmt = std.fmt;
const process = std.process;
const print = @import("print.zig");
const cmd = @import("command.zig");
const Database = @import("db.zig").Database;
const builtin = @import("builtin");

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();

    const io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: std.Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    const home = try getHome(init, allocator);

    var db = try Database.init(allocator, home);
    defer db.deinit();

    defer _ = stdout.flush() catch {};

    var it = try init.minimal.args.iterateAllocator(allocator);
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
        try stdout.flush();
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

fn getHome(init: std.process.Init, allocator: std.mem.Allocator) ![]const u8 {
    if (builtin.os.tag == .windows) {
        const homedrive = init.environ_map.get("homedrive") orelse return error.NoHomeDrive;
        const homepath = init.environ_map.get("homepath") orelse return error.NoHomePath;

        const slices: [2][]const u8 = .{ homedrive, homepath };
        return fs.path.joinZ(allocator, slices[0..]);
    } else {
        return init.environ_map.get("HOME") orelse return error.NoHome;
    }
}
