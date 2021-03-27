//=============================================================================
// Gives all players a speed boost on trader time;
// Made by Vel-San @ https://steamcommunity.com/id/Vel-San/
//=============================================================================

class TraderBoostMut extends Mutator Config(TraderBoostMut);

// Tmp Vars
var bool isBoostActive;
var KFGameType KFGT;
var TraderBoostMut Mut;

// Colors from Config
struct ColorRecord
{
  var config string ColorName; // Color name, for comfort
  var config string ColorTag; // Color tag
  var config Color Color; // RGBA values
};
var() config array<ColorRecord> ColorList; // Color list

// Initialization
function PostBeginPlay()
{
  // Pointer To self, just in case needed
  Mut = self;
  default.Mut = self;
  class'TraderBoostMut'.default.Mut = self;

  isBoostActive = false;
  KFGT = KFGameType(Level.Game);

  if(KFGT == none) MutLog("-----|| KFGameType not found! ||-----");

  // Enable Tick
  Enable('Tick');
}

// Tick to Give Trader Speed Boost
// TODO: Maybe change from tick to something else? Not sure.
function Tick(float DeltaTime)
{
  if (!KFGT.bWaveInProgress && !KFGT.IsInState('PendingMatch') && !KFGT.IsInState('GameEnded'))
  {
    if(!isBoostActive) GiveTraderBoost();
  }
  else
  {
    isBoostActive = false;
  }
}

function ServerMessage(string Msg)
{
  local Controller C;
  local PlayerController PC;
  for (C = Level.ControllerList; C != none; C = C.nextController)
  {
    PC = PlayerController(C);
    if (PC != none)
    {
      SetColor(Msg);
      PC.ClientMessage(Msg);
    }
  }
}

function CriticalServerMessage(string Msg)
{
  local Controller C;
  local PlayerController PC;
  for (C = Level.ControllerList; C != none; C = C.nextController)
  {
    PC = PlayerController(C);
    if (PC != none)
    {
      SetColor(Msg);
      PC.ClientMessage(Msg, 'CriticalEvent');
    }
  }
}

function GiveTraderBoost()
{
  local Controller C;
  local PlayerController PC;


  MutLog("-----|| DEBUG - Trader Speed Boost Activated ||-----");

  isBoostActive = true;

  for (C = Level.ControllerList; C != none; C = C.nextController)
  {
    PC = PlayerController(C);
    if (PC != none && PC.Pawn != none) class'Boost'.Static.GiveBoost(PC.Pawn);
  }
}

function TimeStampLog(coerce string s)
{
  log("["$Level.TimeSeconds$"s]" @ s, 'SkipTrader');
}

function MutLog(string s)
{
  log(s, 'SkipTrader');
}

/////////////////////////////////////////////////////////////////////////
// BELOW SECTION IS CREDITED FOR NikC //

// Apply Color Tags To Message
function SetColor(out string Msg)
{
  local int i;
  for(i=0; i<ColorList.Length; i++)
  {
    if(ColorList[i].ColorTag!="" && InStr(Msg, ColorList[i].ColorTag)!=-1)
    {
      ReplaceText(Msg, ColorList[i].ColorTag, FormatTagToColorCode(ColorList[i].ColorTag, ColorList[i].Color));
    }
  }
}

// Format Color Tag to ColorCode
function string FormatTagToColorCode(string Tag, Color Clr)
{
  Tag=Class'GameInfo'.Static.MakeColorCode(Clr);
  Return Tag;
}

function string RemoveColor(string S)
{
  local int P;
  P=InStr(S,Chr(27));
  While(P>=0)
  {
    S=Left(S,P)$Mid(S,P+4);
    P=InStr(S,Chr(27));
  }
  Return S;
}
//////////////////////////////////////////////////////////////////////

defaultproperties
{
  // Mandatory Vars
  GroupName = "KF-TraderBoostMut"
  FriendlyName = "Trader Booster - v1.0"
  Description = "Gives all players a speed boost on trader time; Made by Vel-San /w help of Marco"
}
