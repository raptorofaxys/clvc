boolean appFullScreen = false;
boolean appTouchScreen = false;
boolean appSmooth = false;

UIButton b1, b2, b3, b4;
UIGraph GraphPressure, GraphFlow, GraphVolume;
UITrackBar TrackBar;
UIElement InfoPanel;
UIGroup RootGroup, MainGroup, DataGroup, GraphGroup, SettingsGroup, RightGroup;
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
  InfoPanel = new UIElement(0.2, 1.0);
  b1 = new UIButton(0.2, 1.0);
  b2 = new UIButton(0.2, 1.0);
  b3 = new UIButton(0.2, 1.0);
  b4 = new UIButton(0.2, 1.0);
  GraphPressure = new UIGraph(1.0, 1.0, 512, -1.0, 1.0, #ffbb00);
  GraphFlow = new UIGraph(1.0, 1.0, 512, -2.0, 2.0, #00ff99);
  GraphVolume = new UIGraph(1.0, 1.0, 512, -1.0, 3.0, #0099ff);

  GraphGroup = new UIVerticalFracGroup(0.8, 1.0, new UIElement[] {GraphPressure, GraphFlow, GraphVolume});
  DataGroup = new UIHorizontalFracGroup(1.0, 0.8, new UIElement[] {GraphGroup, InfoPanel});
  SettingsGroup = new UIHorizontalFracGroup(1.0, 0.2, new UIElement[] {b1, b2, b3, b4});
  MainGroup = new UIVerticalFracGroup(0.9, 1.0, new UIElement[] {DataGroup, SettingsGroup});
  RightGroup = new UIVerticalFracGroup(0.1, 1.0, new UIElement[] {TrackBar});
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
