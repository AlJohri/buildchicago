workon buildchicago
source .secret
rqworker
rq-dashboard
pg_dump --no-owner --schema=public buildchicago > latest.dump.txt
nohup rqworker -n worker1 &> worker1.log&