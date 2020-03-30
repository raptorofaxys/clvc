import processing.serial.*;

boolean appFullScreen = false;
boolean appTouchScreen = false;
boolean appSmooth = true;

UIButton b1, b2, b3, b4;
UIGraph GraphPressure, GraphFlow, GraphVolume;
UITrackBar TrackBar;
UIElement InfoPanel;
UIGroup RootGroup, MainGroup, DataGroup, GraphGroup, SettingsGroup, RightGroup;
PFont fontText, fontNumbers;

Serial port;
long lastSendMs;

void settings()
{
  if (appFullScreen)
    fullScreen(P2D);
  else
    size(832, 520, P2D);

  if (appSmooth)
    smooth();
  else
    noSmooth();
}

void setup()
{
  surface.setResizable(true);
  frameRate(60);
  background(0);

  if (appTouchScreen)
  {
    noCursor();
  }

  fontText = loadFont("SegoeUI_Bold_64.vlw");
  fontNumbers = loadFont("SegoeUI_Semilight_64.vlw");

  TrackBar = new UITrackBar(1.0, 1.0);
  InfoPanel = new UIElement(0.2, 1.0);
  b1 = new UIButton(0.2, 1.0);
  b2 = new UIButton(0.2, 1.0);
  b3 = new UIButton(0.2, 1.0);
  b4 = new UIButton(0.2, 1.0);
  GraphPressure = new UIGraph(1.0, 1.0, 512, -1, 30, #ffbb00);
  GraphFlow = new UIGraph(1.0, 1.0, 512, -100.0, 100.0, #00ff99);
  GraphVolume = new UIGraph(1.0, 1.0, 512, -40.0, 800.0, #0099ff);

  GraphGroup = new UIVerticalFracGroup(0.8, 1.0, new UIElement[] {GraphPressure, GraphFlow, GraphVolume});
  DataGroup = new UIHorizontalFracGroup(1.0, 0.8, new UIElement[] {GraphGroup, InfoPanel});
  SettingsGroup = new UIHorizontalFracGroup(1.0, 0.2, new UIElement[] {b1, b2, b3, b4});
  MainGroup = new UIVerticalFracGroup(0.9, 1.0, new UIElement[] {DataGroup, SettingsGroup});
  RightGroup = new UIVerticalFracGroup(0.1, 1.0, new UIElement[] {TrackBar});
  RootGroup = new UIHorizontalFracGroup(0, 0, width, height, new UIElement[] {MainGroup, RightGroup});

  //port = new Serial(this, "COM7", 9600); // Change this to the name of your own com port - might need UI for this
}

void draw()
{
  Update();
  Render();
}

void Update()
{
  //* For testing resizable window with the lack of a proper resize event
  if (!appFullScreen)
  {
    RootGroup.Transform.SetWH(width, height);
    RootGroup.UpdateChildrenLayout();
  }
  //*/
  RootGroup.Update();

  UpdateSerial();

  float fakeVal1 = noise(millis() * 0.001) * 2.0 * 14.0 + 5.0;
  GraphPressure.SetValue(fakeVal1);
  float fakeVal2 = (sin(millis() * TWO_PI * 0.00033) + noise(millis() * 0.002) - 0.5) * 0.5;
  GraphFlow.SetValue(fakeVal2 * 60.0);
  GraphVolume.SetValue(max(0, fakeVal2 * 500.0));
}

void Render()
{
  background(0);
  RootGroup.Render();
  // noStroke();
  // fill(#ff0000);
  //rect(0, height - 100, 180, 2);
  textAlign(CENTER);
  fill(100);
  textFont(fontText, 24);
  text("PEEP", 90, height - 90);
  fill(255);
  textFont(fontNumbers, 64);
  text("12.6", 90, height - 28);
}

void UpdateSerial()
{
  if (port == null)
  {
    return;
  }

  int size = MachineState.GetSerializedSize();
  if (port.available() >= size)
  {
    byte[] bytes = port.readBytes(size);

    MachineState ms = MachineState.Deserialize(bytes);

    println(ms.InhalationPressure);
    println(ms.InhalationFlow);
    println(ms.ExhalationPressure);
    println(ms.ExhalationFlow);
    println(ms.O2ValveAngle);
    println(ms.AirValveAngle);
    println(ms.TotalFlowLitersPerMin);
    println(ms.MinuteVentilationLitersPerMin);
    println(ms.RespiratoryFrequencyBreathsPerMin);
    println(ms.InhalationTidalVolume);
    println(ms.ExhalationTidalVolume);
    println(ms.PressurePeak);
    println(ms.PressurePlateau);
    println(ms.PressurePeep);
    println(ms.IERatio);
    println(ms.LastReceiveValid != 0);
    println(ms.SerializedHash);
    println(ms.ComputedHash);
    println(ms.IsValid());
  }

  long nowMs = millis();
  if (nowMs - lastSendMs > 1000)
  {
    UIState us = new UIState();
    byte[] packet = us.Serialize();

    port.write(packet);

    lastSendMs = nowMs;
  }
}
