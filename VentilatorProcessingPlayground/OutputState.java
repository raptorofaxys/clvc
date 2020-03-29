import processing.core.*;

import java.nio.ByteOrder;
import java.nio.ByteBuffer;
import java.util.Arrays;

class OutputState
{
    final static int kNumFloats = 6;

    // int LowO2ServoEndpoint;
    // int HighO2ServoEndpoint;

    public float InhalationPressure = 0.0f;
    public float InhalationFlow = 0.0f;

    public float ExhalationPressure = 0.0f;
    public float ExhalationFlow = 0.0f;

    public float O2ValveAngle = 0.0f;
    public float AirValveAngle = 0.0f;

    public int SerializedHash;
    public int ComputedHash;

    public boolean IsValid()
    {
        return SerializedHash == ComputedHash;
    }

    private OutputState() {}

    public static int GetSerializedSize()
    {
        return GetPayloadSize() + 4; // 4 bytes for the hash
    }

    static int GetPayloadSize()
    {
        return kNumFloats * 4;
    }

    static int GetHash(byte[] buf)
    {
        int hash = 0x811c9dc5;
        for (byte b: buf)
        {
            hash ^= b;
            // PApplet.println("Hash after XOR : " + Integer.toHexString(hash));
            hash *= 0x01000193;
            // PApplet.println("Hash after mult: " + Integer.toHexString(hash));
        }
        
        return hash;
    }

    public static OutputState Deserialize(byte[] buf)
    {
        byte[] payload = Arrays.copyOfRange(buf, 0, GetPayloadSize());
        int hash = GetHash(payload);

        ByteBuffer bb = ByteBuffer.wrap(buf).order(ByteOrder.LITTLE_ENDIAN);
        bb.rewind();

        OutputState os = new OutputState();

        os.InhalationPressure = bb.getFloat();
        os.InhalationFlow  = bb.getFloat();

        os.ExhalationPressure = bb.getFloat();
        os.ExhalationFlow  = bb.getFloat();

        os.O2ValveAngle = bb.getFloat();
        os.AirValveAngle = bb.getFloat();

        int serializedHash = bb.getInt();

        // println(hash);
        // println(serializedHash);
        os.SerializedHash = serializedHash;
        os.ComputedHash = hash;

        return os;
    }

}
