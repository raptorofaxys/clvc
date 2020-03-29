public class VUtils
{
    static int GetHash(byte[] buf, int startIndex, int endIndex)
    {
        int hash = 0x811c9dc5;
        // for (byte b: buf)
        for (int i = startIndex; i < endIndex; ++i)
        {
            hash ^= buf[i];
            // PApplet.println("Hash after XOR : " + Integer.toHexString(hash));
            hash *= 0x01000193;
            // PApplet.println("Hash after mult: " + Integer.toHexString(hash));
        }
        
        return hash;
    }
}
