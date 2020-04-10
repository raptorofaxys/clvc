class UIGraph2 extends UIElement
{
  final private int FADE_SAMPLES_COUNT = 30;
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

  public UIGraph2(float fracW, float fracH, int sampleCount, float rangeMinY, float rangeMaxY, color colorLine)
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
    _originY = GetYPosition(0f);

    // Draw background
    noStroke();
    fill(BG_COLOR);
    rect(0f, 2f, w, h - 4f);
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

    // float x1 = _sampleIndex * sampleWidth;
    // float x0 = x1 - sampleWidth;

    // noStroke();
    // for (int i = 0; i < FADE_SAMPLES_COUNT; i++)
    // {
    //   // This does not produce a linear fade but good enough for now
    //   int alpha = 255 * (FADE_SAMPLES_COUNT - i) / FADE_SAMPLES_COUNT;
    //   int stepW = (int)sampleWidth + 1;
    //   int stepX = (int)x1 + stepW * i;
    //   color bgColor = lerpColor(GetCurrentBGColor(), BG_COLOR, (float)i / FADE_SAMPLES_COUNT);
    //   fill(bgColor, alpha);
    //   rect(stepX, 2f, stepW, h - 4f);
    //   fill(0, alpha);
    //   rect(stepX, 0f, stepW, 2f);
    //   rect(stepX, h - 2f, stepW, 2f);
    // }

    // Curve
    if (_sampleIndex != _sampleCount - 1)
    {
      // float y0 = GetYPosition(GetPrevValue());
      float y1 = GetYPosition(GetCurrentValue());
      // _originY = GetYPosition(0f);

      // noFill();
      // stroke(_colorLine);
      // strokeWeight(2f * app.GetHScale());
      _currentX = _sampleIndex * sampleWidth;
      _currentY = y1;
      // line(x0, y0, x1, y1);
    }
  }

  public void Render()
  {
    super.Render();
    int x = Transform.GetX();
    int y = Transform.GetY();
    int w = Transform.GetW();
    int h = Transform.GetH();
    float currentX = (float)_sampleIndex / _sampleCount * w + x;
    float currentY = GetYPosition(GetCurrentValue()) + y;

    // Background
    noStroke();
    fill(30);
    rect(x, y + 2f, w, h - 4f);

    noFill();
    // Axis second marks
    stroke(40);
    strokeWeight(1f * app.GetHScale());
    strokeCap(SQUARE);
    int secondsCount = _sampleCount / app.FRAME_RATE;
    float secondWidth = (float)w / _sampleCount * app.FRAME_RATE;
    for (int i = 1; i < secondsCount; i++)
    {
      int secondX = (int)(i * secondWidth + x);
      line(secondX, y + 2f, secondX, y + h - 4f);
    }

    // Origin Axis
    stroke(180);
    strokeWeight(1f);
    line(x, _originY + y, w, _originY + y);

    // Curve
    noFill();
    strokeCap(ROUND);
    strokeWeight(2f * app.GetHScale());
    float x0 = 0f;
    float y0 = GetYPosition(_samplesValue[0]);
    color c0 = _samplesBGColor[0];
    int steps = w < _sampleCount ? w : _sampleCount;
    float stepSize = (float)w / steps;
    for (int i = 1; i < steps; i++)
    {
      float x1 = i * stepSize;
      int sampleI = (int)(x1 / w * _sampleCount);
      float y1 = GetYPosition(_samplesValue[sampleI]);

      float deltaCurrentIndex = (float)(sampleI - _sampleIndex);
      deltaCurrentIndex = deltaCurrentIndex >= 0 && deltaCurrentIndex < 2 * stepSize ? 0f : deltaCurrentIndex;
      float alpha = min(1f, deltaCurrentIndex / FADE_SAMPLES_COUNT);
      alpha = alpha < 0f ? 1f : alpha;
      stroke(_colorLine, alpha * 255f);
      line(x + x0, y + y0, x + x1, y + y1);
      x0 = x1;
      y0 = y1;
      // c0 = c1;
    }

    // Current Value Dot
    fill(_colorDot);
    noStroke();
    circle(currentX, currentY, 5.0f * app.GetHScale());
  }
}
