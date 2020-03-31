import processing.core.*;

import java.nio.ByteOrder;
import java.nio.ByteBuffer;
import java.util.Arrays;

class MachineState extends SerializedState
{
    final static int kNumFloats = 28;
    final static int kNumInts = 1;
    final static int kNumChars = 0;
    final static int kNumBytes = 2;

    float InhalationPressure;                       // cmH2O
    float InhalationFlow;                           // L/min

    float ExhalationPressure;                       // cmH2O
    float ExhalationFlow;                           // L/min

    float O2ValveOpening;                           // degrees
    float AirValveOpening;                          // degrees

    float TotalFlowLitersPerMin;                    // L/min

    float MinuteVentilationLitersPerMin;            // L/min
    float RespiratoryFrequencyBreathsPerMin;        // breaths/min

    float InhalationTidalVolume;                    // ml
    float ExhalationTidalVolume;                    // ml

    float PressurePeak;                             // cmH2O
    float PressureMean;                             // cmH2O
    float PressurePlateau;                          // cmH2O
    float PressurePeep;                             // cmH2O

    float EffectiveInspirationTime;                 // s
    float IERatio;                                  // unitless; how long expiration is compared to inspiration

    byte BreathPhase;                               // 0: Inhalation, 1: Exhalation, 2: Rest

    float RawUIMessagesPerSecond;                   // count/s
    float ValidUIMessagesPerSecond;                 // count/s
    float MachineStateMessagesPerSecond;            // count/s

    float Debug1;
    float Debug2;
    float Debug3;
    float Debug4;
    float Debug5;
    float Debug6;
    float Debug7;
    float Debug8;
    
    byte LastReceiveValid;
    int ErrorMask;

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
        return kNumFloats * 4
        + kNumInts * 4
        + kNumChars * 2
        + kNumBytes * 1;
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

        os.O2ValveOpening = bb.getFloat();
        os.AirValveOpening = bb.getFloat();

        os.TotalFlowLitersPerMin = bb.getFloat();

        os.MinuteVentilationLitersPerMin = bb.getFloat();
        os.RespiratoryFrequencyBreathsPerMin = bb.getFloat();

        os.InhalationTidalVolume = bb.getFloat();
        os.ExhalationTidalVolume = bb.getFloat();

        os.PressurePeak = bb.getFloat();
        os.PressureMean = bb.getFloat();
        os.PressurePlateau = bb.getFloat();
        os.PressurePeep = bb.getFloat();

        os.EffectiveInspirationTime = bb.getFloat();
        os.IERatio = bb.getFloat();
        
        os.BreathPhase = bb.get();
        
        os.RawUIMessagesPerSecond = bb.getFloat();
        os.ValidUIMessagesPerSecond = bb.getFloat();
        os.MachineStateMessagesPerSecond = bb.getFloat();

        os.Debug1 = bb.getFloat();
        os.Debug2 = bb.getFloat();
        os.Debug3 = bb.getFloat();
        os.Debug4 = bb.getFloat();
        os.Debug5 = bb.getFloat();
        os.Debug6 = bb.getFloat();
        os.Debug7 = bb.getFloat();
        os.Debug8 = bb.getFloat();

        os.LastReceiveValid = bb.get();
        os.ErrorMask = bb.getInt();

        int serializedHash = bb.getInt();

        // println(hash);
        // println(serializedHash);
        os.SerializedHash = serializedHash;
        os.ComputedHash = hash;

        return os;
    }

}
