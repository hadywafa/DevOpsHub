import os
import argparse
import sys
from src.aws_service import AWSSelenium
from src.utils import configure_aws_cli, extract_keys_from_csv, find_latest_csv


# 🔹 Parse Command-Line Arguments
parser = argparse.ArgumentParser(description="AWS Access Key Automation")
parser.add_argument("--use-existing-file", action="store_true", help="Use an existing AWS credentials CSV file")
parser.add_argument("--file", type=str, help="Full path to the AWS credentials CSV file (required if --use-existing-file is set)")
parser.add_argument("--account-id", type=str, required=True, help="AWS Account ID")
parser.add_argument("--username", type=str, required=True, help="AWS Username")
parser.add_argument("--password", type=str, required=True, help="AWS Password")

print("Received Arguments:", sys.argv)

args = parser.parse_args()

# 🔹 Check for conflicting parameters
if args.use_existing_file and not args.file:
    print("❌ Error: --file is required when using --use-existing-file flag.")
    exit()

DOWNLOAD_DIR = os.path.join(os.path.expanduser("~"), "Downloads")

# 🔹 If using an existing file, configure AWS CLI directly
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
    # 🔹 Initialize AWS Selenium Service
    aws = AWSSelenium(args.username, args.password, args.account_id, DOWNLOAD_DIR)

    # 🔹 Run Steps
    aws.setup_driver()
    aws.login_to_aws()
    aws.create_access_key()

    # 🔹 Process CSV File
    csv_file = find_latest_csv(DOWNLOAD_DIR)
    aws_access_key, aws_secret_key = extract_keys_from_csv(csv_file)

    # 🔹 Configure AWS CLI
    configure_aws_cli(aws_access_key, aws_secret_key)

    # 🔹 Quit Selenium
    aws.quit_driver()
