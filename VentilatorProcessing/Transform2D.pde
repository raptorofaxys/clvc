class Transform2D
{
  private int _x, _y;
  private int _w, _h;
  private int _minW, _minH;
  private int _maxW, _maxH;

  public Transform2D() {}

  public Transform2D(int x, int y, int w, int h)
  {
    _x = x;
    _y = y;
    _w = w;
    _h = h;
  }

  int GetX() { return _x; }
  int GetY() { return _y; }
  int GetW() { return _w; }
  int GetH() { return _h; }

  void SetX(int value) { _x = value; }
  void SetY(int value) { _y = value; }

  void SetXY(int x, int y)
  {
    _x = x;
    _y = y;
  }

  int SetW(int value)
  {
    _w = max(value, _minW);
    if (_maxW > 0)
      _w = min(_w, _maxW);

    return _w;
  }

  int SetH(int value)
  {
    _h = max(value, _minH);
    if (_maxH > 0)
      _h = min(_h, _maxH);

    return _h;
  }

  void SetWH(int w, int h)
  {
    SetW(w);
    SetH(h);
  }

  void SetMinWH(int minW, int minH)
  {
    _minW = minW;
    _minH = minH;
    SetWH(_w, _h);
  }

  void SetMaxWH(int maxW, int maxH)
  {
    _maxW = maxW;
    _maxH = maxH;
    SetWH(_w, _h);
  }
}

class Padding
{
  private float _l, _r, _t, _b, _w, _h;

  public Padding() {}

  public Padding(float l, float r, float t, float b)
  {
    _l = l;
    _r = r;
    _t = t;
    _b = b;
    _w = l + r;
    _h = t + b;
  }

  public Padding(float horizontal, float vertical)
  {
    this(horizontal, horizontal, vertical, vertical);
  }

  public Padding(float all)
  {
    this(all, all, all, all);
  }

  public float GetL() { return _l * app.GetHScale(); }
  public float GetR() { return _r * app.GetHScale(); }
  public float GetT() { return _t * app.GetHScale(); }
  public float GetB() { return _b * app.GetHScale(); }
  public float GetW() { return _w * app.GetHScale(); }
  public float GetH() { return _h * app.GetHScale(); }

  public void SetL(float value)
  {
    _l = value;
    _w = _r + _l;
  }

  public void SetR(float value)
  {
    _r = value;
    _w = _r + _l;
  }

  public void SetT(float value)
  {
    _t = value;
    _h = _t + _b;
  }

  public void SetB(float value)
  {
    _b = value;
    _h = _t + _b;
  }

  public void SetAll(float value)
  {
    _l = _r = _t = _b = value;
    _w = _h = value + value;
  }

  public void SetHorizontal(float value)
  {
    _l = _r = value;
    _w = value + value;
  }

  public void SetVertical(float value)
  {
    _t = _b = value;
    _h = value + value;
  }
}
