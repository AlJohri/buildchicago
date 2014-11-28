all: analysis.html
clean:
	rm edgelist.csv users.csv donors.csv matched_donors.csv matched_personnel.csv

edgelist.csv:
	psql -d buildchicago -c "SELECT uid1, uid2 FROM facebook_friends" -o 'edgelist.csv' -F ',' -A --pset footer

users.csv:
	psql -d buildchicago -c "SELECT name, username, fbu.uid, (CASE WHEN fbpu.uid IS NULL THEN 0 ELSE 1 END) AS fan FROM facebook_users fbu LEFT OUTER JOIN facebook_pages_users fbpu ON fbu.uid = fbpu.uid" -o 'users.csv' -F ',' -A --pset footer

donors.csv:
	Rscript aggregate_donors.R

# Note: This csv file only includes donors who matched to a UNIQUE facebook user
matched_donors.csv: donors.csv users.csv
	./match_names donors.csv Name users.csv name > matched_donors.csv

matched_personnel.csv: users.csv
	./match_names build_personnel.csv name users.csv name > matched_personnel.csv

analysis.html: edgelist.csv users.csv donors.csv matched_donors.csv matched_personnell.csv
	Rscript -e "require(knitr); require(pander); spin('analysis.R'); Pandoc.convert('analysis.md')"
