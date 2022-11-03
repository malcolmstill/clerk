const std = @import("std");
const mem = std.mem;

pub const Command = enum {
    add,
    done,
    todo,
    status,
    edit,
    ref,
    unref,
    search,
};

pub fn parse(command: []const u8) !Command {
    if (mem.eql(u8, command, "add")) {
        return .add;
    } else if (mem.eql(u8, command, "done")) {
        return .done;
    } else if (mem.eql(u8, command, "todo")) {
        return .todo;
    } else if (mem.eql(u8, command, "status")) {
        return .status;
    } else if (mem.eql(u8, command, "edit")) {
        return .edit;
    } else if (mem.eql(u8, command, "ref")) {
        return .ref;
    } else if (mem.eql(u8, command, "unref")) {
        return .unref;
    } else if (mem.eql(u8, command, "search")) {
        return .search;
    } else {
        return error.UnknownCommand;
    }
}
