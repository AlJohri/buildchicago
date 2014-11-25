import requests
from models import Session, FacebookUser, FacebookPage, FacebookGroup
from lib import get_scraper, save_user, save_page

import logging
logging.basicConfig(level=logging.DEBUG)

scraper = get_scraper()

def get_friends(username):

	session = Session()
	session.expire_on_commit = False

	fan = session.query(FacebookUser).filter_by(username=username).first()

	print "Friends of %s" % fan.name

	fan.data = "in progress"
	session.commit()

	try:
		for result in scraper.get_friends_nograph(fan.username):
			print result
			current_user = save_user(result, session, log=False)
			fan.friend(current_user)
			print "\t-", fan.name, "is friends with", current_user.name
			session.commit()
	except requests.exceptions.ConnectionError as e:
		fan.data = "error - %s" % e
		session.commit()
		return "errored out with %s after downloading %d friends for %s" % (e, fan.friends.count(), fan.username)

	fan.data = "done"
	session.commit()
	session.close()

	return "downloaded %d friends for %s" % (fan.friends.count(), fan.username)