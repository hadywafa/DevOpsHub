import os
import time
import pandas as pd
import subprocess


def find_latest_csv(download_dir):
    """Find the most recent AWS Access Key CSV file."""
    try:
        csv_files = [f for f in os.listdir(download_dir) if f.endswith('.csv')]
        latest_csv = max(csv_files, key=lambda f: os.path.getctime(
            os.path.join(download_dir, f)))
        return os.path.join(download_dir, latest_csv)
    except Exception as e:
        print(f"❌ Error finding CSV file: {e}")
        exit()


def extract_keys_from_csv(csv_file):
    """Extract AWS access keys from the downloaded CSV file."""
    try:
        df = pd.read_csv(csv_file)
        df.columns = df.columns.str.strip()  # Remove any trailing spaces
        aws_access_key = df.loc[0, "Access key ID"]
        aws_secret_key = df.loc[0, "Secret access key"]

        print(f"🔑 Extracted Access Key: {aws_access_key}")
        print(f"🔒 Extracted Secret Key: {aws_secret_key}")
        return aws_access_key, aws_secret_key

    except Exception as e:
        print(f"❌ Error extracting keys from CSV: {e}")
        exit()


def configure_aws_cli(aws_access_key, aws_secret_key):
    """Configure AWS CLI with the extracted access keys."""
    try:
        subprocess.run(f'aws configure set aws_access_key_id {
                       aws_access_key} --profile kodekloud', shell=True, check=True)
        subprocess.run(f'aws configure set aws_secret_access_key {
                       aws_secret_key} --profile kodekloud', shell=True, check=True)
        subprocess.run(
            f'aws configure set region us-east-1 --profile kodekloud', shell=True, check=True)
        print("✅ AWS CLI Configured Successfully!")

    except Exception as e:
        print(f"❌ Error configuring AWS CLI: {e}")
