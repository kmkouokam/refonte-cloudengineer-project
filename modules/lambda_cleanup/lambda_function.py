import json
import boto3
import datetime
import logging
import os
import pymysql
from aws_xray_sdk.core import xray_recorder, patch_all
from aws_xray_sdk.core import patch

# Patch all boto3 and pymysql calls
patch_all()

logger = logging.getLogger()
logger.setLevel(logging.INFO)
cloudwatch = boto3.client('cloudwatch')
sns = boto3.client('sns')

ec2 = boto3.client('ec2')
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']


def put_metric(name, value):
    cloudwatch.put_metric_data(
        Namespace='EC2Cleanup',
        MetricData=[{
            'MetricName': name,
            'Value': value,
            'Unit': 'Count'
        }]
    )


def lambda_handler(event, context):
    deleted_resources = {
        'volumes': [],
        'eips': [],
        'instances': []
    }

    # 1. Unattached (available) EBS volumes
    volumes = ec2.describe_volumes(Filters=[{'Name': 'status', 'Values': ['available']}])['Volumes']
    for vol in volumes:
        vol_id = vol['VolumeId']
        try:
            ec2.delete_volume(VolumeId=vol_id)
            logger.info(f"Deleted unattached EBS volume: {vol_id}")
            deleted_resources['volumes'].append(vol_id)
        except Exception as e:
            logger.error(f"Error deleting volume {vol_id}: {str(e)}")

    # 2. Orphaned Elastic IPs (not associated)
    addresses = ec2.describe_addresses()['Addresses']
    for addr in addresses:
        if 'InstanceId' not in addr and 'AssociationId' not in addr:
            try:
                ec2.release_address(AllocationId=addr['AllocationId'])
                logger.info(f"Released orphaned Elastic IP: {addr['PublicIp']}")
                deleted_resources['eips'].append(addr['PublicIp'])
            except Exception as e:
                logger.error(f"Error releasing Elastic IP {addr['PublicIp']}: {str(e)}")

    # 3. Stopped EC2 instances
    instances = ec2.describe_instances(
        Filters=[{'Name': 'instance-state-name', 'Values': ['stopped']}]
    )

    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            try:
                ec2.terminate_instances(InstanceIds=[instance_id])
                logger.info(f"Terminated stopped EC2 instance: {instance_id}")
                deleted_resources['instances'].append(instance_id)
            except Exception as e:
                logger.error(f"Error terminating instance {instance_id}: {str(e)}")

     # Push metrics to CloudWatch
    put_metric('DeletedVolumes', len(deleted_resources['volumes']))
    put_metric('ReleasedEIPs', len(deleted_resources['eips']))
    put_metric('TerminatedInstances', len(deleted_resources['instances']))

     # Publish to SNS
    message = f"EC2 Cleanup Completed:\nDeleted Volumes: {len(deleted_resources['volumes'])}\nReleased EIPs: {len(deleted_resources['eips'])}\nTerminated Instances: {len(deleted_resources['instances'])}"
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject="AWS EC2 Cleanup Summary",
        Message=message
    )
    logger.info("Cleanup completed and notification sent.")

      # --- MySQL Query with X-Ray Tracing ---
    try:
        xray_recorder.begin_subsegment('MySQLConnection')
        conn = pymysql.connect(
            host=os.environ['DB_HOST'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD'],
            db=os.environ['DB_NAME'],
            connect_timeout=5
        )
        xray_recorder.end_subsegment()

        with conn.cursor() as cursor:
            xray_recorder.begin_subsegment('Query: SELECT NOW()')
            cursor.execute("SELECT NOW()")
            result = cursor.fetchone()
            xray_recorder.end_subsegment()
        
        logger.info(f"MySQL Query Result: {result[0]}")
    except Exception as e:
        logger.error(f"MySQL connection/query failed: {str(e)}")

    
    return {
        'statusCode': 200,
        'body': json.dumps(f"Cleanup done. Volumes: {len(deleted_resources['volumes'])}, EIPs: {len(deleted_resources['eips'])}, Instances: {len(deleted_resources['instances'])}")
    }
