class UIGraph extends UIElementRT
{
  private int FADE_SAMPLES_COUNT = 5;

  private int _sampleCount;
  private float[] _samplesValue;
  private color[] _samplesBGColor;
  private float _rangeMinY;
  private float _rangeMaxY;
  private float _rangeHeight;
  private color _colorLine;
  private color _colorDot;
  private int _sampleIndex;
  private int _currentX;
  private int _currentY;
  private int _originY;

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

    _samplesBGColor[0] = #1E1E1E;
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

  // private color GetPrevBGColor()
  // {
  //   return _samplesBGColor[GetPrevSampleIndex()];
  // }

  private color GetCurrentBGColor()
  {
    return _samplesBGColor[_sampleIndex];
  }

  private float GetYPosition(float y)
  {
    return Transform.GetH() - (y - _rangeMinY) * _rangeHeight;
  }

  protected void OnResize()
  {
    super.OnResize();
    _rangeHeight = Transform.GetH() / (_rangeMaxY - _rangeMinY);
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
    float sampleWidth = (float)w / (float)_sampleCount;

    float x1 = _sampleIndex * sampleWidth;
    float x0 = x1 - sampleWidth;
    _renderTarget.noStroke();
    for (int i = 0; i < FADE_SAMPLES_COUNT; i++)
    {
      // This does not produce a linear fade but good enough for now
      _renderTarget.fill(GetCurrentBGColor(), 255 * (FADE_SAMPLES_COUNT - i) / FADE_SAMPLES_COUNT);
      _renderTarget.rect(x1 + sampleWidth * i, 2, sampleWidth, h - 4);
      // _renderTarget.fill(0);
      // _renderTarget.rect();
    }

    if (_sampleIndex != _sampleCount - 1)
    {
      // Invert y values because Processing coordinate system 0 is top
      float y0 = GetYPosition(GetPrevValue());
      float y1 = GetYPosition(GetCurrentValue());
      _originY = (int)GetYPosition(0);

      _renderTarget.noFill();
      _renderTarget.stroke(_colorLine);
      _renderTarget.strokeWeight(1);
      _currentX = (int)x1;
      _currentY = (int)y1;
      _renderTarget.line((int)x0, (int)y0, _currentX, _currentY);
    }
  }

  public void Render()
  {
    super.Render();
    int x = Transform.GetX();
    int y = Transform.GetY();
    noFill();
    stroke(90);
    strokeWeight(0.5);
    line(0, _originY + y, Transform.GetW(), _originY + y);
    fill(_colorDot);
    noStroke();
    circle(_currentX + x, _currentY + y, 5);
  }
}
