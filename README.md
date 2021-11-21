# nn
Основная логика скрипта описана в main.run, данные необходимые для выполнения скрипта в базе данных Postgres

Поднять контейнер Postgres, создать и заполнить необходимые таблицы:
```
docker-compose -f psql_up.yml up --build
```

### Схема БД
Создается 6 таблиц:
- scripts
- units
- prompts
- entities
- pre_actions
- post_actions

***Таблица scripts:***
  - id - Primary key
  - script - название скрипта (max_length=128)
 
 ***Таблица units:***
  - id - Primary key
  - script_id - Foreign key (scripts)
  - logic_unit - содежимое столбца logic_unit excel-таблицы (max_length=128)
  
 ***Таблица prompts:***
 - id - Primary key
 - unit_id  - Foreign key (units)
 - prompt_name - содержимое столбца prompt_name  excel-таблицы (max_length=64)
 - prompt_text - содержимое стоблца prompt_text  excel-таблицы (max_length=512). 
 >*В случае наличия переменных в тексте они должны быть заключены в фигурные скобки.*
  Например: "{name}, добрый день!"
  - prompt_vars - переменные используемые в тексте через запятую **без пробелов** (max_length=64)
  
 ***Таблица entities:***
 - id - Primary key
 - unit_id  - Foreign key (units)
 - phrase - содержимое стоблца phrase excel-таблицы (max_length=64)
 - repeat_count - количество получения pharase в качесте ответа, соответствующее next_step
 > Например: при получении phrase NULL в первый раз (repeat_count=1) next_step='hello_null', во второй раз (repeat_count=2) next_step='hangup_null'
 - next_step - Foreign key (prompts)
  
 ***Таблица pre_actions:***
 в данной таблице содержатся данные о специфических действиях, которые необходимо выполнить перед запуском проигрывания синтеза
  - id - Primary key
 - prompt_id  - Foreign key (prompts)
 - order_number - порядковый номер выполнения действия
- obj - имя вызываемого объекта, исходя из описания задания, возможны "nn", "nv","nlu", "result"  (max_length=16)
- method - имя вызываемого метода (max_length=16)
- args - значения передаваемых аргументов через запятую **без пробелов** (max_length=64)

 ***Таблица post_actions:***
 в данной таблице содержатся данные о специфических действиях, которые необходимо выполнить после получения ответа от собеседника
  - id - Primary key
 - entity_id  - Foreign key (entities)
 - order_number - порядковый номер выполнения действия
 - obj - имя вызываемого объекта, исходя из описания задания, возможны "nn", "nv","nlu", "result"  (max_length=16)
- method - имя вызываемого метода (max_length=16)
- args - значения передаваемых аргументов через запятую **без пробелов** (max_length=64)
  


