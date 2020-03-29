boolean appFullScreen = false;
boolean appTouchScreen = false;
boolean appSmooth = false;

UIButton b1, b2, b3, b4;
UIGraph graph1, graph2, graph3;
UITrackBar TrackBar;
UIGroup RootGroup, MainGroup, GraphGroup, SettingsGroup, RightGroup;

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
  TrackBar = new UITrackBar(1.0, 1.0);
  b1 = new UIButton(0.4, 1.0);
  b2 = new UIButton(0.2, 1.0);
  b3 = new UIButton(0.2, 1.0);
  b4 = new UIButton(0.2, 1.0);
  graph1 = new UIGraph(1.0, 1.0, 512, 0.0);
  graph2 = new UIGraph(1.0, 1.0, 512, 0.0);
  graph3 = new UIGraph(1.0, 1.0, 512, 0.0);

  GraphGroup = new UIVerticalFracGroup(1.0, 0.8, new UIElement[] {graph1, graph2, graph3});
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
  RootGroup.Render();
}
