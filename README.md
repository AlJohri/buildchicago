Usage
```
workon buildchicago
source .secret
python -i models.py

# when facebook graph api key expires:
# edit .secret file
# source .secret
# rm facebook_scraper.pickle
# rerun command
```

Scraping
```
rq-dashboard
nohup rqworker -n worker1 &> worker1.log&
nohup rqworker -n worker2 &> worker2.log&
nohup rqworker -n worker3 &> worker3.log&
nohup rqworker -n worker4 &> worker4.log&
nohup rqworker -n worker5 &> worker5.log&
tail -f worker1.log -f worker2.log -f worker3.log -f worker4.log -f worker5.log
```

Setup
```
mkvirtualenv buildchicago
pip install -r requirements.txt
cp .secret.example .secret
# fill in .secret file
```

Backup Database
```
pg_dump --no-owner --schema=public buildchicago > latest.dump.txt
```

Restore Database
```
cat latest.dump.txt | psql buildchicago
```