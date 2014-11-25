"""
Copy data from engine1 to engine2. Assumes engine1 has data and engine2 is empty (but database exists).
"""

from models import Base

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm.session import make_transient

engine1 = create_engine('sqlite:///data.db', echo=False)
engine2 = create_engine('postgresql:///buildchicago', echo=False)

Session1 = sessionmaker(bind=engine1)
Session2 = sessionmaker(bind=engine2)

session1 = Session1()
session2 = Session2()

Base.metadata.drop_all(engine2)
Base.metadata.create_all(engine2)

# must ensure that table occurs before join tables / foreign keys
# not sure how to do that
for model in Base.__subclasses__():
	print model
	for obj in session1.query(model).all():
		print obj
		make_transient(obj)
		session2.add(obj)
	session2.commit()

print ""

for model in Base.__subclasses__():
	print model, session1.query(model).count(), session2.query(model).count()

session1.close()
session2.close()