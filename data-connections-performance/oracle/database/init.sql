CREATE TABLE stuff(
    id NUMBER,    
    description VARCHAR2(50) NOT NULL,
    PRIMARY KEY(id)
);

INSERT INTO stuff
    VALUES (1, 'SomeItem');