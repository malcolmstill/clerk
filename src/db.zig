const std = @import("std");
const fmt = std.fmt;
const sqlite = @import("sqlite");
const migrations = @import("migration.zig").migrations;
const process = std.process;

pub const Database = struct {
    db: sqlite.Db,

    pub fn init() !Database {
        var db = try sqlite.Db.init(.{
            .mode = sqlite.Db.Mode{ .File = "clerk.db" },
            .open_flags = .{
                .write = true,
                .create = true,
            },
            .threading_mode = .MultiThread,
        });

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
            .db = db,
        };
    }

    pub fn deinit(self: *Database) void {
        self.db.deinit();
    }

    pub fn addTodo(self: *Database, text: []const u8, _: process.ArgIterator) !usize {
        const query =
            \\INSERT INTO todo (text, status) VALUES (?, 'TODO') RETURNING id;
        ;

        const row = try self.db.one(usize, query, .{}, .{
            .text = text,
        });

        return row orelse return error.AddTodoFailed;
    }
};
