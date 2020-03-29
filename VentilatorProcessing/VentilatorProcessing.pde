import processing.serial.*;

boolean appFullScreen = false;
boolean appTouchScreen = false;
boolean appSmooth = false;

UIButton b1, b2, b3, b4;
UIGraph graphPressure, graphFlow, graphVolume;
UITrackBar TrackBar;
UIGroup RootGroup, MainGroup, GraphGroup, SettingsGroup, RightGroup;
PFont fontText, fontNumbers;

Serial port;
long lastSendMs;

void settings()
{
  if (appFullScreen)
    fullScreen(P2D);
  else
    size(800, 600, P2D);

  if (appSmooth)
    smooth();
  else
    noSmooth();
}

void setup()
{
  surface.setResizable(true);
  background(0);

  if (appTouchScreen)
  {
    noCursor();
  }

  fontText = loadFont("SegoeUI_Bold_48.vlw");
  fontNumbers = loadFont("Monospaced_64.vlw");

  TrackBar = new UITrackBar(1.0, 1.0);
  b1 = new UIButton(0.2, 1.0);
  b2 = new UIButton(0.2, 1.0);
  b3 = new UIButton(0.2, 1.0);
  b4 = new UIButton(0.2, 1.0);
  graphPressure = new UIGraph(1.0, 1.0, 512, 0.0);
  graphFlow = new UIGraph(1.0, 1.0, 512, 0.0);
  graphVolume = new UIGraph(1.0, 1.0, 512, 0.0);

  GraphGroup = new UIVerticalFracGroup(1.0, 0.8, new UIElement[] {graphPressure, graphFlow, graphVolume});
  SettingsGroup = new UIHorizontalFracGroup(1.0, 0.2, new UIElement[] {b1, b2, b3, b4});
  MainGroup = new UIVerticalFracGroup(0.85, 1.0, new UIElement[] {GraphGroup, SettingsGroup});

  RightGroup = new UIVerticalFracGroup(0.15, 1.0, new UIElement[] {TrackBar});

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
  //*
  // For testing resizable window with the lack of a proper resize event
  if (!appFullScreen)
  {
    RootGroup.Transform.SetWH(width, height);
    RootGroup.UpdateChildrenLayout();
  }
  //*/
  RootGroup.Update();

  UpdateSerial();
}

void Render()
{
  background(0);
  RootGroup.Render();
  textFont(fontText, 48);
  text("PEEP", 10, 50);
  textFont(fontNumbers, 64);
  text("12.6", 10, 100);
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
    println(ms.LastReceiveValid);
    println(ms.SerializedHash);
    println(ms.ComputedHash);
    println(ms.IsValid());
  }

  long nowMs = millis();
  if (nowMs - lastSendMs > 1000)
  {
    UIState us = new UIState();
    us.P1 = 1.0f;
    us.P2 = 2.0f;
    byte[] packet = us.Serialize();

    port.write(packet);

    lastSendMs = nowMs;
  }
}