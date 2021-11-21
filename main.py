from psycopg2 import connect
from os import getenv
from dotenv import load_dotenv

from db_connector import (
    conn,
    get_prompt_id,
    get_entities,
    get_prompt_text,
    get_next_step,
    get_pre_actions,
    get_post_actions,
)

from utils import execute_actions, set_prompt_text_vars


MEDIA_PARAMS = {
    "lang": "ru_RU",
    "asr": "google",
    "tts": "google",
    "authentication_data": {
        "asr": "google",
        "tts": "google",
    },
}

USING_CLASSES = {
    "nn": nn,
    "nv": nv,
    "nlu": nlu,
    "result": result,
}

load_dotenv()

conn = connect(
    database=getenv("POSTGRES_DB"),
    user=getenv("POSTGRES_USER"),
    password=getenv("POSTGRES_PASSWORD"),
    host=getenv("POSTGRES_HOST"),
    port=getenv("POSTGRES_PORT"),
)


entry_point = "hello"
while entry_point:
    entry_point_id = get_prompt_id(conn, entry_point)
    nn.counter(entry_point, "+")

    entities = get_entities(conn, entry_point_id)

    if nv.has_record(entry_point):
        nv.say(entry_point)
    else:
        nv.media_params(**MEDIA_PARAMS)

        raw_text, text_vars = get_prompt_text(conn, entry_point_id)
        pre_actions = get_pre_actions(conn, entry_point_id)
        text_values = execute_actions(pre_actions, USING_CLASSES)

        text = set_prompt_text_vars(raw_text, text_vars, text_values)
        nv.synthesize(text)
        nv.say(entry_point)

    with nv.listen(entities, stop_condition="OR") as r:
        value = None
        for ent in entities:
            if result.has_entity(ent):
                value = result.entity(ent)
                break
        next_step = get_next_step(conn, entry_point_id, value, nn.counter(entry_point))
        post_actions = get_post_actions(conn, entry_point_id, value)
        execute_actions(post_actions, USING_CLASSES)

        entry_point = next_step

nn.dialog.result = nn.RESULT_DONE
conn.close()
