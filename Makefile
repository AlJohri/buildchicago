all: network
clean:
	rm analysis/edgelist.csv analysis/users.csv analysis/donors.csv analysis/matched_donors.csv analysis/matched_personnel.csv

analysis/edgelist.csv:
	psql -d buildchicago -c "SELECT uid1, uid2 FROM facebook_friends" -o 'analysis/edgelist.csv' -F ',' -A --pset footer

analysis/users.csv:
	psql -d buildchicago -c "SELECT name, username, fbu.uid, (CASE WHEN fbpu.uid IS NULL THEN 0 ELSE 1 END) AS fan FROM facebook_users fbu LEFT OUTER JOIN facebook_pages_users fbpu ON fbu.uid = fbpu.uid" -o 'analysis/users.csv' -F ',' -A --pset footer

analysis/donors.csv:
	Rscript analysis/aggregate_donors.R

# Note: This csv file only includes donors who matched to a UNIQUE facebook user
analysis/matched_donors.csv: analysis/donors.csv analysis/users.csv
	./analysis/match_names analysis/donors.csv Name analysis/users.csv name > analysis/matched_donors.csv

analysis/matched_personnel.csv: analysis/users.csv
	./match_names analysis/build_personnel.csv name analysis/users.csv name > analysis/matched_personnel.csv

analysis/analysis.html: analysis/edgelist.csv analysis/users.csv analysis/donors.csv analysis/matched_donors.csv analysis/matched_personnel.csv
	Rscript -e "setwd('analysis'); require(knitr); require(pander); spin('analysis.R'); Pandoc.convert('analysis.md')"

network: analysis/analysis.html
	python convert.py analysis/*.gml
