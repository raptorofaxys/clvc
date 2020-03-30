boolean appFullScreen = false;
boolean appTouchScreen = false;
boolean appSmooth = false;

UIButton b1, b2, b3, b4;
UIGraph graphPressure, graphFlow, graphVolume;
UITrackBar TrackBar;
UIGroup RootGroup, MainGroup, GraphGroup, SettingsGroup, RightGroup;
PFont fontText, fontNumbers;

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

  fontText = loadFont("SegoeUI_Bold_64.vlw");
  fontNumbers = loadFont("SegoeUI_Semilight_64.vlw");

  TrackBar = new UITrackBar(1.0, 1.0);
  b1 = new UIButton(0.2, 1.0);
  b2 = new UIButton(0.2, 1.0);
  b3 = new UIButton(0.2, 1.0);
  b4 = new UIButton(0.2, 1.0);
  graphPressure = new UIGraph(1.0, 1.0, 512, -1.0, 1.0, #00ff99);
  graphFlow = new UIGraph(1.0, 1.0, 512, -2.0, 2.0, #0099ff);
  graphVolume = new UIGraph(1.0, 1.0, 512, -1.0, 3.0, #ff9900);

  GraphGroup = new UIVerticalFracGroup(1.0, 0.8, new UIElement[] {graphPressure, graphFlow, graphVolume});
  SettingsGroup = new UIHorizontalFracGroup(1.0, 0.2, new UIElement[] {b1, b2, b3, b4});
  MainGroup = new UIVerticalFracGroup(0.85, 1.0, new UIElement[] {GraphGroup, SettingsGroup});

  RightGroup = new UIVerticalFracGroup(0.15, 1.0, new UIElement[] {TrackBar});

  RootGroup = new UIHorizontalFracGroup(0, 0, width, height, new UIElement[] {MainGroup, RightGroup});
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
}

void Render()
{
  background(0);
  RootGroup.Render();
  fill(100);
  textFont(fontText, 24);
  text("PEEP", 56, height - 90);
  fill(255);
  textFont(fontNumbers, 64);
  text("12.6", 30, height - 28);
}
