import processing.serial.*;

boolean appFullScreen = false;
boolean appTouchScreen = false;
boolean appSmooth = true;

UIButton b1, b2, b3, b4;
UIControlButton controlFiO2, controlPEEP, controlRR, controlVT, controlIP;
UIGraph graphPressure, graphFlow, graphVolume;
UIInfoText infoPPeak, infoPMean, infoPEEP, infoRR, infoIE, infoMVe, infoVTi, infoVTe;
UITrackBar trackBar;
UIElement infoPanel;
UIGroup runtimeGroup, mainGroup, dataGroup, graphGroup, settingsGroup, rightGroup;

PFont fontText, fontNumbers;
color colorPressure = #ffbb00;
color colorFlow = #00ff99;
color colorVolume = #0099ff;

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

  UIElement text1, text2, text3, text4, btg, og1;

  trackBar = new UITrackBar(1.0, 1.0);

  controlFiO2 = new UIControlButton(1.0, 1.0, "FiO2");
  controlPEEP = new UIControlButton(1.0, 1.0, "PEEP");
  controlRR = new UIControlButton(1.0, 1.0, "Resp. Rate");
  controlIP = new UIControlButton(1.0, 1.0, "Insp. Pressure");

  // Graphs
  graphPressure = new UIGraph(1.0, 1.0, 512, -1, 30, #ffbb00);
  graphFlow = new UIGraph(1.0, 1.0, 512, -100.0, 100.0, #00ff99);
  graphVolume = new UIGraph(1.0, 1.0, 512, -40.0, 800.0, #0099ff);
  graphGroup = new UIVerticalFracGroup(0.8, 1.0, new UIElement[] {graphPressure, graphFlow, graphVolume});

  // Info Panel
  infoPPeak = new UIInfoText(1.0, 1.0, "PPeak", colorPressure);
  infoPMean = new UIInfoText(1.0, 1.0, "PMean", colorPressure);
  infoPEEP = new UIInfoText(1.0, 1.0, "PEEP", colorPressure);
  infoRR = new UIInfoText(1.0, 1.0, "Resp Rate", colorFlow);
  infoIE = new UIInfoText(1.0, 1.0, "I:E", colorFlow);
  infoMVe = new UIInfoText(1.0, 1.0, "MVe", colorVolume);
  infoVTi = new UIInfoText(1.0, 1.0, "VTi", colorVolume);
  infoVTe = new UIInfoText(1.0, 1.0, "VTe", colorVolume);
  infoPanel = new UIVerticalFracGroup(0.2, 1.0, new UIElement[] {infoPPeak, infoPMean, infoPEEP, infoRR, infoIE, infoMVe, infoVTi, infoVTe});

  dataGroup = new UIHorizontalFracGroup(1.0, 0.8, new UIElement[] {graphGroup, infoPanel});
  settingsGroup = new UIHorizontalFracGroup(1.0, 0.2, new UIElement[] {controlFiO2, controlPEEP, controlRR, controlIP});
  mainGroup = new UIVerticalFracGroup(0.9, 1.0, new UIElement[] {dataGroup, settingsGroup});
  rightGroup = new UIVerticalFracGroup(0.1, 1.0, new UIElement[] {trackBar});
  runtimeGroup = new UIHorizontalFracGroup(0, 0, width, height, new UIElement[] {mainGroup, rightGroup});

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
    runtimeGroup.Transform.SetWH(width, height);
    runtimeGroup.UpdateChildrenLayout();
  }
  //*/
  runtimeGroup.Update();

  UpdateSerial();

  float fakeVal1 = noise(millis() * 0.001) * 2.0 * 14.0 + 5.0;
  float fakeVal2 = (sin(millis() * TWO_PI * 0.00033) + noise(millis() * 0.002) - 0.5) * 0.5;

  if (port == null)
  {
    graphPressure.SetValue(fakeVal1);
    graphFlow.SetValue(fakeVal2 * 60.0);
    graphVolume.SetValue(max(0, fakeVal2 * 500.0));
  }
}

void Render()
{
  background(0);
  runtimeGroup.Render();
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
      graphPressure.SetValue(ms.InhalationPressure);
      graphFlow.SetValue(ms.Debug3);
      graphVolume.SetValue((ms.O2ValveOpening + ms.AirValveOpening) * 300.0f);
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
