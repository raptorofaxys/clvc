import processing.serial.*;
Serial port;

// void DumpBuffer()

void setup()
{
    size(400, 400);

    // println(Serial.list());

    port = new Serial(this, "COM7", 9600);
}

long lastSendMs;

void draw()
{
    // if (port.available() > 0)
    // {
    //     byte[] bytes = port.readBytes();
    //     for (byte b: bytes)
    //     {
    //         print((char)b);
    //     }
    // }
    
    int size = MachineState.GetSerializedSize();
    if (port.available() >= size)
    {
        byte[] bytes = port.readBytes(size);

        MachineState ms = MachineState.Deserialize(bytes);

        println(ms.InhalationPressure);
        println(ms.InhalationFlow);
        println(ms.ExhalationPressure);
        println(ms.ExhalationFlow);
        println(ms.O2ValveAngle);
        println(ms.AirValveAngle);
        println(ms.SerializedHash);
        println(ms.ComputedHash);
        println(ms.IsValid());
    }

    long nowMs = millis();
    if (nowMs - lastSendMs > 1000)
    {
        UIState us = new UIState();
        us.P1 = 1.0f;
        us.P2 = 2.0f;
        byte[] packet = us.Serialize();

        port.write(packet);

        lastSendMs = nowMs;
    }
}
