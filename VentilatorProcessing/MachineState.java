import processing.core.*;

import java.nio.ByteOrder;
import java.nio.ByteBuffer;
import java.util.Arrays;

class MachineState extends SerializedState
{
    final static int kNumFloats = 15;
    final static int kNumBytes = 1;

    float InhalationPressure;                       // cmH2O
    float InhalationFlow;                           // L/min

    float ExhalationPressure;                       // cmH2O
    float ExhalationFlow;                           // L/min

    float O2ValveAngle;                             // degrees
    float AirValveAngle;                            // degrees

    float TotalFlowLitersPerMin;                    // L/min

    float MinuteVentilationLitersPerMin;            // L/min
    float RespiratoryFrequencyBreathsPerMin;        // breaths/min

    float InhalationTidalVolume;                    // ml
    float ExhalationTidalVolume;                    // ml

    float PressurePeak;                             // cmH2O
    float PressurePlateau;                          // cmH2O
    float PressurePeep;                             // cmH2O

    float IERatio;                                  // unitless

    byte LastReceiveValid;

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
        return kNumFloats * 4 + kNumBytes * 1;
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

        os.TotalFlowLitersPerMin = bb.getFloat();

        os.MinuteVentilationLitersPerMin = bb.getFloat();
        os.RespiratoryFrequencyBreathsPerMin = bb.getFloat();

        os.InhalationTidalVolume = bb.getFloat();
        os.ExhalationTidalVolume = bb.getFloat();

        os.PressurePeak = bb.getFloat();
        os.PressurePlateau = bb.getFloat();
        os.PressurePeep = bb.getFloat();

        os.IERatio = bb.getFloat();
        
        os.LastReceiveValid = bb.get();

        int serializedHash = bb.getInt();

        // println(hash);
        // println(serializedHash);
        os.SerializedHash = serializedHash;
        os.ComputedHash = hash;

        return os;
    }

}
