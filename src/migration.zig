pub const migrations = [_][]const u8{
    @embedFile("0001.init.sql"),
};
