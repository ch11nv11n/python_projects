###### these imports are used to create google api instance ######
from __future__ import print_function
import os.path
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
##################################################################

###### imports for rest of program ###############################
import requests
from bs4 import BeautifulSoup
import re
import sys
from datetime import date
import calendar
##################################################################

'''
This program scrapes a shoe release site and gives you a list of sneakers being released based on your selection.
Asks you if you want to schedule a notification for a specific option on the given list of shoes.
If so, it adds an event to your google calendar on the date the sneaker releases. (You have to enable calendar api permissions through Google to write to calendar: https://console.cloud.google.com/apis/library/calendar-json.googleapis.com?project=cs50pfinal)
You then have the option to schedule another notification if desired.
If you don't want to schedule a notification, or an additional notification the program ends.

'''

##########################  MAIN  ######################################
def main(): 
    print(displayMenu())
    userSelection = int(validateMainMenuOption('Select option: '))
    print()
    if userSelection == 4:
        quitApplication()
    
    prodRecords = scrapeData(userSelection)
    scrapeOutput(prodRecords)
    print()
    scheduleNotification('Schedule a notification? (y/n): ',prodRecords)


########################################################################
def displayMenu() -> None:
    '''
    Displays main menu of program
    '''
    return (
        '''
======================================================
        Google Calendar Shoe Release Scheduler
======================================================
  [1] View All Releases
  [2] View Jordan Releases
  [3] View Yeezy Releases
  [4] Quit Program
        '''
    )
########################################################################


########################################################################
def validateMainMenuOption(mainMenuOption: int) -> int:
    '''
    Validates main menu option selection.
    
    :param mainMenuOption: user's entered option
    :type mainMenuOption: str
    :raise ValueError: If mainMenuOption is not a valid menu selection
    :rtype: int
    '''
    while True:
        try:
            mainMenuOption = int(input('Select option: '))
            if mainMenuOption not in range(1,5):
                raise ValueError
            else:
                return mainMenuOption

        except ValueError:
            print('\n','Not a valid option. Please try again.')
            displayMenu()
########################################################################


########################################################################
def scrapeData(selection: int) -> list:
    '''
    Requests data from a list of links or a single link in that list depending on selection param.
    
    :param selection: main menu selection
    :type selection: int
    :rtype: list
    '''
    
    snkrRlseLinks = ['https://sneakernews.com/release-dates/', 'https://sneakernews.com/air-jordan-release-dates/', 'https://sneakernews.com/adidas-yeezy-release-dates/']
    
    prodRecords = []

    if selection == 1:
        for link in snkrRlseLinks:
            snkrRlsePage = requests.get(link)

            soup = BeautifulSoup(snkrRlsePage.content, 'html.parser')

            allTiles = soup.find_all('div', class_='content-box')
            for tile in allTiles:
                releaseDate = tile.find('span', class_='release-date').get_text().strip()
                prodName = tile.find('h2').get_text().strip()
                prodPrice = tile.find('span', class_='release-price').get_text().strip()
                prodData = tile.find('div', class_='post-data')
                prodSizeRun = prodData.contents[1].get_text().strip()
                prodColor = prodData.contents[3].get_text().strip()
                prodStyle = prodData.contents[5].get_text().strip()
                prodReigon = prodData.contents[7].get_text().strip()    

                CleanDate = dateClean(releaseDate)

                # adding data to prodData list
                prodRecords.append({
                    'Release Date' : CleanDate,
                    'Product Name' : prodName,
                    'Size Run' : prodSizeRun[9:],
                    'Product Price' : prodPrice,
                    'Color' : prodColor[6:],
                    'Style Code' : prodStyle[11:],
                    'Reigon' : prodReigon[7:],
                })

        return prodRecords

    elif selection == 2:
        snkrRlsePage = requests.get(snkrRlseLinks[1])

    elif selection == 3:
        snkrRlsePage = requests.get(snkrRlseLinks[2])
        
    soup = BeautifulSoup(snkrRlsePage.content, 'html.parser')
    allTiles = soup.find_all('div', class_='content-box')
    for tile in allTiles:
        releaseDate = tile.find('span', class_='release-date').get_text().strip()
        prodName = tile.find('h2').get_text().strip()
        prodPrice = tile.find('span', class_='release-price').get_text().strip()
        prodData = tile.find('div', class_='post-data')
        prodSizeRun = prodData.contents[1].get_text().strip()
        prodColor = prodData.contents[3].get_text().strip()
        prodStyle = prodData.contents[5].get_text().strip()
        prodReigon = prodData.contents[7].get_text().strip()

        CleanDate = dateClean(releaseDate)        
        
        # adding data to prodData list
        prodRecords.append({
            'Release Date' : CleanDate,
            'Product Name' : prodName,
            'Size Run' : prodSizeRun[9:],
            'Product Price' : prodPrice,
            'Color' : prodColor[6:],
            'Style Code' : prodStyle[11:],
            'Reigon' : prodReigon[7:],
        })

    return prodRecords  
########################################################################          


