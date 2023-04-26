diag_db={
    active=nil,
    ['sc_1_intro']={
        {sp=365,'Okay newbie! Theory lessons are over, now it\'s time for practice!'},
        {'Your first job! Clean the Academy dungeon! Come see me afterwards if you\'re still alive!'},
        {sp=317,'...'},
        {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
    },
    ['sc_1_telepathy']={
        i=1,
        {j=1,sp=269,'(I\'ve figured out a way to legally break the Academy\'s vow of silence!)'},
        {'(Telepathy!)'},
        {'(Just focus on my voice in your head!)'},
        {sp=317,'(Why is he staring at me so intently)'},
        {sp=269,'(Am I clever or what?)'},
        {sp=317,'(stop it stop it stop it stop it this is beyond awkward)'},
        {f=function() clip(); sc_t=t+1; TIC=overworld_fadeout; cur_encounter=encounters['rival1']; fr=260; fa=21 end},
    },
    ['sc_1_post-telepathy']={
        {sp=269,'(Not fair, you just lucked out!)'},
        {'(Come see me again when you\'re stronger!)'},
        {'(In the meantime, I\'ll be fighting some boss enemies! Sayonara!)'},
        {sp=317,'(There he goes with the staring again..)'},
        {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
    },
    ['sc_2_feedback']={
        {sp=365,f=function() if mget(15,39)==49 or mget(15,45)==49 or #areas[1].roaming>0 then 
            diag_db['sc_2_feedback'][2][1]='You did a so-so job cleaning the dungeon!'
            diag_db['sc_2_feedback'][3][1]='I expect more finesse from my graduates!'
            else
            diag_db['sc_2_feedback'][2][1]='You did a nice job cleaning the dungeon!'
            diag_db['sc_2_feedback'][3][1]='Just what I expect from the graduates of this fine Academy!'
            end
        end},
        {},
        {},
        {'Anyway, let\'s get you patched up! There\'s quite the challenge ahead.'},
        {sp=317, f=function() plr.hp=plr.maxhp end, '(HP restored.)'},
        {f=function() ins(keywords,'[monster generals]') end,sp=365,'The monsters here aren\'t just random encounters. There are [monster generals] that command lesser monsters.'},
        {'If we can get rid of the generals, it will destabilize the monsters.'},
        {f=function() ins(keywords,'[giant mushroom]') end,'There is a [giant mushroom] somewhere in this garden. It\'s one of the generals. You should have the wits to take it out.'},
        {'Look around for clues to its whereabouts.'},
        {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
    },
    ['sc_2_shroom_bros']={
        {sp=374,col=2, 'Before we take this guy to the General for retribution, we\'ve got to decide who\'s our group leader!'},
        {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'I\'m the wisest! Whenever the General needs guidance, he consults me!'},
        {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'I\'m the best fighter! Whenever the General needs someone taken care of, he sends me!'},
        {sp=374,col=2,'I\'m the original one! The lot of you are just lousy palette swaps of me!'},
        {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Ouch, bro.'},
        {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'Yeah, you\'re about to give us Luigi syndrome.'},
        {sp=374,col=2,'Instead of that, let\'s open up the path to the General.'},
    {f=function() clip(); append={{tx=53,ty=38,id=35},{tx=53,ty=39,id=35},{tx=53,ty=40,id=33},{tx=54,ty=40,id=34},{tx=55,ty=40,id=34},{tx=56,ty=40,id=33},{tx=56,ty=41,id=35},{tx=56,ty=42,id=35},{tx=56,ty=43,id=49}}; TIC=overworld_append end},
    },
    ['sc_2_shroom_bros2']={
        {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'How do we tell ourselves apart? It\'s easy!'},
        {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'It\'s in the name. Sheebly\'s E is blue, Shoobly\'s O is yellow, and Shaably\'s A is red.'},
        {sp=374,col=2,'It\'s synaesthetic!'},
        {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Syn-a e s t h e t i c'},
        {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'If there were a Shiibly, he\'d be black, because I is a black letter.'},
    {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
    },
    ['sc_2_demoarea']={
        {sp=374,col=2,'Yo, it looks like you\'re about to leave the demo area.'},
        {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'We can\'t allow that.'},
        {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
    },
    ['sc_2_merch_intro']={
        {sp=208,col=5,'Hello stranger! I\'m a travelling merchant.'},
        {sp=208,col=5,'You may buy my wares with your experience!'},
        {f=function() clip(); sc_t=t+1; TIC=shoppe end},
    },
    ['sc_2_merch_potions']={
        {sp=208,col=5,'Just FYI, you can\'t stockpile potions. You have to drink them on the spot.'},
        {sp=208,col=5,'That\'s because they contain no preservatives.'},
        {sp=208,col=5,'No added sugar, either! And they\'re vegan.'},
        {f=function() clip(); sc_t=t+1; TIC=shoppe end},
    },
    ['sc_2_rat_intro']={
        {sp=69,col=14,'Stop. I see that murderous glare in your eyes.'},
        {sp=69,col=14,'I wish no ill will for you. I just want to ask some questions. Is that okay?'},
        {sp=317,'...'},
        {sp=69,col=14,'Ah, the Academy\'s vow of silence. Well, if you won\'t hurt me this turn, your actions will speak for themselves.'},
        {f=function() clip(); sc_t=t+1; TIC=turn end},
    },
    ['sc_2_rat_phase1']={
        {f=function() ins(keywords,'[you]') end,sp=69,col=14,'First question, and the most basic one. So who are [you] really?'},
        {sp=69,col=14,'You may write your answer on the back of your Picross board.'},
        {sp=317,'*scribble scribble*'},
        {sp=317,'("I am Aldo, a wizard apprentice fresh from the Academy.")'},
        {sp=69,col=14,'I see. They train your kind to persecute us monsters.'},
        {sp=69,col=14,'I can\'t say I condone this activity, but we all choose our own paths.'},
        {f=function() clip(); sc_t=t+1; TIC=enemyturn; enemies[turni].phase=enemies[turni].phase+1; turni=turni+1 end},
    },
    ['sc_2_rat_phase2']={
        {f=function() ins(keywords,'[Picross magic]') end,sp=69,col=14,'Next question. What do you think [Picross magic] really is?'},
        {sp=317,'*scribble scribble*'},
        {sp=317,'("A means of self-defense against monsters.")'},
        {sp=69,col=14,'Ha, of course you think this is how it works. No, I see a conflict in your future.'},
        {sp=69,col=14,'Your answer was superficial. Where do you think [Picross magic] comes from? Do you think it\'s just a given that it works?'},
        {sp=69,col=14,'You still have a lot to learn, but if you stay inquisitive, you will find answers.'},
        {f=function() clip(); sc_t=t+1; TIC=enemyturn; enemies[turni].phase=enemies[turni].phase+1; turni=turni+1 end},
    },
    ['sc_2_rat_phase3']={
        {f=function() ins(keywords,'[quest]') end,sp=69,col=14,'Finally, I want to know: what is your [quest]?'},
        {sp=317,'*scribble scribble*'},
        {sp=317,'("To locate and eliminate the [giant mushroom].")'},
        {sp=69,col=14,'The extent of your snobbery! You\'re simply not strong enough to take out [monster generals].'},
        {sp=69,col=14,'...And I can\'t see why you would even want to. It would only have drastic effects on the balance of this area.'},
        {sp=69,col=14,'No, no good can come from walking that path. I would suggest you seek the path of non-violence.'},
        {sp=69,col=14,'Well, do what you will. Thanks for having this little dialogue, you are now free to go.'},
        {f=function() clip(); turni=turni+1; enemyturn(); gain_exp(); TIC=victory end},
    },
    ['sc_2_rat_attack']={
        {sp=69,col=14,'You\'ve made a grave mistake!'},
        {f=function() clip(); music(5); sc_t=t+1; enemy_cast('Meteor') end},
    },
    ['query_MercRat_[monster generals]']={
        {sp=69,col=14,'Ooh, they\'re very powerful.'},
        {sp=69,col=14,'The ordinance of all monsters rests on their shoulders.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_MercRat_[giant mushroom]']={
        {sp=69,col=14,'It lives to the east of this area, in a hidden location.'},
        {sp=69,col=14,'I don\'t see what business you would have with them.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_MercRat_[you]']={
        {sp=69,col=14,'I\'m just a humble servant of the [monster generals].'},
        {sp=69,col=14,'I\'m perfectly fine with not harming and not being harmed.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_MercRat_[Picross magic]']={
        {sp=69,col=14,'There is a dark secret to [Picross magic].'},
        {sp=69,col=14,'You wouldn\'t fathom the concept, since you\'re from the Academy.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Burr_[you]']={
        {sp=422,col=14,'I HAVE CHRONIC ANXIETY!'},
        {f=function() clip(); TIC=allyturn; allyi=2 end},
    },
    ['query_Burr_[Picross magic]']={
        {sp=422,col=14,'MY TAUNT IS ALL I NEED TO KEEP ENEMIES AT BAY!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Burr_[monster generals]']={
        {sp=422,col=14,'I\'M SCARED OF THEM! THEY\'RE SO POWERFUL!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Burr_[giant mushroom]']={
        {sp=422,col=14,'I DON\'T WANNA CROSS PATHS WITH THEM!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Burr_[quest]']={
        {sp=422,col=14,'QUESTS?! I ALREADY HAVE MY HANDS FULL STAYING SANE HERE!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Hidaldi_[you]']={
        {sp=416,col=0,'I wield the powers of ice and fire.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Hidaldi_[giant mushroom]']={
        {sp=416,col=0,'They\'re not the boss of me, I don\'t take orders from no icky mushroom.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Hidaldi_[monster generals]']={
        {sp=416,col=0,'Hmm, I think they could benefit from my fire magic...'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Hidaldi_[Picross magic]']={
        {sp=416,col=0,'I keep my most powerful spell hidden until there\'s an emergency.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Hidaldi_[quest]']={
        {f=function() 
            if cur_encounter==encounters['47:46'] then
                diag_db['query_Hidaldi_[quest]'][2][1]='I\'m looking for someone to team up with!'
            elseif cur_encounter==encounters['56:37'] then
                diag_db['query_Hidaldi_[quest]'][2][1]='Now that I\'ve teamed up, my quest is complete.'
            end   
        end},
        {sp=416,col=0,''},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Mimic']={
        {sp=93,col=2,'Hmmmmm, breaking character a little here.'},
        {sp=93,col=2,'You must be wondering what\'s in the other two encounters, hmmmm?'},
        {sp=93,col=2,'Maybe if you find a secret you\'ll get there hmmmmmm...'},
        {sp=93,col=2,'...But I\'ll give you a hint: you won\'t like what lurks there.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Sheebly_[you]']={
        {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'I\'m the blue mushroom, Sheebly! I don\'t need no introduction.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Shoobly_[you]']={
        {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'I\'m the yellow mushroom, Shoobly! I won\'t lose to you!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Shaably_[you]']={
        {sp=374,col=2,'I\'m the red mushroom, Shaably! My enemies fear me!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Sheebly_[Picross magic]']={
        {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, '[Picross magic] allows me to Leech! It makes me feel a surge of power!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Shoobly_[Picross magic]']={
        {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'My Poison magic is unrivalled in its efficiency!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Shaably_[Picross magic]']={
        {sp=374,col=2,'I\'ll Spore you up!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Sheebly_[monster generals]']={
        {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'They\'re the backbone of our monster army!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Shoobly_[monster generals]']={
        {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'Nobody can take on the [monster generals] and survive!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Shaably_[monster generals]']={
        {sp=374,col=2,'Without them, where would we be? Just waiting for someone to beat us up?'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Sheebly_[giant mushroom]']={
        {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Ooh, the General! I adore him! Maybe one day I\'ll grow as big as him!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Shoobly_[giant mushroom]']={
        {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'He uses Poison magic really creatively! It\'s exquisite!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Shaably_[giant mushroom]']={
        {sp=374,col=2,'Only us shrooms know how to reach the General!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Sheebly_[quest]']={
        {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'My [quest]? Right now it\'s to Leech you dry!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Shoobly_[quest]']={
        {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'I just want to be useful to the General.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Shaably_[quest]']={
        {sp=374,col=2,'As much as I like sharing with Sheebly and Shoobly, maybe a house of my own would be nice.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Maneki_[quest]']={
        {sp=368,col=2,'To get 999999999 gold!!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Maneki_[monster generals]']={
        {sp=368,col=2,'It\'s really peaceful in this dungeon because there\'s no generals bossing us around.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Maneki_[giant mushroom]']={
        {sp=368,col=2,'It ain\'t in this dungeon, that\'s for sure!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Maneki_[Picross magic]']={
        {sp=368,col=2,'I wonder if I\'ll be able to buy some magic!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Maneki_[you]']={
        {sp=368,col=2,'I\'m just a cat born under a lucky star!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_MunSlime_[you]']={
        {sp=326,col=6,'My existence is slime.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_MunSlime_[Picross magic]']={
        {sp=326,col=6,'I don\'t need magic, I\'ve got a nasty bite!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_MunSlime_[giant mushroom]']={
        {sp=326,col=6,'I wanna take a bite out of him!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_MunSlime_[monster generals]']={
        {sp=326,col=6,'Bah, they\'re overrated.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_MunSlime_[quest]']={
        {sp=326,col=6,'One day I will devour the world!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Rival_[quest]']={
        {sp=269,'I won\'t settle for small dreams! I want to become one of the [monster generals]!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Rival_[monster generals]']={
        {sp=269,'They\'re small fry compared to me! Hah!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Rival_[you]']={
        {sp=269,'I\'m the best and you know it!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Rival_[Picross magic]']={
        {sp=269,'Magic is awesome and I\'ll do everything to become the best at it!'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['query_Rival_[giant mushroom]']={
        {sp=269,'I think I saw a glimpse of it outside.'},
        {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
    },
    ['sc_2_bosstest']={
        {sp=41,'Uaaargh!'},
        {f=function() clip(); TIC=turn end},
    },
    ['boss1_weakest']={
        {sp=41,'THE WEAKEST MUST GO!'},
        {f=function() clip(); TIC=turn_boss end},
    },
    ['boss1_win']={
        {sp=41,'IMPOSSIBLE!'},
        {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end,'My General, surely this is only a temporary setback!'},
        {sp=374,col=2,'Oh no! I\'m already feeling the aura of this area collapse!'},
        {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Nobody panic!'},
        {f=function() clip(); endtime=time(); sc_t=t+1; TIC=endofdemo  end},
    },
}

