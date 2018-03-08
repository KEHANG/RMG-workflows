
import os
import pymongo
import ConfigParser

def connect_to_db(database):

    host, port, username, password, db_name = get_authentication_info(database)
       
    remote_address = 'mongodb://{0}:{1}@{2}/admin'.format(username, 
                                                          password,
                                                          host)
    client = pymongo.MongoClient(remote_address, 
                                 port, 
                                 serverSelectionTimeoutMS=2000)
    try:
        client.server_info()
        print("\nConnection success to {0}!\n".format(database))
        return getattr(client, db_name)
    
    except (pymongo.errors.ServerSelectionTimeoutError,
            pymongo.errors.OperationFailure):
        raise Exception("\nConnection failure to {0}...\n".format(database))

def get_authentication_info(database):

    try:
        config = read_config()
        host = config[database]['HOST']
        port = int(config[database]['PORT'])
        username = config[database]['USER']
        password = config[database]['PW']
        db_name = config[database]['DB_NAME']

        return host, port, username, password, db_name
    except KeyError:
        print('Database Authentication Environment Variables Not Completely Set!')
    
    return 'None', 0, 'None', 'None'

def read_config(cfg_path='default'):

    config_parser = ConfigParser.SafeConfigParser()
    config_parser.optionxform = str

    if cfg_path == 'default':
        cfg_path = os.path.join(os.path.dirname(__file__), 'config.cfg')
    with open(cfg_path, 'r') as fid:
        config_parser.readfp(fid)
    return config_parser._sections