########################################################################
def dateClean(dte: str) -> date:
    '''
    There are 3 variations of dates that come from the site I am scraping: there is a month.day format, a year only format, and a month name only format.
    This function converts any of these variations to a proper date format using regex

    :param dte: date string that comes from the scrapeData function
    :type dte: str
    :rtype: date
    '''

    today = date.today()

    # if formatted as 2 digit day and month seperated by .
    if re.search(r'\d{2}\.\d{2}',dte):
        month,day = dte.split('.') 
        month = int(month)
        day = int(day)
        cleanDate = date(day=day, month=month, year=today.year)
        
        return cleanDate

    # if just year
    elif re.search(r'\d{4}',dte):
        year = int(dte)
        month = 1
        day = 1
        cleanDate = date(day=day, month=month, year=year)

        return cleanDate 
 
    # else convert month name to month num
    else:
        month2num = {month: index for index, month in enumerate(calendar.month_name) if month} # creating a dict to convert month name to month number
        month = month2num[dte]
        day = 1
        cleanDate = date(day=day, month=month, year=today.year)

        return cleanDate    
########################################################################


########################################################################
def scrapeOutput(outputList: list) -> None:
    '''
    Displays formatted scraped data
    '''
    enumeratedOutputList = enumerate(outputList,1)
    # enumerated output for all shoes
    for count, record in enumeratedOutputList:
        if count < 10:
            print('','['+str(count)+']',record['Release Date'],record['Product Name'],record['Product Price'],record['Size Run'],record['Color'],record['Style Code'],record['Reigon'])
        else:
            print('['+str(count)+']',record['Release Date'],record['Product Name'],record['Product Price'],record['Size Run'],record['Color'],record['Style Code'],record['Reigon'])
########################################################################


########################################################################
def scheduleNotification(scheduleChoice: str, itemList: list):
    '''
    Gets and confirms item to schedule a notification for in Google calendar

    :param scheduleChoice, itemList: Validates if user wants to schedule a notification, Used to select what item to add to calendar
    :type scheduleChoice, itemList: str, list
    :raise ValueError: If scheduleChoice is not a valid menu selection
    ''' 
    while True:
        scheduleChoice = input('Schedule a notification? (y/n): ').lower()
        print()
        if scheduleChoice == 'y':
            while True:
                try:
                    itemChoice = int(input('Which item do you want to schedule: '))
                    if itemChoice <= 0:
                        raise ValueError

                except ValueError:
                    print('Not a valid option','\n')
                    continue

                else:
                    print()
                    try:
                        selectedItem = itemList[itemChoice-1]
                    except IndexError:
                        print('Not a valid option','\n')
                        continue
                    else:
                        rDate:str = selectedItem["Release Date"]
                        itemName:str = str(selectedItem["Product Name"]).upper()
                        run:str = selectedItem['Size Run']

                        confirmation:str = input(f'Confirm you want to schedule: {itemName}, {run}' + '\n' + f'On {rDate.month}-{rDate.day}-{rDate.year} (y/n): ')

                        if confirmation == 'y':
                            scheduleInGoogleCal(selectedItem)
                        elif confirmation == 'n':
                            print()
                            continue

        elif scheduleChoice == 'n':
            quitApplication()
########################################################################


########################################################################
def quitApplication() -> None:
    '''
    Quits program using sys library    
    '''
    sys.exit('Bye!')
########################################################################


########################################################################
def scheduleInGoogleCal(shoeDetails: dict):
    '''
    Takes details of selected shoe to send through Google calendar api, after authentication, to create notification on calendar.
    
    :param shoeDetails: dictionary of user selected shoe with all prod details 
    :type shoeDetails: dict   
    '''
    # If modifying these scopes, delete the file token.json.
    SCOPES = ['https://www.googleapis.com/auth/calendar']

    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())

    service = build('calendar', 'v3', credentials=creds)

    calID = 'joedejesus91@gmail.com'

    releaseDateYMD = shoeDetails['Release Date']
    releaseDateYMDString = str(shoeDetails['Release Date'])
    rDate = f'{releaseDateYMD.month}-{releaseDateYMD.day}-{releaseDateYMD.year}'
    shoeName = shoeDetails['Product Name']
    shoePrice = shoeDetails["Product Price"]
    shoeRun = shoeDetails["Size Run"]
    shoeColor = shoeDetails["Color"]
    shoeStyle = shoeDetails["Style Code"]
    shoeReigon = shoeDetails["Reigon"]
    
    event = {
    'summary': shoeName + ' Drop',
    'description': 
                    f'Cost: {shoePrice} ' + '\n' +  
                    f'Run: {shoeRun} ' + '\n' +  
                    f'Color: {shoeColor} ' + '\n' +  
                    f'Style Code: {shoeStyle} ' + '\n' +  
                    f'Reigon: {shoeReigon}',
    'start': {
      'date': releaseDateYMDString,
    },
    'end': {
      'date': releaseDateYMDString,
    },

    'transparency': 'transparent',
    
    }

    service.events().insert(
        calendarId = calID,
        body = event
    ).execute() 
    
    print()
    print(f'Notification set for {shoeName} on {rDate} for {calID}', '\n')

    while True:
        scheduleMore = input('Schedule another notification? (y/n): ').lower()
        print()

        if scheduleMore == 'y':
            main()
        elif scheduleMore == 'n':
            sys.exit()
########################################################################


if __name__ == "__main__":
    main()