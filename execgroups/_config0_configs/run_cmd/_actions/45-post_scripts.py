def default():
    
    task = {}
    env_vars = []
    shelloutconfigs = []
    shelloutconfigs.append('config0-publish:::config0_core::post_scripts')

    task['method'] = 'shelloutconfig'
    task['metadata'] = {'env_vars': env_vars,
                        'shelloutconfigs': shelloutconfigs
                        }

    return task
