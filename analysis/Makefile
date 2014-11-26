clean:
	rm edgelist.csv users.csv donors.csv

edgelist.csv:
	psql -d buildchicago -c "SELECT uid1, uid2 FROM facebook_friends" -o 'edgelist.csv' -F ',' -A --pset footer

users.csv:
	psql -d buildchicago -c "SELECT name, fbu.uid, (CASE WHEN fbpu.uid IS NULL THEN 0 ELSE 1 END) AS fan FROM facebook_users fbu LEFT OUTER JOIN facebook_pages_users fbpu ON fbu.uid = fbpu.uid" -o 'users.csv' -F ',' -A --pset footer

donors.csv:
	Rscript aggregate_donors.R

matched_names.csv: donors.csv users.csv
