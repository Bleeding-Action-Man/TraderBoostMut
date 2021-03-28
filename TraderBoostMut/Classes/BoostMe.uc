Class BoostMe extends Info Config(TraderBoostMut);

var() config int iSpeedBoost, iAfterWaveStartBoost, iMatchStartBoost;
var() config string sMatchStartBoostMessage, sTraderBoostMessage, sBoostEndMessage;
var() config bool bGlobalMSG;

var bool bIsBoostActive;
var KFGameType KFGT;
var GameReplicationInfo GRI;

function PostBeginPlay()
{
  KFGT = KFGameType(Level.Game);
  GRI = Level.Game.GameReplicationInfo;

  Instigator.Health = iSpeedBoost; // Value affects groundspeed
  bIsBoostActive = True; // Marker for boost is active

  // Start Speed Boost Timer
  if ( GRI != none)
  {
    if (GRI.ElapsedTime < 10)
    {
      // Match Start Boost
      if (bGlobalMSG) class'TraderBoostMut'.default.Mut.CriticalServerMessage(sMatchStartBoostMessage);
      else class'TraderBoostMut'.default.Mut.ServerMessage(sMatchStartBoostMessage);
      SetTimer(iMatchStartBoost, false); // Recommended 10 seconds is for wave start countdown
    }
    else
    {
      // Trader Time Boost
      if (bGlobalMSG) class'TraderBoostMut'.default.Mut.CriticalServerMessage(sTraderBoostMessage);
      else class'TraderBoostMut'.default.Mut.ServerMessage(sTraderBoostMessage);
      SetTimer(KFGT.TimeBetweenWaves + iAfterWaveStartBoost, false);
    }
  }
}

function Timer()
{
  if (bGlobalMSG) class'TraderBoostMut'.default.Mut.CriticalServerMessage(sBoostEndMessage);
  else class'TraderBoostMut'.default.Mut.ServerMessage(sBoostEndMessage);
  Destroy();
}

function Tick( float Delta )
{
  if ((KFGT.bWaveInProgress && bIsBoostActive) || KFGT.IsInState('PendingMatch') || KFGT.IsInState('GameEnded'))
  {
    if (bGlobalMSG) class'TraderBoostMut'.default.Mut.CriticalServerMessage(sBoostEndMessage);
    else class'TraderBoostMut'.default.Mut.ServerMessage(sBoostEndMessage);
    Disable('Timer');
    Destroy();
  }
  if (Instigator==None || Instigator.Health <= 0)
    {
      Disable('Timer');
      Destroy();
    }
}

function Destroyed()
{
  if (Instigator != None) Instigator.Health = Min(Instigator.Health, 100);
  bIsBoostActive = False;
}

