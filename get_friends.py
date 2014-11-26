import requests
from models import Session, FacebookUser, FacebookPage, FacebookGroup
from lib import get_scraper, save_user, save_page

import logging
logging.basicConfig(level=logging.DEBUG)

scraper = get_scraper()

def get_friends(username):

	print username

	session = Session()
	session.expire_on_commit = False

	fan = session.query(FacebookUser).filter_by(username=username).first()

	fan_username = fan.username or fan.uid

	print "Friends of %s" % fan_username

	fan.data = "in progress"
	session.commit()

	for result in scraper.get_friends_nograph(fan_username):
		print result
		current_user = save_user(result, session, log=False)
		fan.friend(current_user)
		print "\t-", fan_username, "is friends with", current_user.username
		session.commit()

	fan.data = "done"
	session.commit()
	session.close()

	return "downloaded %d friends for %s" % (fan.friends.count(), username)

# try:
# 	# requests.get('asdfasdf')
# except requests.exceptions.ConnectionError as e:
