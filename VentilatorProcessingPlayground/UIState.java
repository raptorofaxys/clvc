import processing.core.*;

import java.nio.ByteOrder;
import java.nio.ByteBuffer;
import java.util.Arrays;

class UIState extends SerializedState
{
    final static int kNumFloats = 2;

    public float P1 = 0.0f;
    public float P2 = 0.0f;

    public static int GetSerializedSize()
    {
        return GetPayloadSize() + 4; // 4 bytes for the hash
    }

    static int GetPayloadSize()
    {
        return kNumFloats * 4;
    }

    public byte[] Serialize()
    {
        ByteBuffer bb =  ByteBuffer.allocate(GetSerializedSize()).order(ByteOrder.LITTLE_ENDIAN);

        // PApplet.println(bb.array().length);

        // byte[] payload = Arrays.copyOfRange(buf, 0, GetPayloadSize());

        bb.putFloat(P1);
        bb.putFloat(P2);

        byte[] array = bb.array();
        int hash = VUtils.GetHash(array, 0, GetPayloadSize());
        bb.putInt(hash);

        return array;
    }

}
