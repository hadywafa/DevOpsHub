from aws_service import AWSSelenium
from utils import find_latest_csv, extract_keys_from_csv, configure_aws_cli
import os

# 🔹 User Inputs
AWS_ACCOUNT_ID = input("Enter AWS Account ID: ")
AWS_USERNAME = input("Enter AWS Username: ")
AWS_PASSWORD = input("Enter AWS Password: ")
DOWNLOAD_DIR = os.path.join(os.path.expanduser("~"), "Downloads")

# 🔹 Initialize AWS Selenium Service
aws = AWSSelenium(AWS_USERNAME, AWS_PASSWORD, AWS_ACCOUNT_ID, DOWNLOAD_DIR)

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
