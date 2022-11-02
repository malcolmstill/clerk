const ansi = @import("ansi-term");
const format = ansi.format;
const style = ansi.style;

pub fn help(stdout: anytype) !void {
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

pub fn version(stdout: anytype) !void {
    const bold = .{ .font_style = style.FontStyle.bold };
    try format.updateStyle(stdout, bold, null);
    try stdout.print("clerk v0.0.1\n\n", .{});
    try format.updateStyle(stdout, .{}, bold);
}

pub fn err(stdout: anytype, message: []const u8) !void {
    const sty = .{ .foreground = style.Color.Red };
    try format.updateStyle(stdout, sty, null);
    try stdout.print("{s}", .{message});
    try format.updateStyle(stdout, .{}, sty);
}
