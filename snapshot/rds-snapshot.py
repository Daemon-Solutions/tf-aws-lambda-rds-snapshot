import boto3
import datetime
import os
import json

def lambda_handler(event, context):
    client = boto3.client('rds')
    db_instance_name = os.environ['DBInstanceIdentifier']
    db_snapshot_name = "%s-%s" % (db_instance_name,datetime.datetime.now().strftime("%Y-%m-%d-%H-%M"))

    db_describe = client.describe_db_instances(DBInstanceIdentifier=db_instance_name)
    db_status = db_describe['DBInstances'][0]['DBInstanceStatus']
    
    if db_status == 'available':
        print("RDS snapshot backups started at %s...\n" % datetime.datetime.now())
        client.create_db_snapshot(
        DBInstanceIdentifier=db_instance_name,
        DBSnapshotIdentifier=db_snapshot_name
        )
    else:
        print("db status is", db_status)