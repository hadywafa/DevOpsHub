from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time


class AWSSelenium:
    def __init__(self, username, password, account_id, download_dir):
        self.username = username
        self.password = password
        self.account_id = account_id
        self.download_dir = download_dir
        self.driver = None

    def setup_driver(self):
        """Initialize Selenium WebDriver."""
        options = webdriver.ChromeOptions()
        prefs = {"download.default_directory": self.download_dir}
        options.add_experimental_option("prefs", prefs)
        self.driver = webdriver.Chrome(options=options)
        self.driver.maximize_window()

    def login_to_aws(self):
        """Log in to AWS Console."""
        try:
            aws_console_url = f"https://{self.account_id}.signin.aws.amazon.com/console?region=us-east-1"
            print("🔄 Opening AWS Console Login Page...")
            self.driver.get(aws_console_url)

            WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.NAME, "username"))).send_keys(self.username, Keys.RETURN)
            WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.NAME, "password"))).send_keys(self.password, Keys.RETURN)

            time.sleep(5)
            print("✅ Successfully Logged into AWS Console!")

        except Exception as e:
            print(f"❌ Error during login: {e}")
            self.quit_driver()

    def create_access_key(self):
        """Navigate to IAM and create an access key with scrolling and delay handling."""
        try:
            print("🔄 Navigating to IAM Security Credentials Page...")
            self.driver.get(
                "https://us-east-1.console.aws.amazon.com/iamv2/home?#/security_credentials")

            WebDriverWait(self.driver, 15).until(
                EC.presence_of_element_located((By.TAG_NAME, "body")))

            # Scroll to the 'Create Access Key' button and wait
            create_access_key_button = WebDriverWait(self.driver, 10).until(
                EC.presence_of_element_located(
                    (By.XPATH, "//button[@data-cy='create-access-keys']"))
            )
            self.driver.execute_script(
                "arguments[0].scrollIntoView(true);", create_access_key_button)
            time.sleep(5)  # Allow UI animations to complete
            WebDriverWait(self.driver, 10).until(EC.element_to_be_clickable(
                (By.XPATH, "//button[@data-cy='create-access-keys']"))).click()
            print("✅ 'Create Access Key' Button Clicked Successfully!")

            # Select 'CLI' as the Use Case
            cli_label = WebDriverWait(self.driver, 10).until(
                EC.element_to_be_clickable(
                    (By.XPATH, "//span[contains(text(),'Command Line Interface (CLI)')]"))
            )
            self.driver.execute_script(
                "arguments[0].scrollIntoView(true);", cli_label)
            time.sleep(2)
            cli_label.click()
            print("✅ CLI selected successfully!")

            # Check 'I Understand' confirmation checkbox
            confirm_label = WebDriverWait(self.driver, 10).until(
                EC.element_to_be_clickable(
                    (By.XPATH, "//span[contains(text(),'I understand the above recommendation and want to proceed to create an access key.')]")
                )
            )
            self.driver.execute_script(
                "arguments[0].scrollIntoView(true);", confirm_label)
            time.sleep(2)
            confirm_label.click()
            print("✅ Confirmation Checkbox Checked Successfully!")

            # Click 'Next' Button
            next_button = WebDriverWait(self.driver, 10).until(
                EC.element_to_be_clickable(
                    (By.XPATH, "//button[contains(@class, 'awsui_primary-button')]"))
            )
            self.driver.execute_script(
                "arguments[0].scrollIntoView(true);", next_button)
            time.sleep(2)
            next_button.click()
            print("✅ 'Next' Button Clicked Successfully!")

            # Click 'Create Access Key' Button
            create_button = WebDriverWait(self.driver, 10).until(
                EC.element_to_be_clickable(
                    (By.XPATH, "//button[contains(@class, 'awsui_primary-button')]"))
            )
            self.driver.execute_script(
                "arguments[0].scrollIntoView(true);", create_button)
            time.sleep(2)
            create_button.click()
            print("✅ Access Key Created Successfully!")

            # Scroll and Download CSV
            download_button = WebDriverWait(self.driver, 10).until(
                EC.element_to_be_clickable(
                    (By.XPATH, "//button[contains(span/text(), 'Download .csv file')]"))
            )
            self.driver.execute_script(
                "arguments[0].scrollIntoView(true);", download_button)
            time.sleep(5)
            download_button.click()

            time.sleep(10)  # Wait for download
            print("✅ CSV file downloaded successfully!")

        except Exception as e:
            print(f"❌ Error creating access key: {e}")
            self.quit_driver()

    def quit_driver(self):
        """Quit the Selenium WebDriver."""
        if self.driver:
            self.driver.quit()
