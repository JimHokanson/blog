import json
import os
import lxml
import pymysql

def connect():

    #endpoint for connectivity & security
    #pubmed.cluster-c2p9zx6qaitu.us-east-2.rds.amazonaws.com
    conn = pymysql.connect(
      host="pubmed.cluster-c2p9zx6qaitu.us-east-2.rds.amazonaws.com",
      user=os.environ['mysql_user'],
      password=os.environ['mysql_pass'],
      database="mydb",
      port=3306
    )
    
    return conn
    
mydb = connect()

mycursor = mydb.cursor()

running_aws = os.environ.get("AWS_EXECUTION_ENV") is not None

def lambda_handler(event, context):
    
    print(lxml.__version__)
    print(pymysql.__version__)
    
    data = 1
    
    print(running_aws)
    
    return {
        'statusCode': 200,
        'body': json.dumps(data)
    }
