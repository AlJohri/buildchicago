# http://docs.sqlalchemy.org/en/rel_0_9/orm/tutorial.html

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship, backref
from sqlalchemy.orm import sessionmaker
from sqlalchemy import func
from sqlalchemy.orm import aliased

from pprint import pprint as pp

LOCAL_DATABASE_URL = 'postgresql:///buildchicago'

engine = create_engine(LOCAL_DATABASE_URL, echo=False)
Session = sessionmaker(bind=engine)
Base = declarative_base()

from socialscraper.adapters import adapter_sqlalchemy

class BaseModel(object):
    created_at = Column(DateTime)
    updated_at = Column(DateTime)
    def __init__(self,created_at,updated_at):
        self.created_at = created_at
        self.updated_at = updated_at

base_classes = (Base, BaseModel,)
fbmodels = adapter_sqlalchemy.make_models(Base, base_classes)

FacebookUser = fbmodels['FacebookUser']
FacebookPage = fbmodels['FacebookPage']
FacebookPagesUsers = fbmodels['FacebookPagesUsers']
FacebookFriend = fbmodels['FacebookFriend']
FacebookGroup = fbmodels['FacebookGroup']
FacebookGroupsUsers = fbmodels['FacebookGroupsUsers']

__all__ = ['Session', 'FacebookPage', 'FacebookUser', 'FacebookPagesUsers', 'FacebookFriend', 'FacebookGroup', 'FacebookGroupsUsers']

if __name__ == '__main__':
    session = Session()
    from lib import status_users
    from functools import partial
    status_users = partial(status_users, session)