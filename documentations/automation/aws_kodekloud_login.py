from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import os

# 🔹 KodeKloud AWS Credentials
AWS_CONSOLE_URL = "https://396913702988.signin.aws.amazon.com/console?region=us-east-1"
USERNAME = "kk_labs_user_674471"
PASSWORD = "sq^^sVmh5ese"

# 🔹 Start Selenium WebDriver (Chrome)
options = webdriver.ChromeOptions()
# options.add_argument("--headless")  # Uncomment to run in headless mode
driver = webdriver.Chrome(options=options)

try:
    print("🔄 Opening AWS Console Login Page...")
    driver.get(AWS_CONSOLE_URL)
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.NAME, "username")))

    # 🔹 Enter Username
    print("🔄 Entering Username...")
    username_field = driver.find_element(By.NAME, "username")
    username_field.send_keys(USERNAME)
    username_field.send_keys(Keys.RETURN)

    # 🔹 Wait for Password Field
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.NAME, "password")))

    # 🔹 Enter Password
    print("🔄 Entering Password...")
    password_field = driver.find_element(By.NAME, "password")
    password_field.send_keys(PASSWORD)
    password_field.send_keys(Keys.RETURN)

    # 🔹 Wait for Login to Complete
    WebDriverWait(driver, 15).until(EC.presence_of_element_located((By.TAG_NAME, "body")))
    print("✅ Logged in Successfully!")

    # 🔹 Navigate to Security Credentials Page
    print("🔄 Navigating to Security Credentials Page...")
    driver.get("https://us-east-1.console.aws.amazon.com/iamv2/home#/security_credentials")
    time.sleep(5)

    # 🔹 Click "Continue to Security Credentials" if required
    try:
        continue_button = WebDriverWait(driver, 5).until(
            EC.element_to_be_clickable((By.XPATH, "//button[contains(text(),'Continue to Security Credentials')]"))
        )
        continue_button.click()
        time.sleep(3)
    except Exception:
        print("✅ No additional confirmation needed.")

    # 🔹 Expand "Access Keys" Section
    try:
        expand_button = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//button[contains(text(),'Access keys')]"))
        )
        expand_button.click()
        time.sleep(3)
    except Exception:
        print("⚠️ Could not find 'Access Keys' section button. Trying next step...")

    # 🔹 Locate AWS Temporary Credentials
    print("🔄 Extracting Temporary AWS Credentials...")

    access_key_elem = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, "//td[contains(text(),'AKIA') or contains(text(),'ASIA')]"))
    )
    AWS_ACCESS_KEY = access_key_elem.text

    secret_key_elem = WebDriverWait(driver, 5).until(
        EC.presence_of_element_located((By.XPATH, "//td[contains(text(),'AKIA') or contains(text(),'ASIA')]/following-sibling::td[1]"))
    )
    AWS_SECRET_KEY = secret_key_elem.text

    session_token_elem = WebDriverWait(driver, 5).until(
        EC.presence_of_element_located((By.XPATH, "//td[contains(text(),'AKIA') or contains(text(),'ASIA')]/following-sibling::td[2]"))
    )
    AWS_SESSION_TOKEN = session_token_elem.text

    print("✅ AWS Credentials Extracted!")

    # 🔹 Save Credentials to AWS CLI Profile
    os.system(f'aws configure set aws_access_key_id {AWS_ACCESS_KEY} --profile kodekloud')
    os.system(f'aws configure set aws_secret_access_key {AWS_SECRET_KEY} --profile kodekloud')
    os.system(f'aws configure set aws_session_token {AWS_SESSION_TOKEN} --profile kodekloud')
    os.system(f'aws configure set region us-east-1 --profile kodekloud')

    print("✅ AWS CLI Configured Successfully!")

except Exception as e:
    print("❌ Error:", str(e))

finally:
    driver.quit()
