class UIElement
{
  Transform2D Transform;
  float FracW, FracH;
  private int _prevW, _prevH;

  public UIElement(int x, int y, int w, int h)
  {
    Transform = new Transform2D(x, y, w, h);
    _prevW = -1;
    _prevH = -1;
  }

  public UIElement()
  {
    this(0, 0, 0, 0);
  }

  public UIElement(float fracW, float fracH)
  {
    this(0, 0, 0, 0);
    FracW = fracW;
    FracH = fracH;
  }

  public UIElement(int x, int y, int w, int h, float fracW, float fracH)
  {
    Transform = new Transform2D(x, y, w, h);
    FracW = fracW;
    FracH = fracH;
  }

  // Returns true if width or height changed
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
    if (RefreshPrevWH())
      OnResize();
  }

  protected void OnResize() {}
  public void Render() {}
}

// For elements that need a render target
class UIElementRT extends UIElement
{
  protected PGraphics _renderTarget;

  public UIElementRT(float fracW, float fracH)
  {
    super(fracW, fracH);
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

  protected void OnResize()
  {
    super.OnResize();
    SetupRenderTarget();
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

class UIText extends UIElement
{
  private String _text;
  private PFont _font;
  private float _textSize;
  private color _textColor;
  private int _alignX, _alignY;

  public UIText(float fracW, float fracH, String text, PFont font, float textSize, color textColor, int alignX, int alignY)
  {
    super(fracW, fracH);
    _text = text;
    _font = font;
    _textSize = textSize;
    _textColor = textColor;
    _alignX = alignX;
    _alignY = alignY;
  }

  public void SetText(String text)
  {
    _text = text;
  }

  public void Render()
  {
    int x = Transform.GetX();
    int y = Transform.GetY();
    int w = Transform.GetW();
    int h = Transform.GetH();

    /* Debug
    stroke(#ffff00);
    strokeWeight(0.5);
    noFill();
    rect(x, y, w, h);
    //*/

    switch (_alignX)
    {
      case CENTER:
        x += w / 2;
        break;
      case RIGHT:
        x += w;
        break;
    }
    switch (_alignY)
    {
      case CENTER:
        y += h / 2;
        break;
      case BOTTOM:
      case BASELINE:
        y += h;
        break;
    }

    // TODO: size relative to resolution
    // maybe snap to specific multiples of original fontSize?
    textAlign(_alignX, _alignY);
    fill(_textColor);
    textFont(_font, _textSize);
    text(_text, x, y);
  }
}
// UIText wannabe static methods
public static String FloatToRoundedString(float value, int decimals)
{
  // Rounded value to the decimal count
  float p = pow(10, decimals);
  float v = value * p;
  v = (int)(v + 0.5) / p;
  String formatString = String.format("%%.%df", decimals);

  return String.format(formatString, value);
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
  public UITrackBar(float fracW, float fracH)
  {
    super(fracW, fracH);
  }

  public void Render()
  {
    fill(30);
    stroke(0);
    strokeWeight(4);
    rect(Transform.GetX(), Transform.GetY(), Transform.GetW(), Transform.GetH());
  }
}
