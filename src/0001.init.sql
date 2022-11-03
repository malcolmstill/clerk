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
);
--
CREATE TRIGGER todo_after_insert AFTER INSERT ON todo
BEGIN
    INSERT INTO todo_fts (rowid, text, status) VALUES (new.id, new.text, new.status);
END;
--
CREATE TRIGGER todo_after_delete AFTER DELETE ON todo
BEGIN
    INSERT INTO todo_fts (todo_fts, rowid, text, status) VALUES ('delete', old.id, old.text, old.status);
END;
--
CREATE TRIGGER todo_after_update AFTER UPDATE ON todo
BEGIN
    INSERT INTO todo_fts (todo_fts, rowid, text, status) VALUES ('delete', old.id, old.text, old.status);
    INSERT INTO todo_fts (rowid, text, status) VALUES (new.id, new.text, new.status);
END;