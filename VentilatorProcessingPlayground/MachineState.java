import processing.core.*;

import java.nio.ByteOrder;
import java.nio.ByteBuffer;
import java.util.Arrays;

class MachineState extends SerializedState
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

    public boolean IsValid()
    {
        return SerializedHash == ComputedHash;
    }

    private MachineState() {}

    public static int GetSerializedSize()
    {
        return GetPayloadSize() + 4; // 4 bytes for the hash
    }

    static int GetPayloadSize()
    {
        return kNumFloats * 4;
    }

    public static MachineState Deserialize(byte[] buf)
    {
//        byte[] payload = Arrays.copyOfRange(buf, 0, GetPayloadSize());
        int hash = VUtils.GetHash(buf, 0, GetPayloadSize());

        ByteBuffer bb = ByteBuffer.wrap(buf).order(ByteOrder.LITTLE_ENDIAN);
        // bb.rewind();

        MachineState os = new MachineState();

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
