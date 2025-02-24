// ------------------------------------------------------------
// Melee Zombie, want to kill fast but bullets too slow
//   ------------------------------------------------------------
class MeleeZombie:UndeadHomeboy{
	
    override void postbeginplay(){
		super.postbeginplay();
   
		bhasdropped=false;

	thismag=0;
	chamber=0;
	firemode=-1;
	}

	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Melee Zombie"
		//$Sprite "POSSA1"

		seesound "meleezombie/sight";
		painsound "meleezombie/pain";
		deathsound "meleezombie/death";
		activesound "meleezombie/active";
		meleesound "meleezombie/bite";
		hdmobbase.stepsound "meleezombie/step";
		hdmobbase.stepsoundwet "meleezombie/wormstep";
		
		tag "melee zombie";
        
        	+ambush
		-nodropoff
		+SLIDESONWALLS

        	scale 1.2;
		radius 10;
		speed 3;
		mass 100;
		painchance 200;
		obituary "%o became zombie chow.";
		hitobituary "%o became zombie chow.";
	}

override void deathdrop(){}

	states{
	spawn:
		ZOMB F 1{
			A_HDLook();
			//A_Recoil(frandom(-0.1,0.1));
		}
		#### FFF random(5,17) A_HDLook();
		#### F 1{
			//A_Recoil(frandom(-0.1,0.1));
			A_SetTics(random(10,40));
		}
		#### B 0 A_Jump(28,"spawngrunt");
		#### B 0 A_Jump(132,"spawnswitch");
		#### B 8 A_Recoil(frandom(-0.2,0.2));
		loop;
	spawngrunt:
		ZOMB G 1{
			//A_Recoil(frandom(-0.4,0.4));
			A_SetTics(random(30,80));
			//if(!random(0,7))A_Vocalize(activesound);
		}
		#### A 0 A_Jump(256,"spawn");
	spawnswitch:
		#### A 0 A_JumpIf(bambush,"spawnstill");
		goto spawnwander;
	spawnstill:
		#### A 0 A_Look();
		//#### A 0 A_Recoil(random(-1,1)*0.4);
		#### CD 5 A_SetAngle(angle+random(-4,4));
		#### A 0{
			A_Look();
			//if(!random(0,127))A_Vocalize(activesound);
		}
		#### AB 5 A_SetAngle(angle+random(-4,4));
		#### B 1 A_SetTics(random(10,40));
		#### A 0 A_Jump(256,"spawn");
	spawnwander:
		#### CDAB 5 A_HDWander();
		#### A 0 A_Jump(64,"spawn");
		loop;

	see:
		#### ABCD random(9,10) A_HDChase();
		loop;

    missile://lunge code borrowed from babuin latch attack 
		#### ABCD 8{
			A_FaceTarget(16,16);
			bnodropoff=false;
			A_Changevelocity(1,0,0,CVF_RELATIVE);
			if(A_JumpIfTargetInLOS("null",20,0,128)){
				//A_Vocalize(seesound);
				setstatelabel("hunger");
			}
		}
		---- A 0 setstatelabel("see");
	hunger:
	    #### FFEE 3 A_HDChase();
		---- A 0 setstatelabel("missile");

    meleehead://zombie bite attack
    	#### FE 3;
		#### G 5 {
			pitch+=frandom(-40,-8);
			A_HumanoidMeleeAttack(height*0.7);
			A_CustomMeleeAttack(random(20,40),meleesound,"","teeth",true);
		}
		#### EF 3;
		#### A 0 setstatelabel("meleeend");

	pain:
		ZOMB G 2;
		#### G 3 A_Vocalize(painsound);
		#### G 0{
			A_ShoutAlert(0.1,SAF_SILENT);
			if(
				floorz==pos.z
				&&target
				&&(
					!random(0,4)
					||distance3d(target)<128
				)
			){
				double ato=angleto(target)+randompick(-90,90);
				vel+=((cos(ato),sin(ato))*speed,1.);
				setstatelabel("missile");
			}else bfrightened=true;
		}
		#### ABCD 2 A_HDChase();
		#### G 0{bfrightened=false;}
		---- A 0 setstatelabel("see");
	death:
		#### H 5;
		#### I 5 A_Vocalize(deathsound);
		#### J 5 A_NoBlocking();
		#### K 5;
	dead:
		#### L 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### M 5 canraise{if(abs(vel.z)>=2.)setstatelabel("dead");}
		wait;
	xxxdeath:
		POSS L 5;
		#### M 5{
			spawn("MegaBloodSplatter",pos+(0,0,34),ALLOW_REPLACE);
			A_XScream();
		}
		#### OPQRST 5;
		goto xdead;
	xdeath:
		POSS L 5;
		#### M 5{
			spawn("MegaBloodSplatter",pos+(0,0,34),ALLOW_REPLACE);
			A_XScream();
		}
		#### O 0 A_NoBlocking();
		#### OP 5 spawn("MegaBloodSplatter",pos+(0,0,34),ALLOW_REPLACE);
		#### QRST 5;
		goto xdead;
	xdead:
		POSS T 3 canraise{if(abs(vel.z)<2.)frame++;}
		#### U 5 canraise A_JumpIf(abs(vel.z)>=2.,"xdead");
		wait;
	raise:
		ZOMB L 4;
		#### LK 6;
		#### JIH 4;
		#### A 0 A_Jump(256,"see");
	ungib:
		POSS U 12;
		#### T 8;
		#### SRQ 6;
		#### PONM 4;
		ZOMB A 0 A_Jump(256,"see");
	}

}
