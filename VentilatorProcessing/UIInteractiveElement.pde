// UIInteractiveUtils Global
public boolean MouseOverRect(int x, int y, int w, int h)
{
  return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
}

public boolean MouseOverRect(Transform2D Transform)
{
  int x = Transform.GetX();
  int y = Transform.GetY();
  int w = Transform.GetW();
  int h = Transform.GetH();
  return MouseOverRect(x, y, w, h);
}

static class UIInteractiveUtils
{
  private static boolean _mousePressedThisFrame;
  private static boolean _mouseReleasedThisFrame;
  public static boolean GetMousePressedThisFrame() { return _mousePressedThisFrame; }
  public static boolean GetMouseReleasedThisFrame() { return _mouseReleasedThisFrame; }

  public static void Reset()
  {
    _mousePressedThisFrame = false;
    _mouseReleasedThisFrame = false;
  }

  public static void MousePress()
  {
    _mousePressedThisFrame = true;
  }

  public static void MouseRelease()
  {
    _mouseReleasedThisFrame = true;
  }
}

class UIInteractiveElement extends UIElement
{
  protected boolean _over;
  protected boolean _pressed;

  public UIInteractiveElement(int x, int y, int w, int h)
  {
    super(x, y, w, h);
  }

  public UIInteractiveElement(float fracW, float fracH)
  {
    super(fracW, fracH);
  }

  protected void OnHover()
  {
    _over = true;
  }
  protected void OnPress()
  {
    _pressed = true;
  }
  protected void OnRelease()
  {
    _pressed = false;
  }
  protected void OnRollOver()
  {
    _over = true;
  }
  protected void OnRollOut()
  {
    _over = false;
  }

  public void Update()
  {
    boolean over = MouseOverRect(Transform);

    if (over)
    {
      if (!_over)
      {
        OnRollOver();
      }

      OnHover();

      if (UIInteractiveUtils.GetMousePressedThisFrame())
      {
        OnPress();
      }

      if (UIInteractiveUtils.GetMouseReleasedThisFrame())
      {
        OnRelease();
      }
    }
    else
    {
      if (_over)
      {
        OnRollOut();
      }

      if (UIInteractiveUtils.GetMouseReleasedThisFrame())
      {
        _pressed = false;
      }
    }
  }
}

class UIButton extends UIInteractiveElement
{
  protected color _colorFill = 40;

  public UIButton(float fracW, float fracH)
  {
    super(fracW, fracH);
  }

  protected void OnPress()
  {
    super.OnPress();
  }

  public void Render()
  {
    fill(_colorFill);
    stroke(0);
    strokeWeight(4);
    rect(Transform.GetX(), Transform.GetY(), Transform.GetW(), Transform.GetH(), 12.0f);
  }
}

class UIRadioButton extends UIButton
{
  private UIRadioButtonSet _set;
  private boolean _selected;
  private int _id;

  public UIRadioButton(float fracW, float fracH)
  {
    super(fracW, fracH);
  }

  public void SetID(UIRadioButtonSet set, int id)
  {
    _set = set;
    _id = id;
  }

  protected void OnPress()
  {
    super.OnPress();
    if (_set != null)
      _set.SelectID(_id);
  }

  public void Select()
  {
    _selected = true;
    _colorFill = 55;
  }

  public void UnSelect()
  {
    _selected = false;
    _colorFill = 40;
  }
}

class UIControlRadioButton extends UIRadioButton
{
  private UIControlButton _controlParent;

  public UIControlButton GetControlParent() { return _controlParent; }

  public UIControlRadioButton(float fracW, float fracH, UIControlButton controlParent)
  {
    super(fracW, fracH);
    _controlParent = controlParent;
  }
}

class UIRadioButtonSet
{
  private UIRadioButton[] _radioButtons;
  private int _selectedID = -1;

  public UIRadioButtonSet(UIRadioButton[] radioButtons, int selectedID)
  {
    SetRadioButtons(radioButtons);
    SelectID(selectedID);
  }

  public void SetRadioButtons(UIRadioButton[] radioButtons)
  {
    if (radioButtons == null)
      radioButtons = new UIRadioButton[0];

    _radioButtons = radioButtons;

    for (int i = 0; i < _radioButtons.length; i++)
    {
      _radioButtons[i].SetID(this, i);
    }
  }

  public void SelectID(int id)
  {
    if (id >= 0 && id < _radioButtons.length)
    {
      if (id != _selectedID)
      {
        for (int i = 0; i < _radioButtons.length; i++)
        {
          if (i == id)
            _radioButtons[i].Select();
          else
            _radioButtons[i].UnSelect();
        }
        _selectedID = id;
      }
    }
  }

