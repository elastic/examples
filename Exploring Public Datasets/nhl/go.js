var request = require("request")
var forEachAsync = require('futures').forEachAsync;

var targetEndpoint = 'http://localhost:9200';
var targetIndex = 'nhl';
var targetType = 'play';

var totalPlays = 0;

// Required Season
var arg_season = parseInt(process.argv[2]);

// Options Game ID
var arg_game = process.argv[3];

var season = "" + arg_season + (arg_season+1);
var url = "http://live.nhl.com/GameData/SeasonSchedule-" + season + ".json";

request({
    url: url,
    json: true
}, function (error, response, body) {

	if (error || response.statusCode !== 200) {
		console.log("Could not get season " + season + ": " + error);
		process.exit(1);
	}

	var games = body;
	forEachAsync(games, function (nextGame, game, index, array) {

		if (arg_game && game.id != arg_game) {
		   nextGame();
		   return;
		} 
	
		var est = game.est;
		var game_date = Date.parse(est);

		var url = "http://live.nhl.com/GameData/" + season + "/" + game.id + "/PlayByPlay.json";
		process.stdout.write(".");

		var year = game.est.substring(0,4);
		var month = game.est.substring(4,6);
		var day = game.est.substring(6,8);
		var hours = game.est.substring(9,11);
		var minutes = game.est.substring(12,14);
		var seconds = game.est.substring(15,17);
		var gameDate = new Date(year, month-1, day, hours, minutes, seconds);

		var gameBulk = "";

		request({
		    url: url,
		    json: true
		}, function (error, response, body) {

			if (error || response.statusCode !== 200 || !body || !body.data) {
				console.log("Could not get game " + url + ": " + error);
				nextGame();
				return;
			}

			var awayteamid = body.data.game.awayteamid;
			var hometeamid = body.data.game.hometeamid;
			var awayteamnick = body.data.game.awayteamnick;
			var hometeamnick = body.data.game.hometeamnick;


			var teamnick = {};
			teamnick[awayteamid] = awayteamnick;
			teamnick[hometeamid] = hometeamnick;

			var opposing = {};
			opposing[awayteamid] = hometeamnick;
			opposing[hometeamid] = awayteamnick;

			for (var p in body.data.game.plays.play) {

				var play = body.data.game.plays.play[p];
				var play_minutes = parseInt(play.time.substring(0,2)) + ((play.period-1) * 20);
				var play_seconds = parseInt(play.time.substring(3,5));
				var playDate =  new Date(gameDate.getTime())
				playDate.setMinutes(playDate.getMinutes()+play_minutes);
				playDate.setSeconds(playDate.getSeconds()+play_seconds);
				play.timestamp = playDate.toISOString();
				play.teamnick = teamnick[play.teamid];
				play.teamnick_opposing = opposing[play.teamid];
				play.game = game;

				totalPlays++;

				gameBulk += JSON.stringify({ "index" : { "_id" : game.id + ":" + play.timestamp } }) + "\n";
				gameBulk += JSON.stringify(play) + "\n";

			}

			//console.log(gameBulk);
			request.post({
			  headers: {'content-type' : 'application/x-www-form-urlencoded'},
			  url:     targetEndpoint + '/' + targetIndex + '/' + targetType + '/_bulk',
			  body:    gameBulk
			}, function(err, response, body){
			  if (err || response.statusCode != 200) {
			    return console.error('index failed:', response.statusMessage + (err ? (" - " + err) : ""));
			  }
			});

			// no reason why this has to be synchronized
			nextGame();

		})


	}).then(function () {
		console.log("\nDone.  Total Plays Read: " + totalPlays);
	});


})




