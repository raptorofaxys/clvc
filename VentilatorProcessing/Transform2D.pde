class Transform2D
{
  private int _x, _y;
  private int _w, _h;
  private int _minW, _minH;
  private int _maxW, _maxH;

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

  public Transform2D() {}

  public Transform2D(int x, int y, int w, int h)
  {
    _x = x;
    _y = y;
    _w = w;
    _h = h;
  }
}
