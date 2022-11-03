CREATE TABLE status (
    id TEXT PRIMARY KEY
);
--
CREATE TABLE todo (
    id INTEGER PRIMARY KEY NOT NULL,
    status TEXT NOT NULL,
    text TEXT NOT NULL,
    FOREIGN KEY(status) REFERENCES status(id)
);
-- 
CREATE TABLE ref (
    id INTEGER NOT NULL,
    referer INTEGER NOT NULL,

    PRIMARY KEY (id, referer),
    FOREIGN KEY(id) REFERENCES todo(id),
    FOREIGN KEY(referer) REFERENCES todo(id)
);
--
INSERT INTO status (id) VALUES ('TODO');
INSERT INTO status (id) VALUES ('DONE');
--
CREATE VIRTUAL TABLE todo_fts USING fts5(
    id UNINDEXED,
    text,
    status UNINDEXED,
    content='todo',
    content_rowid='id'
)