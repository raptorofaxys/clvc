class UIGroup extends UIElement
{
  UIElement[] _children;
  boolean _dirtyLayout;

  public UIGroup(int x, int y, int w, int h)
  {
    super(x, y, w, h);
    SetChildren(null);
  }

  public UIGroup(int x, int y, int w, int h, UIElement[] children)
  {
    super(x, y, w, h);
    SetChildren(children);
  }

  public UIGroup(float fracW, float fracH)
  {
    super(fracW, fracH);
  }

  public UIGroup(float fracW, float fracH, UIElement[] children)
  {
    super(fracW, fracH);
    SetChildren(children);
  }

  public void SetChildren(UIElement[] children)
  {
    if (children == null)
      children = new UIElement[0];
    // TODO: validate that no child is null
    _children = children;
    _dirtyLayout = true;
  }

  public void UpdateChildren()
  {
    for (UIElement e : _children)
    {
      e.Update();
    }
  }

  public void UpdateChildrenLayout()
  {
    for (UIElement e : _children)
    {
      if (e instanceof UIGroup)
      {
        ((UIGroup)e).UpdateChildrenLayout();
      }
    }
  }

  public void Update()
  {
    if (_dirtyLayout)
    {
      UpdateChildrenLayout();
      _dirtyLayout = false;
    }

    UpdateChildren();
  }

  public void Render()
  {
    for (UIElement e : _children)
    {
      e.Render();
    }
  }
}

// Spreads children horizontally based on their frac width. Full height.
class UIHorizontalFracGroup extends UIGroup
{
  public UIHorizontalFracGroup(int x, int y, int w, int h, UIElement[] children)
  {
    super(x, y, w, h, children);
  }

  public UIHorizontalFracGroup(float fracW, float fracH, UIElement[] children)
  {
    super(fracW, fracH, children);
  }

  public void UpdateChildrenLayout()
  {
    int slotX = Transform.GetX();
    int thisY = Transform.GetY();
    int thisW = Transform.GetW();
    int thisH = Transform.GetH();

    float fracSum = 0.0;
    for (UIElement e : _children)
    {
      fracSum += e.FracW;
    }

    for (UIElement e : _children)
    {
      e.Transform.SetXY(slotX, thisY);
      int eW = (int)(thisW * e.FracW / fracSum);
      slotX += eW;
      e.Transform.SetWH(eW, thisH);
    }

    super.UpdateChildrenLayout();
  }
}

// Spreads children vertically based on their frac height. Full width.
class UIVerticalFracGroup extends UIGroup
{
  public UIVerticalFracGroup(int x, int y, int w, int h, UIElement[] children)
  {
    super(x, y, w, h, children);
  }

  public UIVerticalFracGroup(float fracW, float fracH, UIElement[] children)
  {
    super(fracW, fracH, children);
  }

  public void UpdateChildrenLayout()
  {
    int thisX = Transform.GetX();
    int slotY = Transform.GetY();
    int thisW = Transform.GetW();
    int thisH = Transform.GetH();

    float fracSum = 0.0;
    for (UIElement e : _children)
    {
      fracSum += e.FracH;
    }

    for (UIElement e : _children)
    {
      e.Transform.SetXY(thisX, slotY);
      int eH = (int)(thisH * e.FracH / fracSum);
      slotY += eH;
      e.Transform.SetWH(thisW, eH);
    }

    super.UpdateChildrenLayout();
  }
}

class UIOverlappingGroup extends UIGroup
{
  public UIOverlappingGroup(int x, int y, int w, int h, UIElement[] children)
  {
    super(x, y, w, h, children);
  }

  public UIOverlappingGroup(float fracW, float fracH, UIElement[] children)
  {
    super(fracW, fracH, children);
  }

  public void UpdateChildrenLayout()
  {
    int x = Transform.GetX();
    int y = Transform.GetY();
    int w = Transform.GetW();
    int h = Transform.GetH();

    for (UIElement e : _children)
    {
      e.Transform.SetXY(x, y);
      e.Transform.SetWH(w, h);
    }

    super.UpdateChildrenLayout();
  }
}

class UIInfoText extends UIHorizontalFracGroup
{
  private UIText _textLabel;
  private UIText _textValue;
  private int _decimals;
  private String _prefix;

  public UIInfoText(float fracW, float fracH, String label, color textColor, int decimals, String prefix)
  {
    super(fracW, fracH, null);
    label = String.format(" %s", label);
    _textLabel = new UIText(1.0, 1.0, label, fontSemilight, 24, textColor, LEFT, CENTER);
    _textValue = new UIText(1.0, 1.0, "-- ", fontBold, 24, textColor, RIGHT, CENTER);
    SetChildren(new UIElement[] {_textLabel, _textValue});
    _decimals = decimals;
    _prefix = prefix;
  }
  public UIInfoText(float fracW, float fracH, String label, color textColor, int decimals)
  {
    this(fracW, fracH, label, textColor, decimals, "");
  }
  public UIInfoText(float fracW, float fracH, String label, color textColor)
  {
    this(fracW, fracH, label, textColor, 0, "");
  }

  public void SetValue(float value)
  {
    _textValue.SetText(String.format("%s%s ", _prefix, FloatToRoundedString(value, _decimals)));
  }
}

class UIControlButton extends UIOverlappingGroup
{
  private UIVerticalFracGroup _textGroup;
  private UIText _textLabel;
  private UIText _textValue;
  private UIControlRadioButton _button;
  private int _decimals;
  private float _rangeMin, _rangeMax;

  public UIControlRadioButton GetRadioButton() { return _button; }

  public UIControlButton(float fracW, float fracH, String label, float rangeMin, float rangeMax, int decimals)
  {
    super(fracW, fracH, null);
    _button = new UIControlRadioButton(1.0, 1.0, this);
    _textLabel = new UIText(1.0, 0.4, label, fontBold, 16, 100, CENTER, CENTER);
    _textValue = new UIText(1.0, 0.6, "--", fontSemilight, 64, 255, CENTER, TOP);
    _textGroup = new UIVerticalFracGroup(1.0, 1.0, new UIElement[] {_textLabel, _textValue});
    SetChildren(new UIElement[] {_button, _textGroup});
    _decimals = decimals;
    _rangeMin = rangeMin;
    _rangeMax = rangeMax;
  }

  public UIControlButton(float fracW, float fracH, String label, float rangeMin, float rangeMax)
  {
    this(fracW, fracH, label, rangeMin, rangeMax, 0);
  }

  public void SetValue(float value)
  {
    _textValue.SetText(FloatToRoundedString(value, _decimals));
  }

  public void SetValueInRange01(float t)
  {
    SetValue(lerp(_rangeMin, _rangeMax, t));
  }
}
