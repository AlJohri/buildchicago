import sys, json
from networkx import nx

filename = sys.argv[1].split("/")[-1]

G = nx.read_gml(sys.argv[1])
for node in G.nodes(data=True):
	node[1]['viz'] = eval(node[1]['viz'].replace("-Inf", "float(\"-inf\")"))

print "write to gefx from networkx"
nx.write_gexf(G, './network/data/%s.gexf' % filename)
config = json.load(open("./network/sample.json"))
config['data'] = 'data/%s.gexf' % filename
config['logo']['text'] = filename.title()
config['text']['title'] = filename.title()
json.dump(config, open('./network/%s.json' % filename, 'w'))
