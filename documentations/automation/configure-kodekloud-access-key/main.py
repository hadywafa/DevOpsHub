import os
import argparse
from src.aws_service import AWSSelenium
from src.utils import find_latest_csv, extract_keys_from_csv, configure_aws_cli

# 🔹 Parse Command-Line Arguments
parser = argparse.ArgumentParser(description="AWS Access Key Automation")
parser.add_argument("--use-existing-file", action="store_true",
                    help="Use an existing AWS credentials CSV file")
parser.add_argument("--file", type=str,
                    help="Full path to the AWS credentials CSV file (required if --use-existing-file is set)")
parser.add_argument("--account-id", type=str,
                    required=True, help="AWS Account ID")
parser.add_argument("--username", type=str, required=True, help="AWS Username")
parser.add_argument("--password", type=str, required=True, help="AWS Password")
args = parser.parse_args()

DOWNLOAD_DIR = os.path.join(os.path.expanduser("~"), "Downloads")

if args.use_existing_file:
    if os.path.exists(args.file):
        print(f"✅ Using existing AWS credentials file: {args.file}")
        aws_access_key, aws_secret_key = extract_keys_from_csv(args.file)
        configure_aws_cli(aws_access_key, aws_secret_key)
        print("✅ AWS CLI Configured Successfully! (Skipping Access Key Creation)")
    else:
        print(f"❌ File not found: {args.file}")
        exit()
else:
    aws = AWSSelenium(args.username, args.password,
                      args.account_id, DOWNLOAD_DIR)
    aws.setup_driver()
    aws.login_to_aws()
    aws.create_access_key()

    csv_file = find_latest_csv(DOWNLOAD_DIR)
    aws_access_key, aws_secret_key = extract_keys_from_csv(csv_file)
    configure_aws_cli(aws_access_key, aws_secret_key)

    aws.quit_driver()
