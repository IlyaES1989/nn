CREATE TABLE IF NOT EXISTS scripts(
    id INT GENERATED ALWAYS AS IDENTITY,
    script VARCHAR(128),
    PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS units(
    id INT GENERATED ALWAYS AS IDENTITY,
    script_id INT NOT null,
    FOREIGN KEY(script_id)
        REFERENCES scripts(id)
        ON DELETE CASCADE,
    logic_unit VARCHAR(128),
    PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS prompts(
    id INT GENERATED ALWAYS AS IDENTITY,
    unit_id INT not null,
    FOREIGN KEY(unit_id)
        REFERENCES units(id)
        ON DELETE CASCADE,
    prompt_name VARCHAR(64) NOT NULL,
    prompt_text VARCHAR(512) NOT NULL,
    phrase VARCHAR(64),
    go_to_action_id INT,
    FOREIGN KEY(go_to_action_id)
        REFERENCES units(id)
        ON DELETE CASCADE,
    entity VARCHAR(256),
    tag VARCHAR(256),
    PRIMARY KEY(id)
);