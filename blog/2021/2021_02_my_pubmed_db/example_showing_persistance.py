import json
import os
import lxml
import pymysql


print(lxml.__version__)
print(pymysql.__version__)

a = 0
    
def lambda_handler(event, context):
    global a
    a = a + 1
    
    print("a is %d"%a)
    
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps("1")
    }

