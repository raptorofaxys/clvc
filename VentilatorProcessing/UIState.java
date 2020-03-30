import processing.core.*;

import java.nio.ByteOrder;
import java.nio.ByteBuffer;
import java.util.Arrays;

class UIState extends SerializedState
{
    final static int kNumFloats = 9;
    final static int kNumInts = 0;
    final static int kNumChars = 2;
    final static int kNumBytes = 3;

    float FiO2;                                     // 0-1 ratio: 1.0 is 100% O2
    
    byte ControlMode;                               // 0: no trigger, 1: pressure control, 2: volume control

    // If pressure control mode:
    float PressureControlInspiratoryPressure;       // cmH2O

    // If volume control mode:
    float VolumeControlMaxPressure;                 // cmH2O
    float VolumeControlTidalVolume;                 // ml

    float Peep;                                     // cmH2O

    float InspirationTime;                          // s

    float InspirationFilterRate;                    // IIR filter rate - how much error remains after one second: 0.1 means 10% of error remains after one second
    float ExpirationFilterRate;                     // IIR filter rate

    byte TriggerMode;                               // 0: no trigger, 1: timer, 2: patient effort

    char TimerTriggerBreathsPerMin;                 // breaths/min

    char PatientEffortTriggerMinBreathsPerMin;      // breaths/min
    float PatientEffortTriggerLitersPerMin;         // L/min

    byte BreathManuallyTriggered;                   // 1: yes, 0:no

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

    public byte[] Serialize()
    {
        ByteBuffer bb =  ByteBuffer.allocate(GetSerializedSize()).order(ByteOrder.LITTLE_ENDIAN);

        // PApplet.println(bb.array().length);

        // byte[] payload = Arrays.copyOfRange(buf, 0, GetPayloadSize());

        bb.putFloat(FiO2);
        bb.put(ControlMode);
        bb.putFloat(PressureControlInspiratoryPressure);
        bb.putFloat(VolumeControlMaxPressure);
        bb.putFloat(VolumeControlTidalVolume);
        bb.putFloat(Peep);
        bb.putFloat(InspirationTime);
        bb.putFloat(InspirationFilterRate);
        bb.putFloat(ExpirationFilterRate);
        bb.put(TriggerMode);
        bb.putChar(TimerTriggerBreathsPerMin);
        bb.putChar(PatientEffortTriggerMinBreathsPerMin);
        bb.putFloat(PatientEffortTriggerLitersPerMin);
        bb.put(BreathManuallyTriggered);

        byte[] array = bb.array();
        int hash = VUtils.GetHash(array, 0, GetPayloadSize());
        bb.putInt(hash);

        return array;
    }

    public void TriggerBreath()
    {
        BreathManuallyTriggered = 1;
    }

    public void ResetEvents()
    {
        BreathManuallyTriggered = 0;
    }
}
