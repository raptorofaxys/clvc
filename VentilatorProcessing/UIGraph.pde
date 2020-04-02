class UIGraph extends UIElementRT
{
  final private int FADE_SAMPLES_COUNT = 10;
  final private color BG_COLOR = #1e1e1e;

  private int _sampleCount;
  private float[] _samplesValue;
  private color[] _samplesBGColor;
  private float _rangeMinY;
  private float _rangeMaxY;
  private float _rangeHeight;
  private color _colorLine;
  private color _colorDot;
  private int _sampleIndex;
  private float _currentX;
  private float _currentY;
  private float _originY;

  public UIGraph(float fracW, float fracH, int sampleCount, float rangeMinY, float rangeMaxY, color colorLine)
  {
    super(fracW, fracH);
    _sampleCount = sampleCount;
    _samplesValue = new float[sampleCount];
    _samplesBGColor = new color[sampleCount];
    _rangeMinY = rangeMinY;
    _rangeMaxY = rangeMaxY;
    _colorLine = colorLine;
    _colorDot = colorLine;
    _samplesBGColor[0] = BG_COLOR;
  }

  public void SetValue(float value)
  {
    _samplesValue[_sampleIndex] = value;
  }

  public void SetBGColor(color bgColor)
  {
    _samplesBGColor[_sampleIndex] = bgColor;
  }

  private void NextSample()
  {
    float currentValue = _samplesValue[_sampleIndex];
    color currentBGColor = _samplesBGColor[_sampleIndex];

    _sampleIndex += 1;
    _sampleIndex = _sampleIndex >= _sampleCount ? 0 : _sampleIndex;

    _samplesValue[_sampleIndex] = currentValue;
    _samplesBGColor[_sampleIndex] = currentBGColor;
  }

  private int GetPrevSampleIndex()
  {
    int i = _sampleIndex;
    i -= 1;
    return i < 0 ? _sampleCount - 1 : i;
  }

  private float GetPrevValue()
  {
    return _samplesValue[GetPrevSampleIndex()];
  }

  private float GetCurrentValue()
  {
    return _samplesValue[_sampleIndex];
  }

  private color GetPrevBGColor()
  {
    return _samplesBGColor[GetPrevSampleIndex()];
  }

  private color GetCurrentBGColor()
  {
    return _samplesBGColor[_sampleIndex];
  }

  private float GetYPosition(float y)
  {
    // Invert y values because Processing coordinate system 0 is top
    return Transform.GetH() - (y - _rangeMinY) * _rangeHeight;
  }

  protected void OnResize()
  {
    super.OnResize();
    int w = Transform.GetW();
    int h = Transform.GetH();
    _rangeHeight = h / (_rangeMaxY - _rangeMinY);

    // Draw background
    _renderTarget.beginDraw();
    _renderTarget.noStroke();
    _renderTarget.fill(BG_COLOR);
    _renderTarget.rect(0f, 2f, w, h - 4f);
    _renderTarget.endDraw();
  }

  public void Update()
  {
    super.Update();
    // TODO: Make frame rate independent
    // 0, 1 or more NextSample() calls based on elapsed time would fix
    // should interpolate missing samples
    // would require work to handle drawing
    NextSample();
  }

  protected void Draw()
  {
    int x = Transform.GetX();
    int y = Transform.GetY();
    int w = Transform.GetW();
    int h = Transform.GetH();
    float sampleWidth = (float)w / _sampleCount;

    float x1 = _sampleIndex * sampleWidth;
    float x0 = x1 - sampleWidth;

    // Background
    _renderTarget.noStroke();
    for (int i = 0; i < FADE_SAMPLES_COUNT; i++)
    {
      // This does not produce a linear fade but good enough for now
      int alpha = 255 * (FADE_SAMPLES_COUNT - i) / FADE_SAMPLES_COUNT;
      int stepW = (int)sampleWidth + 1;
      int stepX = (int)x1 + stepW * i;
      color bgColor = lerpColor(GetCurrentBGColor(), BG_COLOR, (float)i / FADE_SAMPLES_COUNT);
      _renderTarget.fill(bgColor, alpha);
      _renderTarget.rect(stepX, 2f, stepW, h - 4f);
      _renderTarget.fill(0, alpha);
      _renderTarget.rect(stepX, 0f, stepW, 2f);
      _renderTarget.rect(stepX, h - 2f, stepW, 2f);
    }

    // Curve
    if (_sampleIndex != _sampleCount - 1)
    {
      float y0 = GetYPosition(GetPrevValue());
      float y1 = GetYPosition(GetCurrentValue());
      _originY = GetYPosition(0f);

      _renderTarget.noFill();
      _renderTarget.stroke(_colorLine);
      _renderTarget.strokeWeight(2f);
      _currentX = x1;
      _currentY = y1;
      _renderTarget.line(x0, y0, x1, y1);
    }
  }

  public void Render()
  {
    super.Render();
    int x = Transform.GetX();
    int y = Transform.GetY();
    int w = Transform.GetW();

    // Origin Axis
    noFill();
    stroke(90);
    strokeWeight(0.5f);
    line(x, _originY + y, w, _originY + y);

    // Axis second marks
    strokeWeight(1f);
    int secondsCount = _sampleCount / APP_FRAMERATE;
    float secondWidth = (float)w / _sampleCount * APP_FRAMERATE;
    for (int i = 1; i < secondsCount; i++)
    {
      int secondX = (int)(i * secondWidth + x);
      line(secondX, _originY + y - 2, secondX, _originY + y + 2);
    }

    // Current Value Dot
    fill(_colorDot);
    noStroke();
    circle(_currentX + x, _currentY + y, 5.0f);
  }
}
