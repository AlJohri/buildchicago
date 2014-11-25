import csv
from models import Session, FacebookUser

session = Session()

with open("users.csv", "w") as f:
	writer = csv.writer(f)
	for user in session.query(FacebookUser).all():
		row = [user.uid, user.username, user.name.encode('utf-8'), ", ".join([page.name for page in user.pages])]
		writer.writerow(row)
		print row