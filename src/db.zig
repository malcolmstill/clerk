const std = @import("std");
const os = std.os;
const fmt = std.fmt;
const mem = std.mem;
const sqlite = @import("sqlite");
const print = @import("print.zig");
const migrations = @import("migration.zig").migrations;
const process = std.process;
var gpa = std.heap.GeneralPurposeAllocator(.{});

pub const Database = struct {
    db: sqlite.Db,
    alloc: mem.Allocator,

    pub fn init(
        alloc: mem.Allocator,
    ) !Database {
        const home = os.getenv("HOME") orelse "";
        const slices: [3][]const u8 = .{ home, "/", ".clerk.db" };
        const path = try mem.concatWithSentinel(alloc, u8, slices[0..], 0);
        defer alloc.free(path);

        var db = try sqlite.Db.init(.{
            .mode = sqlite.Db.Mode{ .File = path[0..] },
            .open_flags = .{
                .write = true,
                .create = true,
            },
            .threading_mode = .MultiThread,
        });

        _ = try db.pragma(void, .{}, "foreign_keys", "on");

        const row = (try db.pragma(usize, .{}, "user_version", null)) orelse return error.ReadUserVersionFailed;

        if (row < migrations.len) {
            inline for (migrations) |m, i| {
                if (i >= row) {
                    _ = try db.execMulti(m, .{});
                    _ = try db.pragma(
                        void,
                        .{},
                        "user_version",
                        comptime fmt.comptimePrint("{}", .{i + 1}),
                    );
                }
            }
        }

        return Database{
            .alloc = alloc,
            .db = db,
        };
    }

    pub fn deinit(self: *Database) void {
        self.db.deinit();
    }

    pub fn addTodo(self: *Database, text: []const u8, it: *process.ArgIterator) !usize {
        var savepoint = try self.db.savepoint("todo_with_references");
        defer savepoint.rollback();

        const id = try self.db.one(
            usize,
            "INSERT INTO todo (text, status) VALUES (?, 'TODO') RETURNING id;",
            .{},
            .{ .text = text },
        );

        while (it.next()) |arg| {
            const ref = try std.fmt.parseInt(usize, arg, 10);

            _ = try self.db.one(
                usize,
                "INSERT INTO ref (id, referer) VALUES (?, ?);",
                .{},
                .{ .ref = ref, .id = id },
            );
        }

        savepoint.commit();

        return id orelse return error.AddTodoFailed;
    }

    pub fn printTodo(self: *Database, stdout: anytype, id: usize) !void {
        var arena = std.heap.ArenaAllocator.init(self.alloc);
        defer arena.deinit();

        var stmt = try self.db.prepare("SELECT id, text, status FROM todo WHERE id = ?");
        defer stmt.deinit();

        const row = (try stmt.oneAlloc(
            struct { id: usize, text: []const u8, status: []const u8 },
            arena.allocator(),
            .{},
            .{ .id = id },
        )) orelse return error.NoRow;

        try print.todo(stdout, row.id, row.text, row.status);
    }

    pub fn markDone(self: *Database, id: usize) !void {
        _ = try self.db.one(
            usize,
            "UPDATE todo SET status = 'DONE' WHERE id = ?",
            .{},
            .{ .id = id },
        );
    }
};
