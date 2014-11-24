from models import Session, FacebookUser, FacebookPage, FacebookGroup
from lib import get_scraper, save_user, save_page

import logging
logging.basicConfig(level=logging.DEBUG)
session = Session()
scraper = get_scraper()

incomplete_fans = session.query(FacebookUser).filter(data="incomplete").all()
todo_fans = session.query(FacebookUser).filter(data="todo").all()

def get_friends(fans):
	for i, fan in fans:

		fan.data = "in progress"
		session.commit()

		for result in scraper.get_friends_nograph(fan.username):
			current_user = save_user(result, session)
			fan.friend(current_user)
			print fan.name, "is friends with", current_user.name
			session.commit()

		fan.data = "done"
		session.commit()

get_friends(incomplete_fans)
get_friends(todo_fans)