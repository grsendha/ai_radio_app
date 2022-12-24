// Use this sample to create your own voice commands
intent('hello world', p => {
    p.play('(hello|hi there)');
});

intent(
    'what this app can do',
    reply('This is a AI radio app where you can ask me to play some music'),
);




intent('play $(CHANNEL* (.*)) fm',p=>{
    let channel=project.radios.filter(x=>x.name.toLowerCase() === p.CHANNEL.value.toLowerCase())[0];
    try{
        p.play({"command":"play_channel","id":channel.id});
        p.play("(playing now|on it| roger that)");
    }catch(err){
        console.log("cant play");
        p.play("(cant play this)");
    }
});

intent('play (some|) $(CATEGORY* (.*)) music',p=>{
    let channel=project.radios.filter(x=>x.category.toLowerCase() === p.CATEGORY.value.toLowerCase())[0];
    try{
        p.play({"command":"play_channel","id":channel.id});
        p.play("(playing now|roger that)");
    }catch(err){
        console.log("cant play");
        p.play("(i could not find the genre)");
    }
});

intent('(play)','play (the|) (some|) music',p=>{
    p.play({"command":"play"});
    p.play("(playing now|roger that)");
});

intent('stop (it|)','stop (the|) music','pause (it|)','pause (the|) music',p=>{
    p.play({"command":"stop"});
    p.play("(stopping now|roger that)");
});


intent('(play|) next (channel|fm|radio)',p=>{
    p.play({"command":"next"});
    p.play("(ok captain|roger that)");
});

intent('(play|) previous (channel|fm|radio)',p=>{
    p.play({"command":"prev"});
    p.play("(ok captain|roger that)");
});

