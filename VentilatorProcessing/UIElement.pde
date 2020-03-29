class UIElement
{
  Transform2D Transform;
  float FracW, FracH;

  public UIElement()
  {
    Transform = new Transform2D();
  }

  public UIElement(int x, int y, int w, int h)
  {
    Transform = new Transform2D(x, y, w, h);
  }

  public UIElement(float fracW, float fracH)
  {
    Transform = new Transform2D();
    FracW = fracW;
    FracH = fracH;
  }

  public UIElement(int x, int y, int w, int h, float fracW, float fracH)
  {
    Transform = new Transform2D(x, y, w, h);
    FracW = fracW;
    FracH = fracH;
  }

  public void Update() {}
  public void Render() {}
}

// For elements that need a render target
class UIElementRT extends UIElement
{
  protected PGraphics _renderTarget;
  private int _prevW, _prevH;

  public UIElementRT(float fracW, float fracH)
  {
    super(fracW, fracH);
    _prevW = -1;
    _prevH = -1;
  }

  private void SetupRenderTarget()
  {
    int w = max(2, Transform.GetW());
    int h = max(2, Transform.GetH());
    _renderTarget = createGraphics(w, h);
    _renderTarget.beginDraw();
    _renderTarget.background(0);
    _renderTarget.endDraw();
  }

  // Returns true if changed
  private boolean RefreshPrevWH()
  {
    int w = Transform.GetW();
    int h = Transform.GetH();
    boolean changed = _prevW != w || _prevH != h;
    _prevW = w;
    _prevH = h;
    return changed;
  }

  public void Update()
  {
    super.Update();
    if (RefreshPrevWH())
    {
      SetupRenderTarget();
    }
  }

  protected void Draw() {}

  public void Render()
  {
    if (_renderTarget != null)
    {
      _renderTarget.beginDraw();
      Draw();
      _renderTarget.endDraw();
      image(_renderTarget, Transform.GetX(), Transform.GetY());
    }
  }
}

class UIButton extends UIElement
{
  public UIButton(int x, int y, int w, int h)
  {
    super(x, y, w, h);
  }

  public UIButton(float fracW, float fracH)
  {
    super(fracW, fracH);
  }

  public void Render()
  {
    fill(50);
    stroke(0);
    strokeWeight(4);
    rect(Transform.GetX(), Transform.GetY(), Transform.GetW(), Transform.GetH(), 12);
  }
}

class UITrackBar extends UIElement
{
  public UITrackBar(int x, int y, int w, int h)
  {
    super(x, y, w, h);
  }

  public UITrackBar(float fracW, float fracH)
  {
    super(fracW, fracH);
  }

  public void Render()
  {
    fill(50);
    stroke(0);
    strokeWeight(4);
    rect(Transform.GetX(), Transform.GetY(), Transform.GetW(), Transform.GetH(), 12);
  }
}
