import boto3
import datetime
import os
import re
import json
import string


def lambda_handler(event, context):
    client = boto3.client('rds')
    db_instance_name = os.environ['DBInstanceIdentifier']
    db_snapshot_name = "%s-%s" % (db_instance_name,datetime.datetime.now().strftime("%Y-%m-%d-%H-%M"))
    delete_snapshot_older_than = os.environ['Days']

    db_describe = client.describe_db_instances(DBInstanceIdentifier=db_instance_name)
    db_status = db_describe['DBInstances'][0]['DBInstanceStatus'] 

    print("Alert received from SNS")
    message = event['Records'][0]['Sns']['Message']
    data = json.loads(message)
 
    f = "Finished DB Instance backup"
    if f in data['Event Message']:
        print ("event message exists")
        snapcount = client.describe_db_snapshots(DBInstanceIdentifier=db_instance_name, MaxRecords=100)['DBSnapshots']
        if len (snapcount) > 0: 
            delc = 0
            for snapshot in client.describe_db_snapshots(DBInstanceIdentifier=db_instance_name, MaxRecords=100)['DBSnapshots']:
                if 'SnapshotCreateTime' in snapshot:
                    create_ts = snapshot['SnapshotCreateTime'].replace(tzinfo=None)
                    if create_ts < datetime.datetime.now() - datetime.timedelta(days=int(delete_snapshot_older_than)):
                        print "Deleting snapshot id:%s" % snapshot['DBSnapshotIdentifier']
                        try:
                            response=client.delete_db_snapshot(DBSnapshotIdentifier=snapshot['DBSnapshotIdentifier'])
                            print (response)
                            delc = delc+1
                        except Exception as e:
                             print (e)
            if delc == 0:
                print ("no shapshots ready for deletion")
        else:
            print ("no snapshots found")
    else:
        print ("ignoring notification")