const std = @import("std");
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
        var db = try sqlite.Db.init(.{
            .mode = sqlite.Db.Mode{ .File = "clerk.db" },
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
        var stmt = try self.db.prepare("SELECT id, text, status FROM todo WHERE id = ?");
        defer stmt.deinit();

        const row = (try stmt.oneAlloc(
            struct { id: usize, text: []u8, status: []u8 },
            self.alloc,
            .{},
            .{ .id = id },
        )) orelse return error.NoRow;

        try print.todo(stdout, row.id, row.text, row.status);
    }
};
