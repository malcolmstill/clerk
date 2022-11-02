const sqlite = @import("sqlite");

pub const Database = struct {
    db: sqlite.Db,

    pub fn init() !Database {
        var db = try sqlite.Db.init(.{
            .mode = sqlite.Db.Mode{ .File = ".clerk.db" },
            .open_flags = .{
                .write = true,
                .create = true,
            },
            .threading_mode = .MultiThread,
        });

        return Database{
            .db = db,
        };
    }

    pub fn addTodo(_: *Database, _: []const u8) !usize {
        return 22;
    }
};
