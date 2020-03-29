#include <Servo.h>

const int PIN_O2_VALVE = 4;
const int PIN_AIR_VALVE = 5;

/////////////////////////////
// General utilities
/////////////////////////////

void Blink(long ms = 250)
{
    digitalWrite(13, HIGH);
    delay(ms);
    digitalWrite(13, LOW);
    delay(ms);
}

#define assert(x, msg) if (!(x)) { Halt(__LINE__, msg); }
#define verify(x, msg) assert(x, msg)
#define HALT() Halt(__LINE__, "Halt")

template <class T>
void Halt(int line, const T* msg)
{
    Serial.print(F("Halt: L"));
    Serial.println(line);
    Serial.println(msg);
    Serial.flush();
    pinMode(13, OUTPUT);
    for (;;)
    {
        Blink(250);
    }
}

#define ARRAY_COUNT(x) (static_cast<int>(sizeof(x) / sizeof(x[0])))

float Clamp01(float v)
{
    return min(max(v, 0.0f), 1.0f);
}

/////////////////////////////
// Printing and formatting
/////////////////////////////

#define DEFAULT_PRINT (&Serial)
#define DEFAULT_FLOAT_DECIMALS 1

void Ln(Print* p = DEFAULT_PRINT)
{
    p->println("");
}

void ClearScreen(Print* p = DEFAULT_PRINT)
{
    p->print("\x1B[2J");
}

void MoveCursor(int x, int y, Print* p = DEFAULT_PRINT)
{
    p->print("\x1B[");
    p->print(y + 1);
    p->print(";");
    p->print(x + 1);
    p->print("H");
}

void Space(Print* p = DEFAULT_PRINT)
{
    p->print(" ");
}

void Cls(Print* p = DEFAULT_PRINT)
{
    p->print(char(27));
    p->print("[2J");
}

void PrintFloat(float f, int decimals = DEFAULT_FLOAT_DECIMALS, Print* p = DEFAULT_PRINT)
{
    if (f < 0)
    {
        p->print("-");
        f = -f;
    }
    else
    {
        p->print(" ");
    }

    int b = int(f);
    p->print(b);
    p->print(".");
    f -= b;
    for (int i = 0; i < decimals; ++i)
    {
        f *= 10.0f;
        int a = int(f);
        p->print(a);
        f -= a;
    }
}

void PrintHex16(uint16_t h, Print* p = DEFAULT_PRINT)
{
    static char const* hex = "0123456789ABCDEF";
    p->print(hex[(h & 0xF000) >> 12]);
    p->print(hex[(h & 0x0F00) >> 8]);
    p->print(hex[(h & 0x00F0) >> 4]);
    p->print(hex[(h & 0x000F) >> 0]);
}

void PrintHex32(uint32_t h, Print* p = DEFAULT_PRINT)
{
    static char const* hex = "0123456789ABCDEF";
    p->print(hex[(h & 0xF0000000) >> 28]);
    p->print(hex[(h & 0x0F000000) >> 24]);
    p->print(hex[(h & 0x00F00000) >> 20]);
    p->print(hex[(h & 0x000F0000) >> 16]);
    p->print(hex[(h & 0x0000F000) >> 12]);
    p->print(hex[(h & 0x00000F00) >> 8]);
    p->print(hex[(h & 0x000000F0) >> 4]);
    p->print(hex[(h & 0x0000000F) >> 0]);
}

void PrintStringChar(char const* s, char c, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": ");
    p->print(c);
}

void PrintStringInt(const __FlashStringHelper *s, int v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": ");
    p->print(v);
}

void PrintStringInt(char const* s, int v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": ");
    p->print(v);
}

void PrintStringLong(const __FlashStringHelper *s, long v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": ");
    p->print(v);
}

void PrintStringLong(char const* s, long v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": ");
    p->print(v);
}

void PrintStringHex32(const __FlashStringHelper *s, uint32_t v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": 0x");
    PrintHex32(v);
}

void PrintStringHex32(char const* s, uint32_t v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": 0x");
    PrintHex32(v);
}

void PrintFormattedFloat(float f, int decimals = DEFAULT_FLOAT_DECIMALS, Print* p = DEFAULT_PRINT)
{
    p->print(": ");
    // if (f < 10000.0f)
    // {
    //     p->print(" ");
    // }
    // if (f < 1000.0f)
    // {
    //     p->print(" ");
    // }
    if (f < 100.0f)
    {
        p->print(" ");
    }
    if (f < 10.0f)
    {
        p->print(" ");
    }
    PrintFloat(f, decimals);
}

void PrintStringFloat(const __FlashStringHelper *s, float f, int decimals = DEFAULT_FLOAT_DECIMALS, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    PrintFormattedFloat(f, decimals, p);
}

void PrintStringFloat(char const* s, float f, int decimals = DEFAULT_FLOAT_DECIMALS, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    PrintFormattedFloat(f, decimals, p);
}

/////////////////////////////
// Proportional valve output
/////////////////////////////

class ProportionalValve
{
public:
	ProportionalValve(int pin)
	{
		_servo.attach(pin, 500, 2350);
	}

	void SetPosition(float position01)
	{
		int angle = int(0 + (position01) * 180);
		_servo.write(angle);
	}

private:
	Servo _servo;
};

/////////////////////////////
// Initialization and control loop
/////////////////////////////

void setup()
{
    pinMode(13, OUTPUT);

    Serial.begin(9600);
    while (!Serial);
}

#define ENABLE_O2_VALVE_SERVO 1
#define ENABLE_AIR_VALVE_SERVO 1

void loop()
{
    Blink(100);
    Blink(100);
    Blink(100);

#if ENABLE_O2_VALVE_SERVO
    ProportionalValve o2Valve(PIN_O2_VALVE);
#endif
#if ENABLE_AIR_VALVE_SERVO
    ProportionalValve airValve(PIN_AIR_VALVE);
#endif

    for (;;)
    {
        long nowMs = millis();
        float seconds = nowMs / 1000.0f;
        float position = sin(seconds) * 0.5f + 0.5f;
#if ENABLE_O2_VALVE_SERVO
        o2Valve.SetPosition(position);
#endif

#if ENABLE_AIR_VALVE_SERVO
        airValve.SetPosition(position);
#endif
    }
}