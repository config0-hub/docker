def default():

    task = {'method': 'shelloutconfig',
            'metadata': {'env_vars': ["config0-publish:::docker::build"],
                         'shelloutconfigs': ['config0-publish:::docker::run_dockerfile']}}

    return task
