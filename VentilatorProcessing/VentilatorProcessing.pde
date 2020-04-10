import processing.serial.*;

class App
{
  public final boolean FULLSCREEN = true;
  public final boolean TOUCH_SCREEN = false;
  public final boolean SMOOTH = true;
  public final boolean DEBUG = false;
  public final int FRAME_RATE = 60;
  public final int BASE_WIDTH = 960;
  public final int BASE_HEIGHT = 600;
  public final color COLOR_PRESSURE = #ffbb00;
  public final color COLOR_FLOW = #00ff99;
  public final color COLOR_VOLUME = #0099ff;

  private float _appHScale = 1f;
  private UIFont _fontBold = new UIFont();
  private UIFont _fontSemilight = new UIFont();

  public float GetHScale() { return _appHScale; }
  public void UpdateHScale() { _appHScale = (float)height / BASE_HEIGHT; }

  public PFont[] GetFontBold() { return _fontBold.GetFonts(); }
  public PFont[] GetFontSemilight() { return _fontSemilight.GetFonts(); }

  public void LoadFonts()
  {
    _fontBold.LoadFonts(new String[] {"SegoeUI_Bold_64.vlw", "SegoeUI_Bold_128.vlw"});
    _fontSemilight.LoadFonts(new String[] {"SegoeUI_Semilight_64.vlw", "SegoeUI_Semilight_128.vlw"});
  }
}
App app = new App();

UIMenuButton menuButton;
UIControlButton controlFiO2, controlPEEP, controlRR, controlInspTime, controlVT, controlIP;
UIGraph graphPressure, graphFlow, graphVolume;
UIInfoText infoPPeak, infoPMean, infoPPlat, infoPEEP, infoRR, infoIE, infoMVe, infoVTi, infoVTe;
UITrackBar trackBar;
UIGroup runtimeGroup, mainGroup, dataGroup, graphGroup, infoGroup, controlsGroup, rightGroup;

Serial port;
long lastSendMs;
UIState uiState = new UIState();

void settings()
{
  if (app.FULLSCREEN)
    fullScreen(P2D, 2);
  else
    size(app.BASE_WIDTH, app.BASE_HEIGHT, P2D);

  if (app.SMOOTH)
    smooth();
  else
    noSmooth();
}

