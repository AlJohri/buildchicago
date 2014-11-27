Usage
```
workon buildchicago
source .secret
python -i models.py
```

Scraping
```
rq-dashboard

# foreground (just open separate tabs)
rqworker
rqworker
rqworker
rqworker
rqworker

# background
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
createdb buildchicago
cat latest.dump.txt | psql buildchicago
```

Backup Database
```
pg_dump --no-owner --schema=public buildchicago > latest.dump.txt
```

Restore Database
```
cat latest.dump.txt | psql buildchicago
```


Queries
```
session.query(FacebookUser).filter(FacebookUser.pages.any(username="BUILDChicago")).count()
session.query(FacebookUser).filter(FacebookUser.pages.any(username="BUILDChicago")).filter(FacebookUser.data==None).count()
session.query(FacebookUser).filter(FacebookUser.pages.any(username="BUILDChicago")).filter(FacebookUser.data=="done").count()
```

Analysis Setup

1. Add donations data: Save donations data as .csv files under analysis/

2. Restore database:
```
createdb buildchicago
cat latest.dump.txt | psql buildchicago
```

3. Generate .csv files:
```
cd analysis
make all
```

Some analysis ideas that have yet to be implemented:
- Run a community detection algorithm to identify clusters of fans and donors

- Allocate each donor's donation amount evenly across each of its edges, then calculate a weighted betweenness centrality score for each node in the network. This will serve as a metric of which fans and/or donors are the most critical to bringing in donations.
