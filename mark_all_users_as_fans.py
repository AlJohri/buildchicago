from models import Session, FacebookUser, FacebookPage, FacebookGroup
from lib import get_scraper, save_user, save_page

import logging
logging.basicConfig(level=logging.DEBUG)
session = Session()
scraper = get_scraper()

buildchicago = session.query(FacebookPage).filter(FacebookPage.page_id==166962743387695).first()
if not buildchicago:
	buildchicago = FacebookPage(page_id=166962743387695, username="BUILDChicago", name="Build Chicago")
	session.add(buildchicago)
	session.commit()

for user in session.query(FacebookUser).all():
	buildchicago.users.append(user)
	session.commit()
