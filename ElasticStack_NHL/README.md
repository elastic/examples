# NHL Play by Play -> Elasticsearch

Sucks down data from live.nhl.com.  E.g., 
http://live.nhl.com/GameData/20142015/2014021136/PlayByPlay.json

Imports it into Elasticsearch by season or by game.


1. Install Elasticsearch 
2. Install NodeJS
3. Run # npm install
4. Run # ./clean.sh to erase any previous data and re-prepare the index (shows an error the first time it runs, that's ok)
5. Run # node go.js to importing data as shown below
6. Fire up Kibana and create an index pattern called "nhl"
7. Import the dashboards.json file into Kibana

Usage:
```
node go.js <season> [gameid]
```

Example, Import the whole 2014-2015 season:
```
node go.js 2014
```

Example, Import a specific game (once you know the id).  This is specific for updating real time during a game.
```
node go.js 2014 2014030416
```

Top Hitters, Shooters, Scorers & Penalties per Game
![Game Data](https://github.com/PhaedrusTheGreek/nhl-stats-elasticsearch/blob/master/game.png)

All Season Top Hitters, Shooters, and Scorers against the Habs
![Against Data](https://github.com/PhaedrusTheGreek/nhl-stats-elasticsearch/blob/master/against.png)
