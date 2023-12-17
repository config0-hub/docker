def default():
    
    task = {}
    env_vars = []
    shelloutconfigs = []

    env_vars.append("config0-publish:::docker::build")
    shelloutconfigs.append('config0-publish:::docker::simple_build')

    task['method'] = 'shelloutconfig'
    task['metadata'] = {'env_vars': env_vars, 
                        'shelloutconfigs': shelloutconfigs 
                        }

    return task
