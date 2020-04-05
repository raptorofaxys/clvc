public void GradientVertical(float x, float y, float w, int h, color c1, int alpha1, color c2, int alpha2)
{
  for (int i = 0; i < h; i++)
  {
    float ratio = (float)i / h;
    fill(lerpColor(c1, c2, ratio), lerp(alpha1, alpha2, ratio));
    rect(x, y + i, w, 1);
  }
}
