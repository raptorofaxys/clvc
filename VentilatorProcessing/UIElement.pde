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
