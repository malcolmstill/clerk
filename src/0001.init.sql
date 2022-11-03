CREATE TABLE todo (
    id INTEGER PRIMARY KEY NOT NULL,
    status TEXT NOT NULL,
    text TEXT NOT NULL,
    FOREIGN KEY(status) REFERENCES status(id)
);
-- 
CREATE TABLE status (
    id TEXT PRIMARY KEY
);
-- 
INSERT INTO status (id) VALUES ('TODO');
INSERT INTO status (id) VALUES ('DONE');