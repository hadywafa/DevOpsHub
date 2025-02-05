from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import os

# 🔹 AWS Credentials (Replace with your actual details)
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

    # Wait for the login page
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

    # 🔹 Wait for Login to Complete & Ensure AWS Console is Loaded
    time.sleep(5)

    print("🔄 Confirming Successful Login...")
    driver.get("https://us-east-1.console.aws.amazon.com/iamv2/home?#/security_credentials")
    WebDriverWait(driver, 15).until(EC.presence_of_element_located((By.TAG_NAME, "body")))
    print("✅ Successfully Navigated to IAM Security Credentials Page!")

    # 🔹 Ensure the "Access Keys" Section is Fully Rendered
    print("🔄 Waiting for 'Access Keys' Section to Fully Load...")
    access_keys_section = WebDriverWait(driver, 15).until(
        EC.presence_of_element_located((By.XPATH, "//div[@data-testid='msc-user-access-keys']"))
    )
    driver.execute_script("arguments[0].scrollIntoView();", access_keys_section)
    time.sleep(3)  # Wait for animations

    # 🔹 Click "Create Access Key" Button
    try:
        print("🔄 Clicking 'Create Access Key' Button...")
        create_access_key_button = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//button[@data-cy='create-access-keys']"))
        )
        driver.execute_script("arguments[0].scrollIntoView();", create_access_key_button)
        time.sleep(1)
        create_access_key_button.click()
        time.sleep(3)
        print("✅ 'Create Access Key' Button Clicked Successfully!")
    except:
        print("❌ Error: Could not find the 'Create Access Key' button.")
        driver.quit()
        exit()

    # 🔹 Select "Command Line Interface (CLI)" Use Case
    print("🔄 Selecting CLI as Use Case...")
    cli_use_case = WebDriverWait(driver, 5).until(
        EC.element_to_be_clickable((By.XPATH, "//input[@value='CLI']/ancestor::div[contains(@class,'awsui_tile-container')]"))
    )
    cli_use_case.click()
    time.sleep(2)

    # Click "Next" Button
    next_button = WebDriverWait(driver, 5).until(
        EC.element_to_be_clickable((By.XPATH, "//button[contains(text(),'Next')]"))
    )
    next_button.click()
    time.sleep(3)

    # Check the "I understand" confirmation checkbox
    print("🔄 Accepting confirmation checkbox...")
    confirm_checkbox = WebDriverWait(driver, 5).until(
        EC.element_to_be_clickable((By.XPATH, "//input[@type='checkbox']"))
    )
    confirm_checkbox.click()
    time.sleep(2)

    # Click "Create access key" Button
    create_access_key_button = WebDriverWait(driver, 5).until(
        EC.element_to_be_clickable((By.XPATH, "//button[contains(text(),'Create access key')]"))
    )
    create_access_key_button.click()
    time.sleep(5)

    # Extract the newly created Access Key & Secret Key
    print("🔄 Extracting new Access Key & Secret Key...")
    AWS_ACCESS_KEY = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, "//span[contains(text(),'AKIA')]"))
    ).text

    AWS_SECRET_KEY = WebDriverWait(driver, 5).until(
        EC.presence_of_element_located((By.XPATH, "//span[contains(text(),'Secret access key')]/following-sibling::span"))
    ).text

    print(f"✅ New Access Key Created: {AWS_ACCESS_KEY}")

    # 🔹 Save Credentials to AWS CLI Profile
    os.system(f'aws configure set aws_access_key_id {AWS_ACCESS_KEY} --profile kodekloud')
    os.system(f'aws configure set aws_secret_access_key {AWS_SECRET_KEY} --profile kodekloud')
    os.system(f'aws configure set region us-east-1 --profile kodekloud')

    print("✅ AWS CLI Configured Successfully!")

except Exception as e:
    print("❌ Error:", str(e))

finally:
    driver.quit()
