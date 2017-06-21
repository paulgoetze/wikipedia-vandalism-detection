module Wikipedia
  module VandalismDetection
    module WordLists
      # This list is taken from https://github.com/snipe/banbuilder and can be
      # downloaded from:
      # https //:github.com/snipe/banbuilder/blob/master/word-dbs/wordlist.csv
      VULGARISM = %i[
        $#!+ $1ut $h1t $hit $lut 'ho 'hobag a$$ anus ass assmunch b1tch
        ballsack bastard beaner beastiality biatch beeyotch bitchy
        blow blowjob bollock bollocks bollok boner boob bugger buttplug
        c-0-c-k c-o-c-k c-u-n-t c.0.c.k c.o.c.k. c.u.n. jerk jackoff
        jackhole j3rk0ff homo hom0 hobag hell h0mo h0m0 goddamn goddammit
        godamnit ghey ghay gfy gay fudgepacker fuckwad fucktard fuckoff
        fucker fuck-tard fuck fellatio fellate felching felcher felch
        fartknocker fart fannybandit fanny faggot fagg fag f.u.c.k f-u-c-k
        dyke douchebag douche douch3 doosh dike dick damnit damn dammit d1ldo
        d1ld0 d1ck d0uche d0uch3 cunt cumstain cum crap coon cock clitoris
        clit cl1t cawk c0ck jerk0ff jerkoff jizz knobend labia lmfao moolie
        muff nigga nigger p.u.s.s.y. piss piss-off pissoff prick pube pussy
        queer retard retarded s-h-1-t s-h-i-t s.h.i.t. scrotum sh1t shit slut
        smegma t1t tard terd tit tits titties turd twat vag wank wetback
        whore whoreface 'f*ck' sh*t pu$$y p*ssy diligaf wtf stfu fu*ck fack
        shite fxck sh!t @sshole assh0le assho!e a$$hole a$$h0le a$$h0!e
        a$$h01e assho1e wh0re f@g f@gg0t f@ggot motherf*cker mofo cuntlicker
        cuntface dickbag cockknocker beatch fucknut nucking futs mams cunny
        quim clitty kike spic wop chink humper feltch feltcher fvck ahole
        nads spick douchey bullturds gonads bitch butt fellatio lmao s-o-b
        spunk he11 jizm jism bukkake shiz wigger gook ritard reetard
        masterbate masturbate goatse masterbating masturbating hitler nazi
        tubgirl gtfo foad r-tard rtard hoor g-spot gspot vulva assmaster
        viagra phuck frack fuckwit assbang assbanged assbangs asshole
        assholes asswipe asswipes b1tch bastards bitched bitches boners
        bullshit bullshits bullshitted cameltoe chinc chincs chink chode
        chodes clit clits cocks coons cumming cunts d1ck dickhead dickheads
        doggie-style douchebags dumass dumbass dumbasses dykes faggit fags
        fucked fucker fuckface fucks godamnit gooks humped humping jackass
        jap japs jerk jizzed kikes knobend kooch kooches kootch fuckers
        motherfucking niggah niggas niggers p.u.s.s.y. pussies queers rim s0b
        shitface shithead shits shitted s.o.b. spik spiks twats whack whores
        zoophile m-fucking mthrfucking muthrfucking mutherfucking
        mutherfucker mtherfucker mthrfucker mthrf*cker whorehopper copulator
        whoralicious whorealicious aeolus analprobe areola areole aryan arian
        asses assfuck azazel baal babes bang banger barf bawdy beardedclam
        beater beaver beer bigtits bimbo blew blow blowjobs blowup bod bodily
        boink bone boned bong boobies boobs booby booger bookie booky bootee
        bootie booty booze boozer boozy bosom bosomy bowel bowels bra
        brassiere bung babe bush buttfuck cocaine kinky klan panties
        pedophile pedophilia pedophiliac punkass queaf rape scantily essohbee
        shithouse smut snatch toots doggie anorexia bulimia bulimiic burp
        busty buttfucker caca cahone carnal carpetmuncher cervix climax
        cocain cocksucker coital coke commie condom corpse coven crabs crack
        crackwhore crappy cuervo cummin cumshot cumshots cunnilingus dago
        dagos damned dick-ish dickish dickweed anorexic prostitute marijuana
        lsd pcp diddle dawgie-style dimwit dingle doofus dopey douche drunk
        dummy ejaculate enlargement erect erotic exotic extacy extasy faerie
        faery fagged fagot fairy fisted fisting fisty floozy fondle foobar
        foreskin frigg frigga fubar fucking fuckup ganja gays glans godamn
        goddam goldenshower gonad gonads handjob hebe hemp heroin herpes
        hijack hiv homey honky hooch hookah hooker hootch hooter hooters hump
        hussy hymen inbred incest injun jerked jiz jizm horny junkie junky
        kill kkk kraut kyke lech leper lesbians lesbos lez lezbian lezbians
        lezbo lezbos lezzie lezzies lezzy loin loins lube lust lusty massa
        masterbation masturbation maxi menses menstruate menstruation meth
        molest moron motherfucka motherfucker murder muthafucker nad naked
        napalm nappy nazism negro niggle nimrod ninny nooky nympho opiate
        opium oral orally organ orgasm orgies orgy ovary ovum ovums paddy
        pantie panty pastie pasty pecker pedo pee peepee penetrate
        penetration penial penile perversion peyote phalli phallic
        pillowbiter pimp pinko pissed pms polack porn porno pornography pot
        potty prig prude pubic pubis punky puss queef queefing quife quicky
        racist racy raped raper rapist raunch rectal rectum rectus reefer
        reich revue risque rum rump sadism sadist satan scag schizo screw
        screwed scrog scrot scrote scrud scum seaman seamen seduce semen
        sex_story sexual shithole shitter shitty s*o*b sissy skag slave
        sleaze sleazy sluts smutty sniper snuff sodom souse soused sperm
        spooge stab steamy stiffy stoned strip stroke whacking suck sucked
        sucking tampon tawdry teat teste testee testes testis thrust thug
        tinkle titfuck titi titty whacked toke tramp trashy tush undies unwed
        urinal urine uterus uzi valium virgin vixen vodka vomit voyeur vulgar
        wad wazoo wedgie weed weenie weewee weiner weirdo wench whitey whiz
        whored whorehouse whoring womb woody x-rated xxx b@lls yeasty yobbo
        sumofabiatch doggy-style doggy wang dong d0ng w@ng wh0reface
        wh0ref@ce wh0r3f@ce tittyfuck tittyfucker tittiefucker cockholster
        cockblock gai gey faig faigt a55 a55hole gae corksucker rumprammer
        slutdumper niggaz muthafuckaz gigolo pussypounder herp herpy
        transsexual orgasmic cunilingus anilingus dickdipper dickwhipper
        dicksipper dickripper dickflipper dickzipper homoey queero freex
        cunthunter shamedame slutkiss shiteater fuckass fucka$$ clitorus
        assfucker assfuckers dillweed cracker teabagging shitt azz fuk
        fucknugget cuntlick g@y @ss beotch pussys 's***' paedophile
        pedophiles pedophile sucks licker lickers bitchface idiot tosser
        idiots tossers
      ].freeze
    end
  end
end
