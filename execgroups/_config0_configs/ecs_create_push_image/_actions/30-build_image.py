def default():

    task = {'method': 'shelloutconfig',
            'metadata': {'env_vars': ["config0-publish:::docker::build"],
                         'shelloutconfigs': ['config0-publish:::docker::ecs_build_push_image']}}

    return task
