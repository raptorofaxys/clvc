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

UIState uiState = new UIState();

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

  UIElement text1, text2, btg, og1;

  TrackBar = new UITrackBar(1.0, 1.0);
  InfoPanel = new UIElement(0.2, 1.0);

  b1 = new UIButton(0.2, 1.0);
  text1 = new UIText(1.0, 40, "PEEP", fontText, 24, 100, CENTER, CENTER);
  text2 = new UIText(1.0, 60, "12.6", fontNumbers, 64, 255, CENTER, TOP);
  btg = new UIVerticalFracGroup(1.0, 1.0, new UIElement[] {text1, text2});
  og1 = new UIOverlappingGroup(0.2, 1.0, new UIElement[] {b1, btg});
  b2 = new UIButton(0.2, 1.0);
  b3 = new UIButton(0.2, 1.0);
  b4 = new UIButton(0.2, 1.0);

  GraphPressure = new UIGraph(1.0, 1.0, 512, -1, 30, #ffbb00);
  GraphFlow = new UIGraph(1.0, 1.0, 512, -100.0, 100.0, #00ff99);
  GraphVolume = new UIGraph(1.0, 1.0, 512, -40.0, 800.0, #0099ff);
  GraphGroup = new UIVerticalFracGroup(0.8, 1.0, new UIElement[] {GraphPressure, GraphFlow, GraphVolume});

  DataGroup = new UIHorizontalFracGroup(1.0, 0.8, new UIElement[] {GraphGroup, InfoPanel});
  SettingsGroup = new UIHorizontalFracGroup(1.0, 0.2, new UIElement[] {og1, b2, b3, b4});
  MainGroup = new UIVerticalFracGroup(0.9, 1.0, new UIElement[] {DataGroup, SettingsGroup});
  RightGroup = new UIVerticalFracGroup(0.1, 1.0, new UIElement[] {TrackBar});
  RootGroup = new UIHorizontalFracGroup(0, 0, width, height, new UIElement[] {MainGroup, RightGroup});

  //port = new Serial(this, "COM7", 115200); // Change this to the name of your own com port - might need UI for this
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
  float fakeVal2 = (sin(millis() * TWO_PI * 0.00033) + noise(millis() * 0.002) - 0.5) * 0.5;
  
  if (port == null)
  {
    GraphPressure.SetValue(fakeVal1);
    GraphFlow.SetValue(fakeVal2 * 60.0);
    GraphVolume.SetValue(max(0, fakeVal2 * 500.0));
  }
}

void Render()
{
  background(0);
  RootGroup.Render();
}

void UpdateSerial()
{
  if (port == null)
  {
    return;
  }

  int size = MachineState.GetSerializedSize();
  while (port.available() >= size)
  {
    byte[] bytes = port.readBytes(size);

    MachineState ms = MachineState.Deserialize(bytes);

    println("-----");
    println("ms.InhalationPressure: " + ms.InhalationPressure);
    println("Target pressure: " + ms.Debug3);

    println("Error: " + ms.Debug1);
    println("Error rate: " + ms.Debug4);
    println("Correction: " + ms.Debug2);
    println("CorrectionP: " + ms.Debug5);
    println("CorrectionD: " + ms.Debug6);

    println("ms.O2ValveOpening: " + ms.O2ValveOpening);
    println("ms.AirValveOpening: " + ms.AirValveOpening);
    // println("Raws UI recv/s: " + ms.RawUIMessagesPerSecond);
    // println("Valid UI recv/s: " + ms.ValidUIMessagesPerSecond);
    // println("Send/s: " + ms.MachineStateMessagesPerSecond);
    // println("MCU last received valid: " + ms.LastReceiveValid);
    // println("ms.TotalFlowLitersPerMin: " + ms.TotalFlowLitersPerMin);
    println("MCU error mask: " + Integer.toHexString(ms.ErrorMask));
    println("Is valid: " + ms.IsValid());

    if (ms.IsValid())
    {
      GraphPressure.SetValue(ms.InhalationPressure);
      GraphFlow.SetValue(ms.Debug3);
      GraphVolume.SetValue((ms.O2ValveOpening + ms.AirValveOpening) * 300.0f);
    }
    else
    {
      // Flush the port and try to wait for the next packet
      while (port.available() > 0)
      {
        port.read();
      }
    }
  }

  long nowMs = millis();
  if (nowMs - lastSendMs > 33)
  {
    uiState.FiO2 = 0.3f;
    uiState.ControlMode = 1;
    uiState.PressureControlInspiratoryPressure = 15.0f;
    uiState.VolumeControlMaxPressure = 25.0f;
    uiState.VolumeControlTidalVolume = 0.450f;
    uiState.Peep = 5.0f;
    uiState.InspirationTime = 1.0f;
    uiState.InspirationFilterRate = 0.01f;
    uiState.ExpirationFilterRate = 0.02f;
    uiState.TriggerMode = 1;
    uiState.TimerTriggerBreathsPerMin = 20;
    uiState.PatientEffortTriggerMinBreathsPerMin = 8;
    uiState.PatientEffortTriggerLitersPerMin = 2.5f;

    byte[] packet = uiState.Serialize();
    port.write(packet);

    uiState.ResetEvents();

    lastSendMs = nowMs;
  }
}

void keyPressed()
{
  if (key == 'b')
  {
    uiState.TriggerBreath();
  }
}
