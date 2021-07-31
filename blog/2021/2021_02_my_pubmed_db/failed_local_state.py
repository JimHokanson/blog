import json
import boto3
import os
import zipfile

def lambda_handler(event, context):
    
    #------------------------------------------------
    #1) get updating of the last file
    #2) write the updating code
    #3) read and write to the db layer
    #4) How do deploy????
    
    client = boto3.client('lambda',region_name='us-east-2')
    
    with open('/opt/last_file.txt', 'r') as file:
        data = int(file.read())
        
    file_path = '/tmp/last_file.txt'
    file_path2 = '/tmp/temp.zip'
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
        
    with open(file_path,'w') as file:
        file.write(str(data+1))    
        
    with zipfile.ZipFile(file_path2,'w') as zip: 
        #- write the file to the zip
        #- 2nd input specifies where in the archive to go
        #   otherwise the relative structure is preserved
        zip.write(file_path,'last_file.txt') 
    
    with open(file_path2,'rb') as file:
        bytes = file.read()
        response1 = client.publish_layer_version(
            LayerName='db_status_layer',
            Content={'ZipFile': bytes},
            CompatibleRuntimes=['python3.8'])
    
    response = client.update_function_configuration(
        FunctionName='db_updater',
        Layers=[response1['LayerVersionArn']])

    return {
        'statusCode': 200,
        'body': json.dumps(data)
    }
