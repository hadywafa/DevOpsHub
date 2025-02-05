from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import os

# 🔹 AWS Credentials (Replace with your actual details)
AWS_CONSOLE_URL = "https://hadywafa.signin.aws.amazon.com/console?region=us-east-1"
USERNAME = "hady"
PASSWORD = "hH@HadyWafa"

# 🔹 Start Selenium WebDriver (Chrome)
options = webdriver.ChromeOptions()
# options.add_argument("--headless")  # Uncomment to run in headless mode
driver = webdriver.Chrome(options)

driver.maximize_window()


try:
    print("🔄 Opening AWS Console Login Page...")
    driver.get(AWS_CONSOLE_URL)

    # Wait for the login page
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.NAME, "username")))

    # 🔹 Enter Username
    print("🔄 Entering Username...")
    username_field = driver.find_element(By.NAME, "username")
    username_field.send_keys(USERNAME)
    username_field.send_keys(Keys.RETURN)

    # 🔹 Wait for Password Field
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.NAME, "password")))

    # 🔹 Enter Password
    print("🔄 Entering Password...")
    password_field = driver.find_element(By.NAME, "password")
    password_field.send_keys(PASSWORD)
    password_field.send_keys(Keys.RETURN)

    # 🔹 Wait for Login to Complete & Ensure AWS Console is Loaded
    time.sleep(5)

    print("🔄 Confirming Successful Login...")
    driver.get(
        "https://us-east-1.console.aws.amazon.com/iamv2/home?#/security_credentials")
    WebDriverWait(driver, 15).until(
        EC.presence_of_element_located((By.TAG_NAME, "body")))
    print("✅ Successfully Navigated to IAM Security Credentials Page!")

    # 🔹 Ensure the "Access Keys" Section is Fully Rendered
    print("🔄 Waiting for 'Access Keys' Section to Fully Load...")
    access_keys_section = WebDriverWait(driver, 15).until(
        EC.presence_of_element_located(
            (By.XPATH, "//div[@data-testid='msc-user-access-keys']"))
    )
    driver.execute_script(
        "arguments[0].scrollIntoView();", access_keys_section)
    time.sleep(3)  # Wait for animations

    # 🔹 Click "Create Access Key" Button
    print("🔄 Clicking 'Create Access Key' Button...")
    create_access_key_button = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable(
            (By.XPATH, "//button[@data-cy='create-access-keys']"))
    )
    time.sleep(1)
    create_access_key_button.click()
    time.sleep(3)
    print("✅ 'Create Access Key' Button Clicked Successfully!")

    print("🔄 Selecting 'Command Line Interface (CLI)' as Use Case...")

    wait = WebDriverWait(driver, 10)
    cli_label = wait.until(EC.element_to_be_clickable(
        (By.XPATH, "//span[contains(text(),'Command Line Interface (CLI)')]")))

    time.sleep(3)
    cli_label.click()

    print("Radio button selected successfully")
# ---------------------------------------------------------------------------
    # 🔹 Click "I Understand" Checkbox
    print("🔄 Checking 'I understand' confirmation checkbox...")
    confirm_label = wait.until(EC.element_to_be_clickable(
        (By.XPATH, "//span[contains(text(),'I understand the above recommendation and want to proceed to create an access key.')]")))

    driver.execute_script(
        "arguments[0].scrollIntoView();", confirm_label)

    time.sleep(3)
    confirm_label.click()

    print("✅ Confirmation Checkbox Checked Successfully!")
# ---------------------------------------------------------------------------
    # 🔹 Click "Next" Button
    print("🔄 Clicking 'Next' Button...")
    next_button = WebDriverWait(driver, 10).until(
        EC.visibility_of_element_located(
            (By.XPATH, "//button[contains(@class, 'awsui_primary-button')]"))

    )

    time.sleep(3)
    next_button.click()

    print("✅ 'Next' Button Clicked Successfully!")
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
    # 🔹 Click "Create Access Key" Button
    print("🔄 Clicking 'Next' Button...")
    create_button = WebDriverWait(driver, 10).until(
        EC.visibility_of_element_located(
            (By.XPATH, "//button[contains(@class, 'awsui_primary-button')]"))

    )

    time.sleep(3)
    create_button.click()

    print("✅ 'Next' Button Clicked Successfully!")

except Exception as e:
    print("❌ Error:", str(e))
    driver.quit()
    exit()


print("✅ AWS CLI Configured Successfully!")

# ---------------------------------------------------------------------------
# Download cv file

# Configure the download directory (Desktop)
DOWNLOAD_DIR = os.path.join(os.path.expanduser("~"), "Desktop")

# Setup Chrome options to auto-download files
chrome_options = webdriver.ChromeOptions()
prefs = {"download.default_directory": DOWNLOAD_DIR}
chrome_options.add_experimental_option("prefs", prefs)

try:
    # Click the "Download .csv file" button
    download_button = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable(
            (By.XPATH, "//button[contains(span/text(), 'Download .csv file')]"))
    )
    download_button.click()
    print("✅ CSV file download initiated!")

    # Wait for the file to be fully downloaded
    time.sleep(5)  # Adjust if necessary

    # Find the latest downloaded CSV file
    files = [f for f in os.listdir(DOWNLOAD_DIR) if f.startswith(
        "AccessKeys") and f.endswith(".csv")]
    if not files:
        print("❌ No AWS Access Key CSV file found.")
        driver.quit()
        exit()

    # Sort by modification time (most recent file first)
    files.sort(key=lambda x: os.path.getmtime(
        os.path.join(DOWNLOAD_DIR, x)), reverse=True)
    csv_file_path = os.path.join(DOWNLOAD_DIR, files[0])
    print(f"✅ Found AWS Access Key CSV: {csv_file_path}")

    # Read the CSV file
    df = pd.read_csv(csv_file_path)
    AWS_ACCESS_KEY = df.iloc[0]["Access Key Id"]
    AWS_SECRET_KEY = df.iloc[0]["Secret Access Key"]

    print(f"🔑 Extracted Access Key: {AWS_ACCESS_KEY}")
    print(f"🔒 Extracted Secret Key: {AWS_SECRET_KEY}")

    # Configure AWS CLI
    subprocess.run(f'aws configure set aws_access_key_id {
                   AWS_ACCESS_KEY} --profile kodekloud', shell=True, check=True)
    subprocess.run(f'aws configure set aws_secret_access_key {
                   AWS_SECRET_KEY} --profile kodekloud', shell=True, check=True)
    subprocess.run(
        f'aws configure set region us-east-1 --profile kodekloud', shell=True, check=True)

    print("✅ AWS CLI Configured Successfully!")

except Exception as e:
    print("❌ Error:", str(e))

finally:
    driver.quit()