void setup()
{
  surface.setResizable(true);
  frameRate(app.FRAME_RATE);
  background(0);
  app.UpdateHScale();
  app.LoadFonts();

  if (app.TOUCH_SCREEN)
  {
    noCursor();
  }


  UIElement text1, text2, text3, text4, btg, og1;

  final float kMaxPressure = 40.0;

  menuButton = new UIMenuButton(0.4, 1.0);
  controlFiO2 = new UIControlButton(1.0, 1.0, "FiO2", 21.0, 21.0, 100.0);
  controlPEEP = new UIControlButton(1.0, 1.0, "PEEP", 5.0, 0.0, kMaxPressure);
  controlRR = new UIControlButton(1.0, 1.0, "Resp. Rate", 15.0, 4.0, 30.0);
  controlInspTime = new UIControlButton(1.0, 1.0, "Insp. Time", 1.0, 0.5, 3.0, 1);
  controlIP = new UIControlButton(1.0, 1.0, "Insp. Pressure", 15.0, 0.0, kMaxPressure);
  controlsGroup = new UIHorizontalFracGroup(1.0, 0.2, new UIElement[] {menuButton, controlFiO2, controlPEEP, controlRR, controlInspTime, controlIP});
  UIRadioButtonSet controlButtons = new UIRadioButtonSet(new UIRadioButton[]
    {
      controlFiO2.GetRadioButton(),
      controlPEEP.GetRadioButton(),
      controlRR.GetRadioButton(),
      controlInspTime.GetRadioButton(),
      controlIP.GetRadioButton()
    }, 0);

  // Graphs
  graphPressure = new UIGraph(1.0, 1.0, 720, -2, 40.0, app.COLOR_PRESSURE);
  graphFlow = new UIGraph(1.0, 1.0, 720, -100.0, 100.0, app.COLOR_FLOW);
  graphVolume = new UIGraph(1.0, 1.0, 720, -0.04, 0.8, app.COLOR_VOLUME);
  graphGroup = new UIVerticalFracGroup(0.8, 1.0, new UIElement[] {graphPressure, graphFlow, graphVolume});

  // Info Panel
  infoPPeak = new UIInfoText(1.0, 1.0, "PPeak", app.COLOR_PRESSURE);
  infoPMean = new UIInfoText(1.0, 1.0, "PMean", app.COLOR_PRESSURE);
  infoPPlat = new UIInfoText(1.0, 1.0, "PPlat", app.COLOR_PRESSURE);
  infoPEEP = new UIInfoText(1.0, 1.0, "PEEP", app.COLOR_PRESSURE);
  infoRR = new UIInfoText(1.0, 1.0, "Resp Rate", app.COLOR_FLOW);
  infoIE = new UIInfoText(1.0, 1.0, "I:E", app.COLOR_FLOW, 1, "1:");
  infoMVe = new UIInfoText(1.0, 1.0, "MVe", app.COLOR_VOLUME, 1);
  infoVTi = new UIInfoText(1.0, 1.0, "VTi", app.COLOR_VOLUME);
  infoVTe = new UIInfoText(1.0, 1.0, "VTe", app.COLOR_VOLUME);
  infoGroup = new UIVerticalFracGroup(0.2, 1.0, new UIElement[] {infoPPeak, infoPMean, infoPPlat, infoPEEP, infoRR, infoIE, infoMVe, infoVTi, infoVTe});

  dataGroup = new UIHorizontalFracGroup(1.0, 0.8, new UIElement[] {graphGroup, infoGroup});

  mainGroup = new UIVerticalFracGroup(0.9, 1.0, new UIElement[] {dataGroup, controlsGroup});

  trackBar = new UITrackBar(1.0, 1.0, 1.0, controlButtons);
  rightGroup = new UIVerticalFracGroup(0.1, 1.0, new UIElement[] {trackBar});

  runtimeGroup = new UIHorizontalFracGroup(0, 0, width, height, new UIElement[] {mainGroup, rightGroup});

  // Put the port name you want to use in a file called "comport.txt" in this sketch's directory
  String portName = loadStrings("comport.txt")[0];
  port = new Serial(this, portName, 115200); // Change this to the name of your own com port - might need UI for this
}

void draw()
{
  Update();
  Render();
}

void Update()
{
  //* For testing resizable window with the lack of a proper resize event
  if (!app.FULLSCREEN)
  {
    runtimeGroup.Transform.SetWH(width, height);
    runtimeGroup.UpdateChildrenLayout();
    app.UpdateHScale();
  }
  //*/


  runtimeGroup.Update();

  UpdateSerial();

  if (port == null)
  {
    float fakeVal1 = noise(millis() * 0.001f) * 2.0f * 14.0f + 5.0f;
    float fakeVal2 = (sin(millis() * TWO_PI * 0.00033f) + noise(millis() * 0.002f) - 0.5f) * 0.5f;
    graphPressure.SetValue(fakeVal1);
    graphFlow.SetValue(fakeVal2 * 60.0f);
    graphVolume.SetValue(max(0f, fakeVal2 * 0.5f));
  }

  UIInteractiveUtils.Reset();
}

void Render()
{
  background(0);
  runtimeGroup.Render();
}

void mousePressed()
{
  UIInteractiveUtils.MousePress();
}

