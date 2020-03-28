// COVent-19 control firmware

// Inputs:
// -Inhalation pressure sensor: analog input A0
// -Exhalation pressure sensor: analog input A1
// -Inhalation flow sensor: hardware I2C on pins A4/A5
// -Exhalation flow sensor: software I2C on pins D2/D3

// Outputs:
// -speaker (for alarm): D10
// -proportional O2 valve: servo on D4
// -proportional air valve: servo on D5

#include <Wire.h>
#include <SoftwareWire.h>
#include <Servo.h>

/////////////////////////////
// Hardware configuration
/////////////////////////////

// Beware: some pins may not be able to assume all functions
const int PIN_SOFTWARE_I2C_SDA = 2;
const int PIN_SOFTWARE_I2C_SCL = 3;

const int PIN_INHALE_PRESSURE_SENSOR = A0;
const int PIN_EXHALE_PRESSURE_SENSOR = A1;

const int PIN_ALARM_SPEAKER = 10;

const int PIN_O2_VALVE = 4;
const int PIN_AIR_VALVE = 5;

/////////////////////////////
// General utilities
/////////////////////////////

#define assert(x, msg) if (!(x)) { Halt(__LINE__, msg); }
#define verify(x, msg) assert(x, msg)
#define HALT() Halt(__LINE__, "Halt")
inline void Halt(int line, const __FlashStringHelper* msg)
{
    Serial.print(F("Halt: L"));
    Serial.println(line);
    Serial.println(msg);
    Serial.flush();
    for (;;) {}
}

