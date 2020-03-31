import processing.serial.*;

boolean appFullScreen = false;
boolean appTouchScreen = false;
boolean appSmooth = true;
boolean appDebug = false;

UIMenuButton menuButton;
UIControlButton controlFiO2, controlPEEP, controlRR, controlInspTime, controlVT, controlIP;
UIGraph graphPressure, graphFlow, graphVolume;
UIInfoText infoPPeak, infoPMean, infoPPlat, infoPEEP, infoRR, infoIE, infoMVe, infoVTi, infoVTe;
UITrackBar trackBar;
UIGroup runtimeGroup, mainGroup, dataGroup, graphGroup, infoGroup, controlsGroup, rightGroup;

PFont fontBold, fontSemilight;
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
    //size(800, 500, P2D);
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

  fontBold = loadFont("SegoeUI_Bold_64.vlw");
  fontSemilight = loadFont("SegoeUI_Semilight_64.vlw");

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
  graphPressure = new UIGraph(1.0, 1.0, 768, -1, 40.0, #ffbb00);
  graphFlow = new UIGraph(1.0, 1.0, 768, -100.0, 100.0, #00ff99);
  graphVolume = new UIGraph(1.0, 1.0, 768, -40.0, 800.0, #0099ff);
  graphGroup = new UIVerticalFracGroup(0.8, 1.0, new UIElement[] {graphPressure, graphFlow, graphVolume});

  // Info Panel
  infoPPeak = new UIInfoText(1.0, 1.0, "PPeak", colorPressure);
  infoPMean = new UIInfoText(1.0, 1.0, "PMean", colorPressure);
  infoPPlat = new UIInfoText(1.0, 1.0, "PPlat", colorPressure);
  infoPEEP = new UIInfoText(1.0, 1.0, "PEEP", colorPressure);
  infoRR = new UIInfoText(1.0, 1.0, "Resp Rate", colorFlow);
  infoIE = new UIInfoText(1.0, 1.0, "I:E", colorFlow, 1, "1:");
  infoMVe = new UIInfoText(1.0, 1.0, "MVe", colorVolume, 1);
  infoVTi = new UIInfoText(1.0, 1.0, "VTi", colorVolume);
  infoVTe = new UIInfoText(1.0, 1.0, "VTe", colorVolume);
  infoGroup = new UIVerticalFracGroup(0.2, 1.0, new UIElement[] {infoPPeak, infoPMean, infoPPlat, infoPEEP, infoRR, infoIE, infoMVe, infoVTi, infoVTe});

  dataGroup = new UIHorizontalFracGroup(1.0, 0.8, new UIElement[] {graphGroup, infoGroup});

  mainGroup = new UIVerticalFracGroup(0.9, 1.0, new UIElement[] {dataGroup, controlsGroup});

  trackBar = new UITrackBar(1.0, 1.0, controlButtons);
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
      if (appDebug)
      {
        println("-----");
         println("ms.InhalationPressure: " + ms.InhalationPressure);
        // println("Target pressure: " + ms.Debug3);

        // println("Tracking: " + ms.Debug1);
        println("GasL: " + ms.Debug1);
        println("FlowSlpm: " + ms.Debug2);
        println("Backpressure: " + ms.Debug3);
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
      infoMVe.SetValue(ms.MinuteVentilationLitersPerMin);
      infoVTi.SetValue(ms.InhalationTidalVolume);
      infoVTe.SetValue(ms.ExhalationTidalVolume);

      graphPressure.SetValue(ms.InhalationPressure);
      graphPressure.SetBGColor(ms.BreathPhase == 0 ? #282828 : #1E1E1E);
      // graphFlow.SetValue(ms.Debug1 * 100.0f);
      graphFlow.SetValue(ms.TotalFlowLitersPerMin);
      graphVolume.SetValue((ms.O2ValveOpening + ms.AirValveOpening) * 600.0f);

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
