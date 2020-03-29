import processing.serial.*;
Serial port;

// void DumpBuffer()

void setup()
{
    size(400, 400);

    // println(Serial.list());

    port = new Serial(this, "COM7", 9600);
}

void draw()
{
    // if (port.available() > 0)
    // {
    //     byte[] bytes = port.readBytes();
    //     for (byte b: bytes)
    //     {
    //         println(b);
    //     }
    // }
    int size = OutputState.GetSerializedSize();
    if (port.available() >= size)
    {
        byte[] bytes = port.readBytes(size);

        OutputState os = OutputState.Deserialize(bytes);

        println(os.InhalationPressure);
        println(os.InhalationFlow);
        println(os.ExhalationPressure);
        println(os.ExhalationFlow);
        println(os.O2ValveAngle);
        println(os.AirValveAngle);
        println(os.SerializedHash);
        println(os.ComputedHash);
        println(os.IsValid());

        // for (byte b: bytes)
        // {
        //     print(b);
        //     print(" ");
        // }
        // println();
    }
}
