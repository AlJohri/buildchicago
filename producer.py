from redis import Redis
from rq import Queue
from models import Session, FacebookUser, FacebookPage, FacebookGroup

session = Session()

q = Queue(connection=Redis())

from get_friends import get_friends

incomplete_fans = session.query(FacebookUser).filter(FacebookUser.data=="in progress").all()
todo_fans = session.query(FacebookUser).filter(FacebookUser.data=="todo").all()

print "Grabbing friends of %s fans" % len(todo_fans)
for i, fan in enumerate(todo_fans):
	result = q.enqueue(get_friends, fan.username)
	# result = q.enqueue_call(func=get_friends, args=(fan.username,), timeout=3600)