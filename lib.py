from socialscraper.facebook import FacebookScraper
from models import Session, FacebookUser, FacebookGroup, FacebookPage
from socialscraper.adapters.adapter_sqlalchemy import convert_result

import os, datetime, pickle

def save_user(result, session, log=True):
    user = session.query(FacebookUser).filter_by(uid=result.uid).first()
    if not user:
        user = FacebookUser()
        convert_result(user, result)
        user.created_at = datetime.datetime.now()
        session.add(user)
        if log: print user.name, "created"

    session.commit()

    return user

def save_group(result, session, log=True):
    group = session.query(FacebookGroup).filter_by(group_id=result.group_id).first()
    if not group:
        group = FacebookGroup()
        convert_result(group, result)
        group.created_at = datetime.datetime.now()
        session.add(group)
        if log: print group.name, "created"

    return group

def save_page(result, session, log=True):
    page = session.query(FacebookPage).filter_by(page_id=result.page_id).first()
    if not page:
        page = FacebookPage()
        convert_result(page, result)
        page.created_at = datetime.datetime.now()
        session.add(page)
        if log: print page.name, "created"

    return page

def get_scraper():
    scraper_type = "nograph"
    if not os.path.isfile('facebook_scraper.pickle'):
        scraper = FacebookScraper(scraper_type=scraper_type)
        scraper.add_user(email=os.getenv('FACEBOOK_EMAIL'), password=os.getenv('FACEBOOK_PASSWORD'))
        scraper.login()
        scraper.init_api()
        pickle.dump(scraper, open('facebook_scraper.pickle', 'wb'))
    else:
        scraper = pickle.load(open('facebook_scraper.pickle', 'rb'))
        scraper.scraper_type = scraper_type

    return scraper