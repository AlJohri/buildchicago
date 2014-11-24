from models import Session, FacebookUser, FacebookPage, FacebookGroup
from lib import get_scraper, save_user, save_page

import logging
logging.basicConfig(level=logging.DEBUG)
session = Session()
scraper = get_scraper()

buildchicago_username = "BUILDChicago"
buildchicago_id = "166962743387695"

for i, fan in enumerate(scraper.graph_search(None, "likers", buildchicago_id)):
    user = save_user(fan, session)
    print user
