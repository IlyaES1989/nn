from psycopg2 import extras


def fetchall_data(connector, query: str):
    with connector:
        with connector.cursor(cursor_factory=extras.DictCursor) as curs:
            curs.execute(query)
            result = curs.fetchall()
    return result


def fetch_data(connector, query: str):
    with connector:
        with connector.cursor(cursor_factory=extras.DictCursor) as curs:
            curs.execute(query)
            result = curs.fetchone()
    return result


def parse_queryset(response):
    result = []
    for res in response:
        if res[0]:
            result += res[0].split(",")
    return result


def get_prompt_id(connector, prompt_name):
    query = """
    SELECT id FROM prompts
    WHERE prompts.prompt_name='{prompt_name}'
    """.format(
        prompt_name=prompt_name
    )
    return int(fetch_data(connector, query)[0])


def get_entities(connector, prompt_id):
    query = """
        SELECT DISTINCT phrase FROM entities
        INNER JOIN prompts ON prompts.unit_id = entities.units_id
        WHERE prompts.id={prompt_id}
        """.format(
        prompt_id=prompt_id
    )

    raw_result = fetchall_data(connector, query)
    return parse_queryset(raw_result)


def get_prompt_text(connector, prompt_id):
    query = """
    SELECT prompt_text, prompt_vars FROM prompts
    WHERE id = {prompt_id}
    """.format(
        prompt_id=prompt_id
    )
    return fetch_data(connector, query)[0]


def get_next_step(
    connector,
    prompt_id,
    entity,
    repeated,
):
    query = """
        SELECT prompt_name FROM prompts
        WHERE id=
        (SELECT next_step FROM entities
        INNER JOIN units ON units.id = entities.units_id
        INNER JOIN prompts ON prompts.unit_id = units.id
        WHERE phrase='{entity}'
        AND prompts.id={prompt_id}
        AND repeat_count={repeated})
        """.format(
        entity=entity, prompt_id=prompt_id, repeated=repeated
    )

    return fetch_data(connector, query)[0]


def get_pre_actions(connector, prompt_id):
    query = """
        SELECT obj, method, args FROM pre_actions
        WHERE prompt_id={prompt_id}
        ORDER BY order_number
        """.format(
        prompt_id=prompt_id
    )

    return fetchall_data(connector, query)


def get_post_actions(connector, prompt_id, entity):
    query = """
        SELECT obj, method, args FROM post_actions
        INNER JOIN entities ON entities.id = entity_id
        INNER JOIN prompts ON prompts.unit_id = entities.units_id
        WHERE phrase = '{entity}'
        AND prompts.id={prompt_id}
        ORDER BY order_number
        """.format(
        entity=entity, prompt_id=prompt_id
    )

    return fetchall_data(connector, query)
