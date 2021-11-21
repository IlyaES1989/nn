import functools


def rgetattr(obj, attrs, default=None):
    try:
        return functools.reduce(getattr, attrs.split("."), obj)
    except AttributeError:
        return default


def execute_actions(actions_list, using_classes: dict):
    results = []
    for action in actions_list:
        obj = using_classes.get(action["obj"])
        method = action["method"]
        args = action["args"]
        if obj:
            if args:
                args = args.split(",")
                results.append(rgetattr(obj, method)(*args))
            else:
                results.append(rgetattr(obj, method))
        return results


def set_prompt_text_vars(
    text,
    variables,
    values,
):
    kwargs = {var: val for val, var in zip(variables, values)}
    return text.format(**kwargs)
