const std = @import("std");
const mem = std.mem;
const ansi = @import("ansi-term");
const format = ansi.format;
const style = ansi.style;

pub fn help(stdout: anytype) !void {
    try version(stdout);
    try stdout.print("\n", .{});
    try stdout.print("    list             List todos\n", .{});
    try stdout.print("    todo [text]      Add a new todo\n", .{});
    try stdout.print("    done [id]        Mark todo as done\n", .{});
    try stdout.print("    search [text]    Search todos\n", .{});
    // try stdout.print("\tstatus [id] [status]\tChange status\n", .{});
    // try stdout.print("\tedit [id]\t\tEdit todo as done\n", .{});
    // try stdout.print("\tref [id] [refs..]\tAdd references to todo\n", .{});
    // try stdout.print("\tunref [id] [ref]\tRemove [ref] from [id]\n", .{});
    try stdout.print("\n", .{});
}

const version_number = @embedFile(".version");

pub fn version(stdout: anytype) !void {
    const bold = .{ .font_style = style.FontStyle.bold };
    try format.updateStyle(stdout, bold, null);
    try stdout.print("clerk {s}\n", .{version_number});
    try format.updateStyle(stdout, .{}, bold);
}

pub fn err(stdout: anytype, message: []const u8) !void {
    const sty = .{ .foreground = style.Color.Red };
    try format.updateStyle(stdout, sty, null);
    try stdout.print("{s}", .{message});
    try format.updateStyle(stdout, .{}, sty);
}

pub fn todo(stdout: anytype, id: usize, text: []const u8, status: []const u8) !void {
    try stdout.print("[", .{});
    try format.updateStyle(stdout, yellow, null);
    try stdout.print("{}", .{id});
    try format.updateStyle(stdout, .{}, yellow);
    try stdout.print("] ", .{});

    if (mem.eql(u8, status, "TODO")) {
        try format.updateStyle(stdout, red, null);
        try stdout.print("{s}", .{status});
    } else if (mem.eql(u8, status, "DONE")) {
        try format.updateStyle(stdout, green, null);
        try stdout.print("{s}", .{status});
    }
    try format.updateStyle(stdout, .{}, null);

    try format.updateStyle(stdout, .{}, null);
    try stdout.print(" {s}\n", .{text});
    try format.updateStyle(stdout, .{}, null);
}

pub fn addExpectsText(stdout: anytype) !void {
    try err(stdout, "Expected: clerk add <text>\n");
}

pub fn searchExpectsTerm(stdout: anytype) !void {
    try err(stdout, "Expected: clerk search <term>\n");
}

pub fn doneExpectsId(stdout: anytype) !void {
    try err(stdout, "Expected: clerk done <id>\n");
}

pub fn noSuchId(stdout: anytype, id: usize) !void {
    try stdout.print("Couldn't find [", .{});
    try format.updateStyle(stdout, yellow, null);
    try stdout.print("{}", .{id});
    try format.updateStyle(stdout, .{}, null);
    try stdout.print("]\n", .{});
}

const yellow = .{ .foreground = style.Color.Yellow, .font_style = style.FontStyle.bold };
const red = .{ .foreground = style.Color.Red, .font_style = style.FontStyle.bold };
const green = .{ .foreground = style.Color.Green, .font_style = style.FontStyle.bold };
