import dotenv
import os

dotenv.load_dotenv('.env')

# setting username and password securely
USERNAME = os.environ['USERNAME']
PASSWORD = os.environ['PASSWORD']

# setting current working dir
__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))

# setting search string
BINGURL = 'http://www.bing.com/search?q='
