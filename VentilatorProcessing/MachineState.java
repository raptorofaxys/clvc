import processing.core.*;

import java.nio.ByteOrder;
import java.nio.ByteBuffer;
import java.util.Arrays;

class MachineState extends SerializedState
{
    final static int kNumFloats = 25;
    final static int kNumInts = 1;
    final static int kNumChars = 0;
    final static int kNumBytes = 2;

    float InstantInhalationPressure;                // cmH2O
    float InstantInhalationFlow;                    // L/min

    float InstantExhalationPressure;                // cmH2O
    float InstantExhalationFlow;                    // L/min

    float InstantO2ValveOpening;                    // degrees
    float InstantAirValveOpening;                   // degrees

    float InstantTotalVolume;                       // L
    
    float InstantTotalFlowLitersPerMin;                    // L/min

    float MinuteExhalationLitersPerMin;             // L/min
    float RespiratoryFrequencyBreathsPerMin;        // breaths/min

    float InhalationTidalVolume;                    // L
    float ExhalationTidalVolume;                    // L

    float PressurePeak;                             // cmH2O
    float PressureMean;                             // cmH2O
    float PressurePlateau;                          // cmH2O
    float PressurePeep;                             // cmH2O

    float EffectiveInspirationTime;                 // s
    float IERatio;                                  // unitless; how long expiration is compared to inspiration

    byte InstantBreathPhase;                        // 0: Inhalation, 1: Exhalation, 2: Rest

    float RawUIMessagesPerSecond;                   // count/s
    float ValidUIMessagesPerSecond;                 // count/s
    float MachineStateMessagesPerSecond;            // count/s

    float Debug1;
    float Debug2;
    float Debug3;
    float Debug4;
    
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

        os.InstantInhalationPressure = bb.getFloat();
        os.InstantInhalationFlow  = bb.getFloat();

        os.InstantExhalationPressure = bb.getFloat();
        os.InstantExhalationFlow  = bb.getFloat();

        os.InstantO2ValveOpening = bb.getFloat();
        os.InstantAirValveOpening = bb.getFloat();

        os.InstantTotalVolume = bb.getFloat();

        os.InstantTotalFlowLitersPerMin = bb.getFloat();

        os.MinuteExhalationLitersPerMin = bb.getFloat();
        os.RespiratoryFrequencyBreathsPerMin = bb.getFloat();

        os.InhalationTidalVolume = bb.getFloat();
        os.ExhalationTidalVolume = bb.getFloat();

        os.PressurePeak = bb.getFloat();
        os.PressureMean = bb.getFloat();
        os.PressurePlateau = bb.getFloat();
        os.PressurePeep = bb.getFloat();

        os.EffectiveInspirationTime = bb.getFloat();
        os.IERatio = bb.getFloat();
        
        os.InstantBreathPhase = bb.get();
        
        os.RawUIMessagesPerSecond = bb.getFloat();
        os.ValidUIMessagesPerSecond = bb.getFloat();
        os.MachineStateMessagesPerSecond = bb.getFloat();

        os.Debug1 = bb.getFloat();
        os.Debug2 = bb.getFloat();
        os.Debug3 = bb.getFloat();
        os.Debug4 = bb.getFloat();

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
