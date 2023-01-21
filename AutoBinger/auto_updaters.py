import os
import requests
import glob
import zipfile
import time
from bs4 import BeautifulSoup

############################################################################################
############################# GECKO DRIVER FUNCTIONS #######################################
############################################################################################

def get_latest_gecko_driver_version() -> None:
    ''' gets latest version of Gekodriver for Firefox browser Selenium integration '''

    r = requests.get('https://api.github.com/repos/mozilla/geckodriver/releases/latest')
    return r.json()['tag_name']  

def check_and_update_geckodriver() -> None:
    latest_version: str = get_latest_gecko_driver_version()
    local_file_name: str = f'geckodriver-{latest_version}.exe'  
    gecko_file_path: str = os.path.join(os.getcwd(), local_file_name)
    
    if not os.path.isfile(gecko_file_path): # if file does not exist
        print(f'The file "{local_file_name}" DOES NOT exist or does not end in {latest_version}')
        replace_geckodriver(latest_version)

    else:
        # file exists and ends in current version
        print(f'The file "{local_file_name}" exists and does end in {latest_version}')
        return

def replace_geckodriver(version: str):
    ''' downloads driver zip, extracts to dir, then deletes the zip + old file '''
    
    # removes old geckodriver version
    old_file_pattern = 'geckodriver-v*.exe'
    old_file = glob.glob(old_file_pattern)
    for f in old_file:
        os.remove(f)
        
    # downloads updated driver zip from web
    url = f'https://github.com/mozilla/geckodriver/releases/download/{version}/geckodriver-{version}-win64.zip'
    r = requests.get(url)
    __location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
    gecko_zip = __location__ + f'\geckodriver-{version}-win64.zip'  
    open(gecko_zip,'wb').write(r.content)

    time.sleep(2)

    # Extract the file from the zip file
    with zipfile.ZipFile(gecko_zip, 'r') as zip_ref:
        zip_ref.extractall(__location__)
    
    time.sleep(2)

    # Rename the file
    os.rename(__location__ + '\geckodriver.exe', __location__ + f'\geckodriver-{version}.exe')

    time.sleep(2)

    # Delete the zip
    os.remove(gecko_zip)

############################################################################################
################################ MS DRIVER FUNCTIONS #######################################
############################################################################################

def get_latest_ms_driver_version() -> None:
    ''' gets latest version of MS driver for Edge browser Selenium integration '''

    r = requests.get('https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/#downloads')
    soup = BeautifulSoup(r.text, 'html.parser')
    stable_version = soup.find('p', class_= 'driver-download__meta').text
    version_num = 'v' + stable_version.split(':')[1].strip()
    return version_num

def check_and_update_msdriver() -> None:
    latest_version: str = get_latest_ms_driver_version()
    local_file_name: str = f'msedgedriver-{latest_version}.exe'  
    ms_file_path: str = os.path.join(os.getcwd(), local_file_name)
    
    if not os.path.isfile(ms_file_path): # if file does not exist
        print(f'The file "{local_file_name}" DOES NOT exist or does not end in {latest_version}')
        replace_msdriver(latest_version)

    else:
        # file exists and ends in current version
        print(f'The file "{local_file_name}" exists and does end in {latest_version}')
        return

def replace_msdriver(version: str):
    ''' downloads driver zip, extracts to dir, then deletes the zip + old file '''
    
    # removes old geckodriver version
    old_file_pattern = 'msedgedriver-v*.exe'
    old_file = glob.glob(old_file_pattern)
    for f in old_file:
        os.remove(f)
        
    # downloads updated driver zip from web
    url = f'https://msedgedriver.azureedge.net/{version[1:]}/edgedriver_win64.zip'

    r = requests.get(url)
    __location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
    ms_zip = __location__ + f'\edgedriver_win64.zip'  
    open(ms_zip,'wb').write(r.content)

    time.sleep(2)

    # Extract the file from the zip file
    with zipfile.ZipFile(ms_zip, 'r') as zip_ref:
        zip_ref.extract('msedgedriver.exe',path=__location__)
    
    time.sleep(2)

    # Rename the file
    os.rename(__location__ + '\msedgedriver.exe', __location__ + f'\msedgedriver-{version}.exe')

    time.sleep(2)

    # Delete the zip
    os.remove(ms_zip)