void mouseReleased()
{
  UIInteractiveUtils.MouseRelease();
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

    if (ms.IsValid())
    {
      if (app.DEBUG)
      {
        println("-----");
        println("ms.InhalationPressure: " + ms.InstantInhalationPressure);
        // println("Target pressure: " + ms.Debug3);

        // println("Tracking: " + ms.Debug1);
        // println("GasL: " + ms.Debug1);
        // println("FlowSlpm: " + ms.Debug2);
        // println("Backpressure: " + ms.Debug3);
        println("InstantTotalVolume: " + ms.InstantTotalVolume);
        // println("tracker flow: " + ms.Debug4);
        // println("_volume: " + ms.Debug3);
        // println("Gf3: " + ms.Debug4);
        // println("Gf4: " + ms.Debug5);

        // println("Error: " + ms.Debug1);
        // println("Error rate: " + ms.Debug4);
        // println("Correction: " + ms.Debug2);
        // println("CorrectionP: " + ms.Debug5);
        // println("CorrectionD: " + ms.Debug6);

        // println("insp time: " + ms.Debug1);
        // println("min insp time: " + ms.Debug2);
        // println("phase: " + ms.Debug7);

        //  println("ms.O2ValveOpening: " + ms.O2ValveOpening);
        // println("ms.AirValveOpening: " + ms.AirValveOpening);
        // println("Raws UI recv/s: " + ms.RawUIMessagesPerSecond);
        // println("Valid UI recv/s: " + ms.ValidUIMessagesPerSecond);
        // println("Send/s: " + ms.MachineStateMessagesPerSecond);
        // println("MCU last received valid: " + ms.LastReceiveValid);
        // println("ms.TotalFlowLitersPerMin: " + ms.TotalFlowLitersPerMin);
        // println("MCU error mask: " + Integer.toHexString(ms.ErrorMask));
        // println("Is valid: " + ms.IsValid());
      }

      infoPPeak.SetValue(ms.PressurePeak);
      infoPMean.SetValue(ms.PressureMean);
      infoPPlat.SetValue(ms.PressurePlateau);
      infoPEEP.SetValue(ms.PressurePeep);
      infoRR.SetValue(ms.RespiratoryFrequencyBreathsPerMin);
      infoIE.SetValue(ms.IERatio);
      infoMVe.SetValue(ms.MinuteExhalationLitersPerMin);
      infoVTi.SetValue(ms.InhalationTidalVolume * 1000.0f);
      infoVTe.SetValue(ms.ExhalationTidalVolume * 1000.0f);

      graphPressure.SetValue(ms.InstantInhalationPressure);
      graphPressure.SetBGColor(ms.InstantBreathPhase == 0 ? #282828 : #1E1E1E);
      // graphFlow.SetValue(ms.Debug1 * 100.0f);
      graphFlow.SetValue(ms.InstantTotalFlowLitersPerMin);
      graphVolume.SetValue(ms.InstantTotalVolume);

      // Correct the inspiration time as it is limited by the controller according to other constants
      if (ms.EffectiveInspirationTime < uiState.InspirationTime)
      {
        uiState.InspirationTime = ms.EffectiveInspirationTime;
        controlInspTime.SetValue(uiState.InspirationTime);
      }
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
    uiState.FiO2 = controlFiO2.GetValue() * 0.01f;
    uiState.ControlMode = 1;
    uiState.PressureControlInspiratoryPressure = controlIP.GetValue();
    // uiState.VolumeControlMaxPressure = 25.0f;
    // uiState.VolumeControlTidalVolume = 0.450f;
    uiState.Peep = controlPEEP.GetValue();
    uiState.InspirationTime = controlInspTime.GetValue();
    uiState.InspirationFilterRate = 0.01f;
    uiState.ExpirationFilterRate = 0.02f;
    uiState.TriggerMode = 1;
    uiState.TimerTriggerBreathsPerMin = (char)controlRR.GetValue();
    // uiState.PatientEffortTriggerMinBreathsPerMin = 8;
    // uiState.PatientEffortTriggerLitersPerMin = 2.5f;

    controlFiO2.SetValue(uiState.FiO2 * 100.0f);
    controlPEEP.SetValue(uiState.Peep);
    controlRR.SetValue(uiState.TimerTriggerBreathsPerMin);
    controlInspTime.SetValue(uiState.InspirationTime);
    controlIP.SetValue(uiState.PressureControlInspiratoryPressure);

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
