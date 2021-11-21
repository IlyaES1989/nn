-- Create tables
CREATE TABLE IF NOT EXISTS scripts(
    id INT NOT NULL,
    script VARCHAR(128),
    PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS units(
    id INT NOT NULL,
    script_id INT NOT NULL,
    FOREIGN KEY(script_id)
        REFERENCES scripts(id)
        ON DELETE CASCADE,
    logic_unit VARCHAR(128),
    PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS prompts(
    id INT NOT NULL,
    unit_id INT NOT NULL,
    FOREIGN KEY(unit_id)
        REFERENCES units(id)
        ON DELETE CASCADE,
    prompt_name VARCHAR(64) NOT NULL,
    prompt_text VARCHAR(512) NOT NULL,
    prompt_vars VARCHAR(64),
    PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS entities(
    id INT NOT NULL,
    units_id INT NOT NULL,
    FOREIGN KEY(units_id)
        REFERENCES units(id)
        ON DELETE CASCADE,
    phrase VARCHAR(64),
    repeat_count INT,
    next_step INT,
    FOREIGN KEY(next_step)
        REFERENCES prompts(id)
        ON DELETE CASCADE,
    PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS pre_actions(
    id INT NOT NULL,
    prompt_id INT NOT NULL,
    FOREIGN KEY(prompt_id)
        REFERENCES prompts(id)
        ON DELETE CASCADE,
    order_number INT NOT NULL,
    obj VARCHAR(16),
    method VARCHAR(16),
    args VARCHAR(64),
    PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS post_actions(
    id INT NOT NULL,
    entity_id INT NOT NULL,
    FOREIGN KEY(entity_id)
        REFERENCES entities(id)
        ON DELETE CASCADE,
    order_number INT NOT NULL,
    obj VARCHAR(16),
    method VARCHAR(16),
    args VARCHAR(64),
    PRIMARY KEY(id)
);

-- Fill tables

INSERT INTO scripts (id, script)
VALUES (1, 'test script')
RETURNING *;

INSERT INTO units(id, script_id, logic_unit)
VALUES
    (1,1, 'hello_logic'),
    (2,1,'main_logic'),
    (3,1,'hangup_logic'),
    (4,1,'forward_logic')
RETURNING *;

INSERT INTO prompts (id, unit_id, prompt_name, prompt_text, prompt_vars)
VALUES
    (1,1,'hello', '{name}, добрый день! Вас беспокоит компания X, мы проводим опрос удовлетворенности нашими услугами.  Подскажите, вам удобно сейчас говорить?', 'name'),
    (2,1,'hello_repeat', 'Это компания X  Подскажите, вам удобно сейчас говорить?',NULL),
    (3,1, 'hello_null', 'Извините, вас не слышно. Вы могли бы повторить',NULL),
    (4,2, 'recommend_main', 'Скажите, а готовы ли вы рекомендовать нашу компанию своим друзьям? Оцените, пожалуйста, по шкале от «0» до «10», где «0» - не буду рекомендовать, «10» - обязательно порекомендую.',NULL),
    (5,2,'recommend_repeat', 'Как бы вы оценили возможность порекомендовать нашу компанию своим знакомым по шкале от 0 до 10, где 0 - точно не порекомендую, 10 - обязательно порекомендую.',NULL),
    (6,2,'recommend_repeat_2', 'Ну если бы вас попросили порекомендовать нашу компанию друзьям или знакомым, вы бы стали это делать? Если «да» - то оценка «10», если точно нет – «0».',NULL),
    (7,2,'recommend_score_negative', 'Ну а от 0 до 10 как бы вы оценили бы: 0, 5 или может 7 ?',NULL),
    (8,2, 'recommend_score_neutral', 'Ну а от 0 до 10 как бы вы оценили ?',NULL),
    (9,2, 'recommend_score_positive', 'Хорошо,  а по 10-ти бальной шкале как бы вы оценили 8-9 или может 10  ?',NULL),
    (10,2, 'recommend_null','Извините вас совсем не слышно,  повторите пожалуйста ?',NULL),
    (11,2,'recommend_default', 'повторите пожалуйста ',NULL),
    (12,3,'hangup_positive', 'Отлично!  Большое спасибо за уделенное время! Всего вам доброго!',NULL),
    (13,3,'hangup_negative', 'Я вас понял. В любом случае большое спасибо за уделенное время!  Всего вам доброго. ',NULL),
    (14,3,'hangup_wrong_time', 'Извините пожалуйста за беспокойство. Всего вам доброго',NULL),
    (15,3,'hangup_null', 'Вас все равно не слышно, будет лучше если я перезвоню. Всего вам доброго',NULL),
    (16,4,'forward', 'Чтобы разобраться в вашем вопросе, я переключу звонок на моих коллег. Пожалуйста оставайтесь на линии.',NULL)
RETURNING *;

INSERT INTO entities (id, units_id, phrase, repeat_count, next_step)
VALUES
    (1,1,NULL, 1, 3),
    (2,1,NULL,2,15),
    (3,1,'DEFAULT', 1, 4),
    (4,1,'Да',1,4),
    (5,1, 'Нет', 1, 14),
    (6,1, 'Занят',1,2),
    (7,2,NULL,1,10),
    (8,2,NULL,2,15),
    (9,2, 'DEFAULT', 1, 11),
    (10,2,'DEFAULT',2,15),
    (11,2,'0,1,2,3,4,5,6,7,8',1,13),
    (12,2,'9,10',1,12),
    (13,2,'Нет', 1, 7),
    (14,2,'Возможно', 1,8),
    (15,2, 'Да', 1, 9 ),
    (16,2, 'Еще раз',1,5),
    (17,2, 'Не знаю', 1, 6),
    (18,2,'Занят',1, 14),
    (19,2,'Вопрос',1,16),
    (20,3,NULL,NULL,NULL),
    (21,3,NULL,NULL,NULL),
    (22,3,NULL,NULL,NULL),
    (23,3,NULL,NULL,NULL),
    (24,4,NULL,NULL,NULL)
RETURNING *;

INSERT INTO pre_actions (id, prompt_id, order_number, obj, method, args)
VALUES
    (1,1,1,'nn', 'dialog.name',NULL)
RETURNING *;

INSERT INTO post_actions (id,entity_id, order_number, obj, method, args)
VALUES
    (1,4,1, 'nn', 'env', 'confirm,True'),
    (2,5,1, 'nn', 'env', 'confirm,False' ),
    (3,6,1, 'nn', 'env', 'repeat,True'),
    (4,11,1, 'nn', 'env','recommendation_score,PHRASE'),
    (5,12,1, 'nn', 'env','recommendation_score,PHRASE'),
    (6,13,1, 'nn', 'env','recommendation,negative'),
    (7,14,1, 'nn', 'env','recommendation,neutral'),
    (8,15,1, 'nn', 'env','recommendation,positive'),
    (9,16,1, 'nn', 'env','repeat,True'),
    (10,17,1, 'nn', 'env', 'recommendation,dont_know'),
    (11,18,1, 'nn', 'env', 'wrong_time,True'),
    (12,19,1, 'nn', 'env', 'question,True'),
    (13,20,1, 'nn', 'env', 'tag,высокая оценка'),
    (14,21,1, 'nn', 'env', 'tag,низкая оценка'),
    (15,22,1, 'nn', 'env', 'tag,нет времени для разговора'),
    (16,23,1, 'nn', 'env', 'tag,проблемы с распознаванием'),
    (17,24,1, 'nn', 'env', 'tag,перевод на оператора'),
    (18,24,2, 'nn','forward',NULL)
RETURNING *;
