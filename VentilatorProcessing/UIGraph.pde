class UIGraph extends UIElement
{
  private int _sampleCount;
  private float[] _samples;
  private float _originY;

  private int _sampleIndex;

  public UIGraph(float fracW, float fracH, int sampleCount, float originY)
  {
    super(fracW, fracH);
    _sampleCount = sampleCount;
    _samples = new float[sampleCount];
    _originY = originY;
  }

  private void NextSample()
  {
    _sampleIndex += 1;
    _sampleIndex = _sampleIndex >= _sampleCount ? 0 : _sampleIndex;
  }

  private float GetPrevSample()
  {
    int i = _sampleIndex;
    i -= 1;
    i = i < 0 ? _sampleCount - 1 : i;

    return _samples[i];
  }

  private float GetCurrentSample()
  {
    return _samples[_sampleIndex];
  }

  public void Update()
  {
    NextSample();
    _samples[_sampleIndex] = noise(second() + millis()) - 0.5;
  }

  public void Render()
  {
    int x = Transform.GetX();
    int y = Transform.GetY();
    int w = Transform.GetW();
    int h = Transform.GetH();
    float sampleWidth = (float)w / (float)_sampleCount;

    float x1 = _sampleIndex * sampleWidth + x;
    float x0 = x1 - sampleWidth;
    noStroke();
    for (int i = 0; i < 5; i++)
    {
      fill(0, 255 * (5 - i) / 5);
      rect(x1 + sampleWidth * i, y, sampleWidth, h);
    }

    if (_sampleIndex != _sampleCount - 1)
    {
      float halfHeight = h * 0.5;
      float y0 = -GetPrevSample() * h + halfHeight + y;
      float y1 = -GetCurrentSample() * h + halfHeight + y;

      noFill();
      stroke(#00ff99);
      strokeWeight(1);
      line((int)x0, (int)y0, (int)x1, (int)y1);
    }
  }
}