inline void Halt(int line, const char* msg)
{
    Serial.print(F("Halt: L"));
    Serial.println(line);
    Serial.println(msg);
    Serial.flush();
    for (;;) {}
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
// Button input
/////////////////////////////

class PushButton
{
public:
    PushButton(int pin, bool activeLow = true)
        : _pin(pin)
        , _debounceStart(0)
        , _activeLow(activeLow)
    {
        pinMode(_pin, INPUT_PULLUP);
        _lastValue = _activeLow ? 1 : 0;
        _lastHeld = false;
    }

    void Update()
    {
        _justPressed = false;
        _justRelease = false;
        _justHeld = false;

        unsigned long nowMs = millis();

        if (nowMs < _debounceStart + kDebounceMs)
        {
            return;
        }

        int buttonValue = digitalRead(_pin);
        int const ACTIVE = _activeLow ? 0 : 1;
        int const INACTIVE = 1 - ACTIVE;
        if ((_lastValue == INACTIVE) && (buttonValue == ACTIVE))
        {
            _debounceStart = nowMs;
            _justPressed = true;
            _lastHeld = false;
        }
        else if ((_lastValue == ACTIVE) && (buttonValue == INACTIVE))
        {
            _debounceStart = nowMs;
            _justRelease = true;
        }

        if ((buttonValue == ACTIVE) && !_lastHeld && (nowMs > _debounceStart + kHeldMs))
        {
            _justHeld = true;
            _lastHeld = true;
        }

        _lastValue = buttonValue;
    }

    bool IsPressed() { return _lastValue == (_activeLow ? 0 : 1); }
    bool JustPressed() { return _justPressed; }
    bool IsHeld() { return IsPressed() && _lastHeld; }
    bool JustHeld() { return _justHeld; }
    bool JustReleased() { return _justRelease; }
    bool JustReleasedAndWasHeld() { return _justRelease && _lastHeld; }
    bool JustReleasedAndWasNotHeld() { return _justRelease && !_lastHeld; }

    void WaitForPress()
    {
        for (; !JustPressed(); Update());
        Update();
    }

private:
    static const int kDebounceMs = 25;
    static const int kHeldMs = 800;

    char _pin;
    char _lastValue;
    bool  _lastHeld;
    unsigned long _debounceStart;
    bool _activeLow;
    bool _justPressed;
    bool _justHeld;
    bool _justRelease;
};

/////////////////////////////
// Sound
/////////////////////////////

class NoiseMaker
{
public:
    NoiseMaker(int pinNumber)
        : _pin(pinNumber)
        , _enabled(true)
    {
        noTone(_pin);
        _lastMs = 0;
        
        _pitch = 440.0f;
        _stepsLeft = 0;
        _stepLengthMs = 0;
        _pitchNudge = 1.0f;
        
        _minPitch = 0.0f;
        _pitchBump = 1.0f;
    }

    void Tick()
    {
        _pitch = 700.0f;
        _stepsLeft = 5;
        _stepLengthMs = 5;
        _pitchNudge = 1.2f;
        
        _minPitch = 0.0f;
        _pitchBump = 1.0f;
    }

    void Tock()
    {
        _pitch = 700.0f * 1.3f;
        _stepsLeft = 5;
        _stepLengthMs = 5;
        _pitchNudge = 1.2f * 1.3f;
        
        _minPitch = 0.0f;
        _pitchBump = 1.0f;
    }

    void Bleep()
    {
        _pitch = 500.0f;
        _stepsLeft = 4;
        _stepLengthMs = 20;
        _pitchNudge = 1.15f;
        
        _minPitch = 0.0f;
        _pitchBump = 1.0f;
    }

    void Bloop()
    {
        _pitch = 500.0f * 1.3f;
        _stepsLeft = 4;
        _stepLengthMs = 20;
        _pitchNudge = 1.15f * 1.3f;
        
        _minPitch = 0.0f;
        _pitchBump = 1.0f;
    }

    void BombDrop()
    {
        _minPitch = 130.0f;
        _pitchNudge = 0.63f;
        _pitchBump = 2.5f;
        _pitch = _minPitch * _pitchBump;
        _stepsLeft = 120;
        _stepLengthMs = 10;
    }

    void Laser()
    {
        _minPitch = 500.0f;
        _pitchNudge = 0.71f;
        _pitchBump = 4.1f;
        _pitch = _minPitch * _pitchBump;
        _stepsLeft = 138;
        _stepLengthMs = 4;
    }

    void Spring()
    {
        _minPitch = 400.0f;
        _pitchNudge = 0.71f;
        _pitchBump = 4.1f;
        _pitch = _minPitch * _pitchBump;
        _stepsLeft = 38;
        _stepLengthMs = 28;
    }

    bool IsEnabled()
    {
        return _enabled;
    }

    void SetEnabled(bool enabled)
    {
        _enabled = enabled;
    }

    void Update()
    {
        long nowMs = millis();

        if (!_enabled)
        {
            _stepsLeft = 0;
        }

        if (_stepsLeft > 0)
        {
            if ((_stepLengthMs > 0) && (nowMs - _lastMs >= _stepLengthMs))
            {
                _pitch *= _pitchNudge;
                if (_pitch < _minPitch)
                {
                    _pitch *= _pitchBump;
                }

                _lastMs = nowMs;

                --_stepsLeft;
            }
        }

        if (_stepsLeft > 0)
        {
            // PrintStringInt("p", _pitch); Ln();
            tone(_pin, static_cast<int>(_pitch));
        }
        else
        {
            // Serial.print("N"); Ln();
            noTone(_pin);
        }
    }

private:
    int _pin;
    bool _enabled;

    long _lastMs;

    int _stepLengthMs;
    int _stepsLeft;

    float _pitch;
    float _pitchNudge;

    float _minPitch;
    float _pitchBump;
};

/////////////////////////////
// Pressure sensor input
/////////////////////////////

class PressureSensor
{
public:
    PressureSensor(int pin)
        : _pin(pin)
    {
        pinMode(_pin, INPUT);
    }

    float GetPressurePsi()
    {
        int rawValue = analogRead(_pin);
        float v01 = rawValue / 1023.0f;
        return UnitSampleToPsi(v01);
    }

private:
    float UnitSampleToPsi(float v01)
    {
        const float kMinPsi = 0.0f;
        const float kMaxPsi = 1.0f;

        return ((v01 - 0.1f) * (kMaxPsi - kMinPsi) / 0.8f) + kMinPsi;
    }

    char _pin;
};

/////////////////////////////
// Flow sensor input
/////////////////////////////

template <class I2C>
class FlowSensor
{
public:
    FlowSensor(I2C& i2c)
        : _i2c(i2c)
    {
        EnsureDeviceIsResponsive();

        // Discard the first two bytes, which may or may not be the serial depending on how long it's been since boot
        ReadTwoBytes();
        CommandDelay();
        ReadTwoBytes();
        CommandDelay();

        // Request serial number
        _i2c.beginTransmission(kI2cAddress);
        _i2c.write(0x01);
        _i2c.endTransmission();
        CommandDelay();

        // Read serial number
        uint16_t serialHigh = ReadTwoBytes();
        CommandDelay();
        uint16_t serialLow = ReadTwoBytes();
        CommandDelay();

        _serial = (uint32_t(serialHigh) << 16) | serialLow;
    }

    float GetFlowSlpm()
    {
        UpdateIfRequired();
        return _flowRate;
    }

    uint32_t GetSerial()
    {
        return _serial;
    }

private:
    const int kI2cAddress = 0x49;
    const float kMaxSlpm = 15.0f;

    void EnsureDeviceIsResponsive()
    {
        _i2c.beginTransmission(kI2cAddress);
        uint8_t error =_i2c.endTransmission();
        assert(error == 0, F("No device found at requisite I2C address"));
        CommandDelay();
    }

    void UpdateIfRequired()
    {
        long nowMs = millis();
        if (nowMs - _lastUpdateMs >= 1)
        {
            uint16_t rawValue = ReadTwoBytes();
            _flowRate = kMaxSlpm * ((float(rawValue) / 16384) - 0.1f) / 0.8f;

            _lastUpdateMs = nowMs;
        }
    }

    void CommandDelay()
    {
        delay(10);
    }

    uint16_t ReadTwoBytes()
    {
        _i2c.requestFrom(kI2cAddress, 2);
        
        uint8_t buf[2];
        assert(_i2c.available(), F("Expected first I2C byte"));
        buf[0] = _i2c.read();

        assert(_i2c.available(), F("Expected second I2C byte"));
        buf[1] = _i2c.read();

        assert(!_i2c.available(), F("Expected no more than two I2C bytes"));

        return (uint16_t(buf[0]) << 8) | buf[1];
    }

    I2C& _i2c;

    uint32_t _serial;
    
    long _lastUpdateMs = 0;

    float _flowRate = 0.0f;
};

/////////////////////////////
// Humidity and temperature sensor
/////////////////////////////

template <class I2C>
class HumidityTemperatureSensor
{
public:
    HumidityTemperatureSensor(I2C& i2c)
        : _i2c(i2c)
    {
    }

    // std::tuple/tie not available on gcc's current toolchain
    float GetHumidity01()
    {
        UpdateIfRequired();

        return _humidity;
    }

    float GetTemperature()
    {
        UpdateIfRequired();

        return _temperature;
    }

private:
    const int kI2cAddress = 0x27;

    void EnsureDeviceIsResponsive()
    {
        _i2c.beginTransmission(kI2cAddress);
        uint8_t error =_i2c.endTransmission();
        assert(error == 0, F("No device found at requisite I2C address"));
        delay(10);
    }

    void UpdateIfRequired()
    {
        long nowMs = millis();
        if (nowMs - _lastUpdateMs >= 1)
        {
            _i2c.beginTransmission(kI2cAddress);
            _i2c.endTransmission();
            uint32_t rawValue = ReadFourBytes();

            // PrintStringHex32("HTRV", rawValue); DEFAULT_PRINT->print(" ");

            // uint8_t status = rawValue >> 30;
            uint16_t mask14 = (1 << 14) - 1;
            uint16_t rawHumidity = (rawValue >> 16) & mask14;
            uint16_t rawTemperature = (rawValue >> 2) & mask14;

            const uint16_t denominator = (1 << 14) - 2;
            _humidity = float(rawHumidity) / denominator;
            _temperature = ((float(rawTemperature) / denominator) * 165) - 40;

            _lastUpdateMs = nowMs;
        }
    }

    uint32_t ReadFourBytes()
    {
        _i2c.requestFrom(kI2cAddress, 4);
        
        uint8_t buf[4];
        assert(_i2c.available(), F("Expected first I2C byte"));
        buf[0] = _i2c.read();

        assert(_i2c.available(), F("Expected second I2C byte"));
        buf[1] = _i2c.read();

        assert(_i2c.available(), F("Expected third I2C byte"));
        buf[2] = _i2c.read();

        assert(_i2c.available(), F("Expected fourth I2C byte"));
        buf[3] = _i2c.read();

        assert(!_i2c.available(), F("Expected no more than four I2C bytes"));

        return (uint32_t(buf[0]) << 24)
        | (uint32_t(buf[1]) << 16)
        | (uint32_t(buf[2]) << 8)
        | buf[3];
    }

    I2C& _i2c;

    long _lastUpdateMs = 0;

    float _humidity = 0.0f;
    float _temperature = 0.0f;
};

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

SoftwareWire SWire(PIN_SOFTWARE_I2C_SDA, PIN_SOFTWARE_I2C_SCL);

void setup()
{
    Wire.begin();
    Wire.setClock(100000);
    SWire.begin();
    SWire.setClock(100000);

    Serial.begin(9600);
    while (!Serial);
}

#define ENABLE_INHALATION_PRESSURE_SENSOR 1
#define ENABLE_EXHALATION_PRESSURE_SENSOR 1
#define ENABLE_INHALATION_FLOW_SENSOR 1
#define ENABLE_EXHALATION_FLOW_SENSOR 1
#define ENABLE_HUMIDITY_TEMPERATURE_SENSOR 1

#define ENABLE_ALARM 1
#define ENABLE_O2_VALVE_SERVO 1
#define ENABLE_AIR_VALVE_SERVO 1

void loop()
{
#if ENABLE_INHALATION_PRESSURE_SENSOR
    DEFAULT_PRINT->print(F("Initializing inhalation pressure sensor...")); Ln();
    PressureSensor inhalationPressureSensor(PIN_INHALE_PRESSURE_SENSOR);
#endif

#if ENABLE_EXHALATION_PRESSURE_SENSOR
    DEFAULT_PRINT->print(F("Initializing exhalation pressure sensor...")); Ln();
    PressureSensor exhalationPressureSensor(PIN_EXHALE_PRESSURE_SENSOR);
#endif

#if ENABLE_INHALATION_FLOW_SENSOR
    DEFAULT_PRINT->print(F("Initializing inhalation flow sensor (hardware I2C)...")); Ln();
    FlowSensor<typeof(Wire)> inhalationFlowSensor(Wire);
    DEFAULT_PRINT->print(F("Inhalation serial: 0x"));
    PrintHex32(inhalationFlowSensor.GetSerial());
    Ln();
#endif

#if ENABLE_EXHALATION_FLOW_SENSOR
    DEFAULT_PRINT->print(F("Initializing exhalation flow sensor (software I2C)...")); Ln();
    FlowSensor<typeof(SWire)> exhalationFlowSensor(SWire);
    DEFAULT_PRINT->print(F("Exhalation serial: 0x"));
    PrintHex32(exhalationFlowSensor.GetSerial());
    Ln();
#endif

#if ENABLE_HUMIDITY_TEMPERATURE_SENSOR
    DEFAULT_PRINT->print(F("Initializing humidity and temperature sensor...")); Ln();
    HumidityTemperatureSensor<typeof(Wire)> humidityTemperatureSensor(Wire);
    Ln();
#endif

#if ENABLE_ALARM
    NoiseMaker alarm(PIN_ALARM_SPEAKER);
    alarm.SetEnabled(true);
#endif

#if ENABLE_O2_VALVE_SERVO
    ProportionalValve o2Valve(PIN_O2_VALVE);
#endif
#if ENABLE_AIR_VALVE_SERVO
    ProportionalValve airValve(PIN_AIR_VALVE);
#endif

#if ENABLE_ALARM
    long lastNoiseTimeMs = 0;
#endif

    for (;;)
    {

#if ENABLE_INHALATION_PRESSURE_SENSOR
        float inhalationPressure = inhalationPressureSensor.GetPressurePsi();
        PrintStringFloat(F("Inh P"), inhalationPressure);
        DEFAULT_PRINT->print(F(" PSI  "));
#endif
#if ENABLE_EXHALATION_PRESSURE_SENSOR
        float exhalationPressure = exhalationPressureSensor.GetPressurePsi();
        PrintStringFloat(F("Exh P"), exhalationPressure); 
        DEFAULT_PRINT->print(F(" PSI  "));
#endif

#if ENABLE_INHALATION_FLOW_SENSOR
        float inhalationFlow = inhalationFlowSensor.GetFlowSlpm();
        PrintStringFloat(F("Inh F"), inhalationFlow);
        DEFAULT_PRINT->print(F(" SLPM  "));
#endif

#if ENABLE_EXHALATION_FLOW_SENSOR
        float exhalationFlow = exhalationFlowSensor.GetFlowSlpm();
        PrintStringFloat(F("Exh F"), exhalationFlow);
        DEFAULT_PRINT->print(F(" SLPM "));
#endif

#if ENABLE_HUMIDITY_TEMPERATURE_SENSOR
        float humidity = humidityTemperatureSensor.GetHumidity01();
        float temperature = humidityTemperatureSensor.GetTemperature();
        PrintStringFloat(F("H"), humidity * 100);
        DEFAULT_PRINT->print(F(" %RH  "));
        PrintStringFloat(F("T"), temperature);
        DEFAULT_PRINT->print(F(" C  "));
#endif

        Ln();

#if ENABLE_ALARM
        alarm.Update();
        long nowMs = millis();
        if (nowMs - lastNoiseTimeMs > 1000)
        {
            // Serial.write("bleep!\n");
            alarm.Laser();
            lastNoiseTimeMs = nowMs;
        }
#endif

#if ENABLE_O2_VALVE_SERVO
        float o2Position = Clamp01(inhalationFlow / 16.0f);
        o2Valve.SetPosition(o2Position);
#endif

#if ENABLE_AIR_VALVE_SERVO
        float airPosition = Clamp01(exhalationFlow / 16.0f);
        airValve.SetPosition(airPosition);
#endif
    }
}