#!/usr/bin/env python

"""Connect to Cloud instances"""

import os
import sys
import argparse
import boto3

# Initiate the parser
parser = argparse.ArgumentParser("Type the name of the connection you want")
parser.add_argument('profile', metavar='P', nargs='?',
                    help='an account to use')
parser.add_argument('environment', metavar='E', nargs='?',
                    help='an environment to specify')
args = parser.parse_args()

# Get AWS credentials profile
profile_map = {
    'gs' : {
        'profile': 'ghoststory',
        'prod': 'id_rsa_gstory_prod.pem',
        'dev': 'id_rsa_gstory_prod.pem',
        'username': 'centos',
    },
    'di' : {
        'profile': 't2indies',
        'prod': 'disintegration-prod.pem',
        'dev': 'disintegration-dev.pem',
        'username': 'centos',
    },
    'pd' : {
        'profile': 't2indies',
        'prod': 't2indies-prod.pem',
        'dev': 't2indies-dev.pem',
        'username': 'centos',
    },
    'corp' : {
        'profile': 't2corp',
        'prod': 'take2games-corp.pem',
        'dev': 'take2games-corp.pem',
        'username': 'ec2-user',
    },
    'ksp' : {
        'profile': 'kerbal',
        'prod': 'kerbal_prod_key.pem',
        'dev': 'kerbal_dev_key.pem',
        'username': 'centos',
    },
}
profile_dict = profile_map.get(args.profile)
profile = profile_dict['profile']

# Connect to AWS
session = boto3.Session(profile_name=profile)
client = session.client('ec2', verify=False)

response = client.describe_instances()

print(len(response['Reservations']), "total instances\n")

matched_instances = []
for instance_wrapper in response['Reservations']:
    instance = instance_wrapper['Instances'][0]
    is_matched_env = False
    is_matched_role = False
    for tag in instance.get('Tags', []):
        if tag['Key'] == "site_env" and args.environment in tag['Value']:
            is_matched_env = True
        if tag['Key'] == "role" and tag['Value'] == 'host':
            is_matched_role = True
        if tag['Key'] == "Name":
            instance['Name'] = tag['Value']
    if is_matched_env and is_matched_role:
        matched_instances.append(instance)

for instance in matched_instances:
    print(instance['Name'])
    print(instance['PublicIpAddress'])
    print("")

with open("aws_connect", 'w') as outfile:
    outfile.write("ssh-keyscan {} >> ~/.ssh/known_hosts\n".format(matched_instances[0]['PublicIpAddress']))
    outfile.write("ssh -i ~/.ssh/{} {}@{}".format(profile_dict[args.environment], profile_dict['username'], matched_instances[0]['PublicIpAddress']))
os.chmod("aws_connect", 0o755)
