import dotenv
import os

dotenv.load_dotenv('.env')

# setting username and password securely
USERNAME = os.environ['MS_USERNAME']
PASSWORD = os.environ['PASSWORD']

# EMAIL SETUP
SMTP_PORT = os.environ['SMTP_PORT']
SMTP_SERVER = os.environ['SMTP_SERVER']
EMAIL_PASSWORD = os.environ['EMAIL_PASSWORD']
FROM_ADDR = os.environ['FROM_ADDR']
TO_ADDR = os.environ['TO_ADDR']

# setting current working dir
__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
MSDRIVER = __location__ + '\\' +os.environ['EDGEDRIVER']

# setting search string
BINGURL = 'http://www.bing.com/search?q='