  public UIRadioButton GetSelectedButton()
  {
    return _radioButtons[_selectedID];
  }
}

class UIMenuButton extends UIButton
{
  public UIMenuButton(float fracW, float fracH)
  {
    super(fracW, fracH);
  }

  public void Render()
  {
    super.Render();
    // Hamburger Icon
    int w = 28;
    int h = 6;
    int ySpacing = 9;
    int x = Transform.GetX() + Transform.GetW() / 2 - w / 2;
    int y = Transform.GetY() + Transform.GetH() / 2 - h / 2;
    noStroke();
    fill(100);
    rect(x, y - ySpacing, w, h, 2);
    rect(x, y, w, h, 2);
    rect(x, y + ySpacing, w, h, 2);
  }
}

class UITrackBar extends UIInteractiveElement
{
  private final float MIN_TRACK_SPEED = 0.2;
  private final float MAX_TRACK_SPEED = 5.0;
  private UIRadioButtonSet _controlButtons;
  private int _pressedY;
  private float _pressedValue;
  private float _trackSpeed;
  private int _offsetY;

  public UITrackBar(float fracW, float fracH, float trackSpeed, UIRadioButtonSet controlButtons)
  {
    super(fracW, fracH);
    _controlButtons = controlButtons;
    SetTrackSpeed(trackSpeed);
  }

  protected void OnRollOver()
  {
    super.OnRollOver();
    _pressedY = mouseY;
    _pressedValue = GetControlValue();
  }

  protected void OnPress()
  {
    super.OnPress();
    _pressedY = mouseY;
    _pressedValue = GetControlValue();
  }

  public void SetTrackSpeed(float trackSpeed)
  {
    _trackSpeed = max(MIN_TRACK_SPEED, min(MAX_TRACK_SPEED, trackSpeed));
  }

  private float GetControlValue()
  {
    UIControlRadioButton b = (UIControlRadioButton)_controlButtons.GetSelectedButton();
    return b.GetControlParent().GetValueInRange01();
  }

  private void SetControlValue(float value)
  {
    UIControlRadioButton b = (UIControlRadioButton)_controlButtons.GetSelectedButton();
    b.GetControlParent().SetValueInRange01(value);
  }

  protected void OnHover()
  {
    super.OnHover();
    if (_pressed)
    {
      float deltaY = _pressedY - mouseY;
      float value = max(0, min(1, _pressedValue + deltaY / height * _trackSpeed));
      _offsetY = -(int)deltaY;
      SetControlValue(value);
    }
  }

  public void Render()
  {
    int x = Transform.GetX();
    int y = Transform.GetY();
    int w = Transform.GetW();
    int h = Transform.GetH();

    // Strips
    color c1 = color(55);
    color c2 = color(50);
    int stripCount = 20;
    float stripHeightRatio = 0.2f;
    float stripPairHeight = h / stripCount;
    float strip1H = stripPairHeight * stripHeightRatio;
    float strip2H = stripPairHeight * (1f - stripHeightRatio);
    noStroke();
    for (int i = 0; i < stripCount + 1; i++)
    {
      float stripY = y + stripPairHeight * i + _offsetY % stripPairHeight;
      stripY -= stripY > y + h ? h + stripPairHeight : 0f;
      fill(c1);
      rect(x, stripY, w, strip1H);
      fill(c2);
      rect(x, stripY + strip1H, w, strip2H);
    }

    // Gradients
    int gradH = 10;
    GradientVertical(x, y, w, gradH, 0, 150, 0, 0);
    GradientVertical(x, y + h - gradH, w, gradH, 0, 0, 0, 150);
    gradH = (int)(h * 0.4f);
    GradientVertical(x, y, w, gradH, 0, 100, 0, 0);
    GradientVertical(x, y + h - gradH, w, gradH, 0, 0, 0, 100);

    // Rounded corners
    fill(0);
    float cornerRadius = 4f;
    rect(x, y, cornerRadius, cornerRadius);
    rect(x + w - cornerRadius, y, cornerRadius, cornerRadius);
    rect(x, y + h - cornerRadius, cornerRadius, cornerRadius);
    rect(x + w - cornerRadius, y + h - cornerRadius, cornerRadius, cornerRadius);
    stroke(0);
    strokeWeight(4f);
    noFill();
    rect(x, y, w, h, 12);
  }
}
